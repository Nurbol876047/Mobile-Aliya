import 'package:flora_care/core/ai.dart';
import 'package:flora_care/ui/theme.dart';
import 'package:flora_care/ui/widgets/ai_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

AiAnalysis sample({bool isPlant = true}) => AiAnalysis.fromJson({
      'is_plant': isPlant,
      'plant_name': 'Раушан (Rosa)',
      'status': 'critical',
      'health_score': 5,
      'green_pct': 0,
      'yellow_pct': 0,
      'brown_pct': 100,
      'color_explanation': 'Қоңыр түс 100% — толық кебу.',
      'diagnosis': 'Қураған раушан, сусыздықтан өлген',
      'summary': 'Гүл толығымен қурап, солып қалған.',
      'symptoms': ['Қураған жапырақтар', 'Солған гүл'],
      'causes': ['Судың жетіспеушілігі'],
      'advice': ['Құрғақ бөліктерді кесіңіз', 'Үнемі суарыңыз'],
      'prognosis': 'Қалпына келу мүмкіндігі төмен.',
      'urgency': 'high',
      'confidence': 0.9,
      'plant_info': {
        'latin_name': 'Rosa',
        'family': 'Раушангүлділер (Rosaceae)',
        'origin': 'Азия',
        'description': 'Көпжылдық сәндік бұта.',
        'toxicity': 'Уытты емес.',
        'fun_fact': '30 000-нан астам сорты бар.',
      },
      'care': {
        'light': 'Күніне 6+ сағат күн',
        'watering': 'Аптасына 2–3 рет',
        'temperature': '18–24°C',
        'humidity': '50–60%',
        'soil': 'Құнарлы топырақ',
        'fertilizer': '2 аптада бір',
      },
      'next_check_days': 3,
    }, ms: 8400);

Future<void> pumpCard(WidgetTester t, AiAnalysis ai) async {
  t.view.physicalSize = const Size(375 * 3, 812 * 3); // телефон экраны
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
    theme: buildTheme(dark: false),
    home: Scaffold(body: ListView(padding: const EdgeInsets.all(20), children: [AiCard(ai)])),
  ));
}

void main() {
  testWidgets('толық есеп: барлық бөлімдер, қатесіз сызылады', (t) async {
    await pumpCard(t, sample());
    for (final txt in [
      'Жапырақ түсінің жіктелуі', 'Байқалған белгілер', 'Ықтимал себептер',
      'Не істеу керек', 'Болжам', 'Өсімдік туралы', 'Күтім талаптары',
      'Rosa', 'Уыттылығы', 'Қызықты дерек', 'Суару', 'Келесі тексеру: 3 күннен кейін',
    ]) {
      expect(find.textContaining(txt), findsWidgets, reason: txt);
    }
    expect(find.textContaining('Gemini'), findsNothing);
    expect(t.takeException(), isNull); // overflow т.б. жоқ
  });

  testWidgets('өсімдік емес сурет: өсімдік туралы/күтім жоқ', (t) async {
    await pumpCard(t, sample(isPlant: false));
    expect(find.text('Өсімдік туралы'), findsNothing);
    expect(find.text('Күтім талаптары'), findsNothing);
    expect(t.takeException(), isNull);
  });
}
