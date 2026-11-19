/// Gemini ЖИ талдауының моделі және жауапты тексеру (таза Dart, тестіленеді).
/// Желілік бөлігі — ai_service.dart.
library;
import 'dart:convert';

import '../l10n/l10n.dart';
import 'logic.dart';

/// Тексерілген реті (19.11.2026): 2.5-flash негізгі; 2.5-flash-lite жаңа
/// пайдаланушыларға жабылған (404), flash-latest жиі 503 береді.
const List<String> aiModels = [
  'gemini-2.5-flash',
  'gemini-3.1-flash-lite',
  'gemini-flash-lite-latest',
  'gemini-flash-latest',
];

/// Уақытша қателер — сол модельді бір рет қайталауға болады.
const Set<int> aiRetryCodes = {429, 500, 502, 503, 504};

const String aiPrompt = '''Сен — үй және бау-бақша өсімдіктерінің денсаулығын бағалайтын тәжірибелі агроном-фитопатолог әрі ботаниксің.
Суреттегі өсімдікті (әсіресе жапырақтарды, гүлін, сабағын) мұқият қарап, толық, түсінікті есеп бер.

Ережелер:
- Мәтінді төмендегі МАҢЫЗДЫ нұсқаудағы тілде жаз (латынша атаулардан басқа). Өзіңді, модельді немесе компанияны атама.
- Суретте өсімдік жоқ болса немесе сурет тым бұлыңғыр/қараңғы болса, is_plant=false қой, photo_quality_note толтыр,
  күйді "warning" қой, өсімдік туралы өрістерді бос қалдыр (ойдан толтырма).
- status: "healthy" — айқын белгі жоқ; "warning" — сарғаю, солу, дақтар, зиянкес белгілері басталған;
  "critical" — кең таралған қоңыр/қара дақтар, шірік, кебу, ауыр зақым.
- green_pct, yellow_pct, brown_pct — жапырақ (гүл болса — өсімдік) ауданындағы түс үлесі (қосындысы ≈100).
- color_explanation — осы түс үлестері НЕНІ білдіретінін осы өсімдікке қатысты 2–3 сөйлеммен түсіндір.
- health_score: 0 (өлген) … 100 (толық сау).
- summary — 2–3 сөйлемдік жалпы қорытынды.
- symptoms — суретте НАҚТЫ көрінетін белгілер (3–6); causes — ықтимал себептер, ең ықтималы бірінші (2–5);
  advice — нақты, орындалатын 4–6 қадам (не істеу, қашан, қанша).
- prognosis — қалпына келу мүмкіндігі және қанша уақытта (1–2 сөйлем).
- plant_info — өсімдік туралы деректер: latin_name, family (тұқымдасы қазақша + латынша), origin (отаны),
  description (өсімдік туралы 2–3 сөйлем), toxicity (адамға/үй жануарларына уыттылығы), fun_fact (бір қызықты дерек).
- care — осы түрге арналған күтім талаптары, әрқайсысы 1 сөйлем: light, watering, temperature, humidity, soil, fertilizer.
- next_check_days — келесі фото-тексеруді неше күннен кейін жасау керек (1–30).
- Сенімсіз болсаң, confidence мәнін төмен қой және оны жасырма. Ойдан диагноз құрастырма.''';

const List<String> plantInfoKeys = [
  'latin_name', 'family', 'origin', 'description', 'toxicity', 'fun_fact',
];
const List<String> careKeys = [
  'light', 'watering', 'temperature', 'humidity', 'soil', 'fertilizer',
];

final Map<String, Object> aiSchema = {
  'type': 'OBJECT',
  'properties': {
    'is_plant': {'type': 'BOOLEAN'},
    'plant_name': {'type': 'STRING'},
    'status': {
      'type': 'STRING',
      'enum': ['healthy', 'warning', 'critical'],
    },
    'health_score': {'type': 'INTEGER'},
    'green_pct': {'type': 'NUMBER'},
    'yellow_pct': {'type': 'NUMBER'},
    'brown_pct': {'type': 'NUMBER'},
    'diagnosis': {'type': 'STRING'},
    'summary': {'type': 'STRING'},
    'symptoms': {'type': 'ARRAY', 'items': {'type': 'STRING'}},
    'causes': {'type': 'ARRAY', 'items': {'type': 'STRING'}},
    'advice': {'type': 'ARRAY', 'items': {'type': 'STRING'}},
    'urgency': {
      'type': 'STRING',
      'enum': ['low', 'medium', 'high'],
    },
    'confidence': {'type': 'NUMBER'},
    'photo_quality_note': {'type': 'STRING'},
    'color_explanation': {'type': 'STRING'},
    'prognosis': {'type': 'STRING'},
    'plant_info': {
      'type': 'OBJECT',
      'properties': {
        for (final k in plantInfoKeys) k: {'type': 'STRING'},
      },
      'required': plantInfoKeys,
    },
    'care': {
      'type': 'OBJECT',
      'properties': {
        for (final k in careKeys) k: {'type': 'STRING'},
      },
      'required': careKeys,
    },
    'next_check_days': {'type': 'INTEGER'},
  },
  'required': [
    'is_plant', 'status', 'health_score', 'green_pct', 'yellow_pct',
    'brown_pct', 'color_explanation', 'diagnosis', 'summary', 'symptoms',
    'causes', 'advice', 'prognosis', 'urgency', 'confidence', 'plant_info',
    'care', 'next_check_days',
  ],
};

