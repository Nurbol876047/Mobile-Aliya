import 'dart:convert';

import 'package:flora_care/core/ai.dart';
import 'package:flora_care/l10n/l10n.dart';
import 'package:flora_care/core/logic.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> good() => {
      'is_plant': true,
      'plant_name': 'Фикус (Ficus elastica)',
      'status': 'warning',
      'health_score': 62,
      'green_pct': 60,
      'yellow_pct': 30,
      'brown_pct': 10,
      'diagnosis': 'Азот жетіспеушілігі',
      'summary': 'Төменгі жапырақтар сарғайған.',
      'symptoms': ['Сарғаю', ' ', 'Жиектің құрғауы'],
      'causes': ['Азот аз'],
      'advice': ['Тыңайтқыш беріңіз', 'Суаруды тексеріңіз'],
      'urgency': 'medium',
      'confidence': 0.8,
    };

void main() {
  group('ЖИ жауабын тексеру (normalize)', () {
    test('дұрыс жауап', () {
      final a = AiAnalysis.fromJson(good(), model: 'gemini-2.5-flash', ms: 1200);
      expect(a.status, kWarning);
      expect(a.healthScore, 62);
      expect(a.diagnosis, 'Азот жетіспеушілігі');
      expect(a.symptoms, ['Сарғаю', 'Жиектің құрғауы']); // бос жол алынып тасталды
      expect(a.urgencyLabel, 'Жақын күндері');
      expect(a.model, 'gemini-2.5-flash');
    });

    test('пайыздар 100-ге келтіріледі', () {
      final a = AiAnalysis.fromJson({...good(), 'green_pct': 30, 'yellow_pct': 30, 'brown_pct': 0});
      expect(a.greenPct, 50.0);
      expect(a.yellowPct, 50.0);
      expect(a.brownPct, 0.0);
    });

    test('шектен шыққан мәндер қиылады', () {
      final a = AiAnalysis.fromJson({
        ...good(),
        'health_score': 250,
        'confidence': 7,
        'green_pct': -20,
      });
      expect(a.healthScore, 100);
      expect(a.confidence, 1.0);
      expect(a.greenPct, 0.0);
    });

    test('белгісіз күй/шұғылдық — қауіпсіз әдепкі', () {
      final a = AiAnalysis.fromJson({...good(), 'status': 'dead', 'urgency': 'now'});
      expect(a.status, kWarning);
      expect(a.urgency, 'medium');
    });

    test('өрістер мүлдем жоқ — құламайды', () {
      final a = AiAnalysis.fromJson({});
      expect(a.isPlant, isTrue);
      expect(a.status, kWarning);
      expect(a.healthScore, 50);
      expect(a.advice, isEmpty);
      expect(a.greenPct + a.yellowPct + a.brownPct, 0);
    });

    test('мәтін түріндегі сандар және ұзын мәтін', () {
      final a = AiAnalysis.fromJson({
        ...good(),
        'health_score': '77',
        'diagnosis': 'а' * 200,
        'advice': List.generate(10, (i) => 'қадам $i'),
      });
      expect(a.healthScore, 77);
      expect(a.diagnosis.length, 80);
      expect(a.advice.length, 6);
    });

    test('өсімдік емес сурет', () {
      final a = AiAnalysis.fromJson({...good(), 'is_plant': false, 'photo_quality_note': 'Бұлыңғыр'});
      expect(a.isPlant, isFalse);
      expect(a.photoQualityNote, 'Бұлыңғыр');
    });
  });

  group('Gemini жауабы және сақтау', () {
    test('generateContent жауабынан оқу', () {
      final resp = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': jsonEncode(good())}
              ]
            }
          }
        ]
      };
      final a = AiAnalysis.fromGeminiResponse(resp, model: 'm');
      expect(a.diagnosis, 'Азот жетіспеушілігі');
    });

    test('ой (thought) және мәтінсіз бөліктер өткізіліп жіберіледі', () {
      final resp = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'thoughtSignature': 'abc'},
                {'text': 'ойлау...', 'thought': true},
                {'text': jsonEncode(good())}
              ]
            }
          }
        ]
      };
      final a = AiAnalysis.fromGeminiResponse(resp, model: 'm');
      expect(a.diagnosis, 'Азот жетіспеушілігі');
    });

    test('бұзылған жауап — ValidationError', () {
      expect(() => AiAnalysis.fromGeminiResponse({'candidates': []}),
          throwsA(isA<ValidationError>()));
      expect(
          () => AiAnalysis.fromGeminiResponse({
                'candidates': [
                  {
                    'content': {
                      'parts': [
                        {'text': 'бұл JSON емес'}
                      ]
                    }
                  }
                ]
              }),
          throwsA(isA<ValidationError>()));
    });

    test('encode → tryDecode айналымы', () {
      final a = AiAnalysis.fromJson(good(), model: 'gemini-2.5-flash', ms: 900);
      final b = AiAnalysis.tryDecode(a.encode())!;
      expect(b.diagnosis, a.diagnosis);
      expect(b.healthScore, a.healthScore);
      expect(b.model, 'gemini-2.5-flash');
      expect(b.ms, 900);
    });

    test('бос немесе бұзылған сақталған JSON → null', () {
      expect(AiAnalysis.tryDecode(''), isNull);
      expect(AiAnalysis.tryDecode('{бұзылған'), isNull);
    });

    test('промптқа өсімдік атауы қосылады және қиылады', () {
      expect(aiPromptFor('', ''), aiPrompt + aiLanguageDirective(Lang.kk));
      final p = aiPromptFor('Фикус', 'Ficus elastica');
      expect(p, contains('«Фикус»'));
      expect(p, contains('Ficus elastica'));
      expect(aiPromptFor('а' * 100, ''), contains('«${'а' * 60}»'));
    });

    test('промпт соңында жауап тілі көрсетіледі', () {
      for (final lang in Lang.values) {
        expect(aiPromptFor('', '', lang), endsWith(aiLanguageDirective(lang)));
      }
      expect(aiPromptFor('', '', Lang.ru), contains('Russian'));
      expect(aiPromptFor('', '', Lang.en), contains('English'));
      expect(aiPromptFor('Фикус', '', Lang.kk), contains('Kazakh'));
    });
  });

  group('ЖИ анықтаған атауды бөлу (plantGuess)', () {
    test('атауы мен латынша түрі', () {
      final g = plantGuess(AiAnalysis.fromJson({...good(), 'plant_name': 'Фикус (Ficus elastica)'}));
      expect(g.name, 'Фикус');
      expect(g.species, 'Ficus elastica');
    });
    test('жақшасыз атау', () {
      final g = plantGuess(AiAnalysis.fromJson({...good(), 'plant_name': 'Монстера'}));
      expect(g.name, 'Монстера');
      expect(g.species, '');
    });
    test('өсімдік емес сурет — бос', () {
      final g = plantGuess(AiAnalysis.fromJson({...good(), 'is_plant': false}));
      expect(g.name, '');
      expect(plantGuess(null).name, '');
    });
    test('«Пайдаланушы айтқан:» префиксі алынады', () {
      final g = plantGuess(AiAnalysis.fromJson(
          {...good(), 'plant_name': 'Пайдаланушы айтқан: Фикус (Ficus elastica)'}));
      expect(g.name, 'Фикус');
    });
  });

  group('Кеңейтілген есеп (өсімдік туралы, күтім, болжам)', () {
    Map<String, dynamic> full() => {
          ...good(),
          'color_explanation': 'Сарғаю 30% — азот жетіспеушілігі.',
          'prognosis': '2–3 аптада қалпына келеді.',
          'plant_info': {
            'latin_name': 'Ficus elastica',
            'family': 'Тұттар (Moraceae)',
            'origin': 'Оңтүстік-Шығыс Азия',
            'description': 'Үлкен жапырақты бөлме өсімдігі.',
            'toxicity': 'N/A',
            'fun_fact': 'Табиғатта 30 м-ге дейін өседі.',
          },
          'care': {'light': 'Шашыраңқы жарық', 'watering': '—', 'soil': 'Жеңіл топырақ'},
          'next_check_days': 10,
        };

    test('жаңа өрістер оқылады', () {
      final a = AiAnalysis.fromJson(full());
      expect(a.colorExplanation, contains('азот'));
      expect(a.prognosis, isNotEmpty);
      expect(a.plantInfo['latin_name'], 'Ficus elastica');
      expect(a.care['light'], 'Шашыраңқы жарық');
      expect(a.nextCheckDays, 10);
      expect(a.hasPlantInfo, isTrue);
      expect(a.hasCare, isTrue);
    });

    test('«N/A», «—» сияқты бос мәндер тазаланады', () {
      final a = AiAnalysis.fromJson(full());
      expect(a.plantInfo['toxicity'], '');
      expect(a.care['watering'], '');
      expect(a.care['temperature'], ''); // мүлдем жоқ кілт
    });

    test('өсімдік емес сурет — өсімдік туралы/күтім көрсетілмейді', () {
      final a = AiAnalysis.fromJson({...full(), 'is_plant': false});
      expect(a.hasPlantInfo, isFalse);
      expect(a.hasCare, isFalse);
      expect(a.colorExplanation, '');
    });

    test('келесі тексеру күні 1..30 аралығына қиылады', () {
      expect(AiAnalysis.fromJson({...full(), 'next_check_days': 99}).nextCheckDays, 30);
      expect(AiAnalysis.fromJson({...full(), 'next_check_days': 0}).nextCheckDays, 1);
      expect(AiAnalysis.fromJson({...good()}).nextCheckDays, 7); // жоқ болса — әдепкі
    });

    test('сақтау/оқу айналымында жаңа өрістер сақталады', () {
      final b = AiAnalysis.tryDecode(AiAnalysis.fromJson(full()).encode())!;
      expect(b.plantInfo['family'], 'Тұттар (Moraceae)');
      expect(b.care['soil'], 'Жеңіл топырақ');
      expect(b.nextCheckDays, 10);
      expect(b.prognosis, isNotEmpty);
    });

    test('схемада барлық жаңа өрістер міндетті', () {
      final req = aiSchema['required'] as List;
      for (final k in ['plant_info', 'care', 'prognosis', 'color_explanation', 'next_check_days']) {
        expect(req, contains(k));
      }
    });
  });
}
