/// Gemini арқылы фото талдау.
///
/// Екі режим (құрастыру кезінде --dart-define арқылы таңдалады):
///  1) AI_BACKEND_URL — қолданба біздің серверге (backend/server.py) жібереді,
///     API кілті тек серверде сақталады. ҰСЫНЫЛАТЫН режим.
///  2) GEMINI_API_KEY — қолданба Gemini-ге тікелей жібереді. Қарапайым, бірақ
///     кілт APK ішіне енеді (оқу жобасы/демо үшін ғана).
/// Екеуі де берілмесе, ЖИ өшірулі — талдау қолжетімсіз (жалған нәтиже көрсетілмейді).
library;
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../l10n/l10n.dart';
import 'ai.dart';
import 'logic.dart';

class AiService {
  static const String backendUrl = String.fromEnvironment('AI_BACKEND_URL');
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
  // Render-дің тегін жоспарында ұйықтап қалған сервер ≈1 минутта оянады.
  static const Duration timeout = Duration(seconds: 100);

  static bool get enabled => backendUrl.isNotEmpty || apiKey.isNotEmpty;

  static String get modeLabel => backendUrl.isNotEmpty
      ? 'сервер арқылы'
      : apiKey.isNotEmpty
          ? 'тікелей'
          : 'ЖИ өшірулі';

  /// [jpeg] — кішірейтілген JPEG (≈768 px), желі баяу болса да тез жетеді.
  static Future<AiAnalysis> analyze(Uint8List jpeg,
      {String plant = '', String species = ''}) async {
    if (!enabled) throw const ValidationError('err.ai.notConfigured');
    if (jpeg.isEmpty) throw const ValidationError('err.photoEmpty');
    return backendUrl.isNotEmpty
        ? _viaBackend(jpeg, plant, species)
        : _direct(jpeg, plant, species);
  }

  static Future<AiAnalysis> _viaBackend(
      Uint8List jpeg, String plant, String species) async {
    final uri = Uri.parse('${backendUrl.replaceAll(RegExp(r'/+$'), '')}/api/analyze');
    final http.Response resp;
    try {
      resp = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'image': 'data:image/jpeg;base64,${base64Encode(jpeg)}',
                'plant': plant,
                'species': species,
                'lang': L10n.current.code,
              }))
          .timeout(timeout);
    } catch (_) {
      throw const ValidationError('err.ai.network');
    }
    final Map<String, dynamic> j;
    try {
      j = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw const ValidationError('err.ai.unavailable');
    }
    if (j['ok'] != true) {
      // Сервер қате кодын қайтарады → таңдалған тілде көрсетеміз
      const codes = {
        'busy': 'err.ai.busy',
        'unavailable': 'err.ai.unavailable',
        'key': 'err.ai.key',
        'bad_image': 'err.ai.badImage',
        'too_big': 'err.photoTooBig',
        'not_configured': 'err.ai.notConfigured',
      };
      throw ValidationError(codes[j['code']] ?? 'err.ai.unavailable');
    }
    return AiAnalysis.fromJson(j['result'] as Map<String, dynamic>,
        model: '',
        ms: (j['ms'] is num) ? (j['ms'] as num).toInt() : 0);
  }

  static Future<AiAnalysis> _direct(
      Uint8List jpeg, String plant, String species) async {
    final contents = [
      {
        'role': 'user',
        'parts': [
          {'text': aiPromptFor(plant, species, L10n.current)},
          {
            'inline_data': {'mime_type': 'image/jpeg', 'data': base64Encode(jpeg)}
          },
        ],
      }
    ];

    var last = 'Белгісіз қате';
    var busy = false;
    for (final model in aiModels) {
      final gen = <String, Object>{
        'temperature': 0.2,
        'responseMimeType': 'application/json',
        'responseSchema': aiSchema,
        if (model.startsWith('gemini-2.5'))
          'thinkingConfig': {'thinkingBudget': 1024},
      };
      final body = jsonEncode({'contents': contents, 'generationConfig': gen});

      for (var attempt = 1; attempt <= 2; attempt++) {
        final sw = Stopwatch()..start();
        try {
          final resp = await http
              .post(
                Uri.parse(
                    'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent'),
                // Кілт URL-де емес, тақырыпта жіберіледі (логтарға түспейді).
                headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
                body: body,
              )
              .timeout(const Duration(seconds: 35));
          if ([400, 401, 403].contains(resp.statusCode) &&
              utf8.decode(resp.bodyBytes).contains('API key')) {
            throw const ValidationError('err.ai.key');
          }
          if (resp.statusCode != 200) {
            last = '$model: HTTP ${resp.statusCode}';
            // 429 «quota» — шектеу таусылған: қайталамай, бірден келесі модельге
            final quotaExhausted = resp.statusCode == 429 &&
                utf8.decode(resp.bodyBytes).toLowerCase().contains('quota');
            if (aiRetryCodes.contains(resp.statusCode) && !quotaExhausted) {
              busy = true;
              if (attempt == 1) {
                await Future<void>.delayed(const Duration(milliseconds: 1500));
                continue; // сол модельді тағы бір рет
              }
            }
            break; // 404, quota т.б. — келесі модель
          }
          return AiAnalysis.fromGeminiResponse(
            jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>,
            model: model,
            ms: sw.elapsedMilliseconds,
          );
        } on ValidationError catch (e) {
          if (e.message == 'err.ai.key') rethrow;
          last = '$model: ${e.message}';
          break;
        } catch (e) {
          // таймаут / желі — уақытты үнемдеп, келесі модельге
          last = '$model: $e';
          busy = true;
          break;
        }
      }
    }
    debugPrint('AI: all models failed: $last'); // егжей-тегжей тек логта
    if (busy) {
      throw const ValidationError('err.ai.busy');
    }
    throw const ValidationError('err.ai.unavailable');
  }
}