/// Жауап тілі туралы нұсқау (ағылшынша да қайталанады — модель нақты орындауы үшін).
String aiLanguageDirective(Lang lang) => switch (lang) {
      Lang.kk => '\nМАҢЫЗДЫ: барлық мәтін мәндерін ҚАЗАҚ тілінде жаз. IMPORTANT: write ALL text values in Kazakh.',
      Lang.ru => '\nМАҢЫЗДЫ: барлық мәтін мәндерін ОРЫС тілінде жаз. IMPORTANT: write ALL text values in Russian.',
      Lang.en => '\nМАҢЫЗДЫ: барлық мәтін мәндерін АҒЫЛШЫН тілінде жаз. IMPORTANT: write ALL text values in English.',
    };

String aiPromptFor(String plant, String species, [Lang lang = Lang.kk]) {
  var prompt = aiPrompt;
  if (plant.trim().isNotEmpty || species.trim().isNotEmpty) {
    final p = plant.trim().length > 60 ? plant.trim().substring(0, 60) : plant.trim();
    final s = species.trim().length > 60 ? species.trim().substring(0, 60) : species.trim();
    prompt += '\nПайдаланушы бұл өсімдікті «$p» деп атаған${s.isNotEmpty ? ' (түрі: $s)' : ''}.';
  }
  return prompt + aiLanguageDirective(lang);
}

/// ЖИ анықтаған атауды «Атауы (Latin name)» → (атауы, түрі) етіп бөледі.
/// Өсімдік емес сурет немесе бос атау → ('', '').
({String name, String species}) plantGuess(AiAnalysis? ai) {
  if (ai == null || !ai.isPlant) return (name: '', species: '');
  var raw = ai.plantName.trim().replaceFirst(RegExp(r'^Пайдаланушы айтқан:\s*'), '');
  var species = '';
  final m = RegExp(r'^(.*?)\s*\(([^)]*)\)\s*$').firstMatch(raw);
  if (m != null) {
    raw = m.group(1)!.trim();
    species = m.group(2)!.trim();
  }
  String cut(String s) => s.length > maxNameLen ? s.substring(0, maxNameLen) : s;
  return (name: cut(raw), species: cut(species));
}

class AiAnalysis {
  final bool isPlant;
  final String plantName;
  final String status;
  final int healthScore;
  final double greenPct;
  final double yellowPct;
  final double brownPct;
  final String diagnosis;
  final String summary;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> advice;
  final String urgency;
  final double confidence;
  final String photoQualityNote;
  final String colorExplanation;
  final String prognosis;

  /// latin_name, family, origin, description, toxicity, fun_fact (бос мәндер — '').
  final Map<String, String> plantInfo;

  /// light, watering, temperature, humidity, soil, fertilizer.
  final Map<String, String> care;
  final int nextCheckDays;
  final String model;
  final int ms;

  const AiAnalysis({
    required this.isPlant,
    required this.plantName,
    required this.status,
    required this.healthScore,
    required this.greenPct,
    required this.yellowPct,
    required this.brownPct,
    required this.diagnosis,
    required this.summary,
    required this.symptoms,
    required this.causes,
    required this.advice,
    required this.urgency,
    required this.confidence,
    required this.photoQualityNote,
    this.colorExplanation = '',
    this.prognosis = '',
    this.plantInfo = const {},
    this.care = const {},
    this.nextCheckDays = 7,
    this.model = '',
    this.ms = 0,
  });

  String get urgencyLabel => tr('urgency.$urgency');

  bool get hasPlantInfo => isPlant && plantInfo.values.any((v) => v.isNotEmpty);
  bool get hasCare => isPlant && care.values.any((v) => v.isNotEmpty);

  /// Модель жауабын тексеріп, шекараларға келтіреді. Жарамсыз мәндер —
  /// қауіпсіз әдепкі мәндерге ауыстырылады, қолданба ешқашан құламайды.
  factory AiAnalysis.fromJson(Map<String, dynamic> r,
      {String model = '', int ms = 0}) {
    double num0(Object? v, double lo, double hi, double def) {
      final d = v is num ? v.toDouble() : double.tryParse('$v');
      if (d == null || d.isNaN) return def;
      return d.clamp(lo, hi).toDouble();
    }

    const empty = {'n/a', 'na', '-', '—', 'жоқ', 'белгісіз', 'none', 'null'};
    String str(Object? v, int max) {
      final s = (v ?? '').toString().trim();
      if (empty.contains(s.toLowerCase())) return '';
      return s.length > max ? s.substring(0, max) : s;
    }

    Map<String, String> obj(Object? v, List<String> keys, int max) {
      final m = v is Map ? v : const {};
      return {for (final k in keys) k: str(m[k], max)};
    }

    List<String> list(Object? v) => (v is List ? v : const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .take(6)
        .toList();

    var g = num0(r['green_pct'], 0, 100, 0);
    var y = num0(r['yellow_pct'], 0, 100, 0);
    var b = num0(r['brown_pct'], 0, 100, 0);
    final total = g + y + b;
    if (total > 0) {
      g = (g / total * 1000).round() / 10;
      y = (y / total * 1000).round() / 10;
      b = (b / total * 1000).round() / 10;
    }
    final st = r['status'];
    final urg = r['urgency'];
    final isPlant = r['is_plant'] is bool ? r['is_plant'] as bool : true;
    return AiAnalysis(
      isPlant: isPlant,
      plantName: str(r['plant_name'], 80),
      status: statusSeverity.containsKey(st) ? st as String : kWarning,
      healthScore: num0(r['health_score'], 0, 100, 50).round(),
      greenPct: g,
      yellowPct: y,
      brownPct: b,
      diagnosis: str(r['diagnosis'], 80),
      summary: str(r['summary'], 600),
      symptoms: list(r['symptoms']),
      causes: list(r['causes']),
      advice: list(r['advice']),
      urgency: const {'low', 'medium', 'high'}.contains(urg) ? urg as String : 'medium',
      confidence: (num0(r['confidence'], 0, 1, .5) * 100).round() / 100,
      photoQualityNote: str(r['photo_quality_note'], 200),
      // Өсімдік жоқ суретке «өсімдік туралы», «күтім» және түс түсіндірмесін көрсетпейміз
      colorExplanation: isPlant ? str(r['color_explanation'], 500) : '',
      prognosis: str(r['prognosis'], 300),
      plantInfo: isPlant
          ? obj(r['plant_info'], plantInfoKeys, 400)
          : {for (final k in plantInfoKeys) k: ''},
      care: isPlant ? obj(r['care'], careKeys, 220) : {for (final k in careKeys) k: ''},
      nextCheckDays: num0(r['next_check_days'], 1, 30, 7).round(),
      model: model,
      ms: ms,
    );
  }

  /// Gemini generateContent жауабынан мәтінді алып, талдайды.
  factory AiAnalysis.fromGeminiResponse(Map<String, dynamic> data,
      {String model = '', int ms = 0}) {
    try {
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      return AiAnalysis.fromJson(jsonDecode(text) as Map<String, dynamic>,
          model: model, ms: ms);
    } catch (_) {
      throw const ValidationError('err.ai.format');
    }
  }

  Map<String, Object?> toJson() => {
        'is_plant': isPlant,
        'plant_name': plantName,
        'status': status,
        'health_score': healthScore,
        'green_pct': greenPct,
        'yellow_pct': yellowPct,
        'brown_pct': brownPct,
        'diagnosis': diagnosis,
        'summary': summary,
        'symptoms': symptoms,
        'causes': causes,
        'advice': advice,
        'urgency': urgency,
        'confidence': confidence,
        'photo_quality_note': photoQualityNote,
        'color_explanation': colorExplanation,
        'prognosis': prognosis,
        'plant_info': plantInfo,
        'care': care,
        'next_check_days': nextCheckDays,
        'model': model,
        'ms': ms,
      };

  String encode() => jsonEncode(toJson());

  /// Дерекқордан оқу: бос немесе бұзылған JSON → null.
  static AiAnalysis? tryDecode(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return AiAnalysis.fromJson(m,
          model: (m['model'] ?? '').toString(),
          ms: (m['ms'] is num) ? (m['ms'] as num).toInt() : 0);
    } catch (_) {
      return null;
    }
  }
}
