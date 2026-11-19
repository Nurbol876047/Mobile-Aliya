import 'package:flora_care/core/logic.dart';
import 'package:flora_care/core/models.dart';
import 'package:flutter_test/flutter_test.dart';

Observation obs({
  int id = 1,
  int plantId = 1,
  String plantName = 'Монстера',
  String status = kHealthy,
  double green = 90,
  String note = '',
  DateTime? at,
}) =>
    Observation(
      id: id,
      plantId: plantId,
      plantName: plantName,
      takenAt: at ?? DateTime(2026, 11, 10),
      status: status,
      greenPct: green,
      yellowPct: 5,
      brownPct: 5,
      note: note,
    );

void main() {
  group('Валидация', () {
    test('атауды тазалайды', () {
      expect(validatePlantName('  Фикус '), 'Фикус');
    });
    test('бос атау — қате', () {
      expect(() => validatePlantName('   '), throwsA(isA<ValidationError>()));
      expect(() => validatePlantName(null), throwsA(isA<ValidationError>()));
    });
    test('ұзын атау — қате', () {
      expect(() => validatePlantName('а' * 61),
          throwsA(isA<ValidationError>()));
      expect(validatePlantName('а' * 60).length, 60);
    });
    test('жазба шегі', () {
      expect(validateNote(null), '');
      expect(validateNote('  ok  '), 'ok');
      expect(() => validateNote('a' * 501), throwsA(isA<ValidationError>()));
    });
    test('фото кеңейтімі мен өлшемі', () {
      expect(validatePhotoUpload('leaf.JPG', 1000), 'jpg');
      expect(validatePhotoUpload('leaf.webp', 1000), 'webp');
      expect(() => validatePhotoUpload('leaf.gif', 1000),
          throwsA(isA<ValidationError>()));
      expect(() => validatePhotoUpload('leaf', 1000),
          throwsA(isA<ValidationError>()));
      expect(() => validatePhotoUpload('leaf.jpg', 0),
          throwsA(isA<ValidationError>()));
      expect(() => validatePhotoUpload('leaf.jpg', maxPhotoBytes + 1),
          throwsA(isA<ValidationError>()));
      expect(validatePhotoUpload('leaf.jpg', maxPhotoBytes), 'jpg');
    });
  });

  group('Іздеу, сүзу, сұрыптау', () {
    final items = [
      obs(id: 1, plantName: 'Монстера', at: DateTime(2026, 11, 1), green: 90),
      obs(
          id: 2,
          plantId: 2,
          plantName: 'Фикус',
          status: kWarning,
          at: DateTime(2026, 11, 5),
          green: 60,
          note: 'сарғайған'),
      obs(
          id: 3,
          plantId: 3,
          plantName: 'Алоэ',
          status: kCritical,
          at: DateTime(2026, 11, 9),
          green: 30),
    ];
    final now = DateTime(2026, 11, 10);

    test('әдепкі: күні бойынша кему', () {
      final r = filterAndSort(items, now: now);
      expect(r.map((e) => e.id).toList(), [3, 2, 1]);
    });
    test('өсу ретімен', () {
      final r = filterAndSort(items, descending: false, now: now);
      expect(r.map((e) => e.id).toList(), [1, 2, 3]);
    });
    test('мәтін бойынша іздеу (атау және жазба)', () {
      expect(filterAndSort(items, query: 'фик', now: now).length, 1);
      expect(filterAndSort(items, query: 'САРҒАЙ', now: now).single.id, 2);
      expect(filterAndSort(items, query: 'жоқ', now: now), isEmpty);
    });
    test('күй бойынша сүзу', () {
      expect(filterAndSort(items, status: kWarning, now: now).single.id, 2);
    });
    test('өсімдік бойынша сүзу', () {
      expect(filterAndSort(items, plantId: 3, now: now).single.id, 3);
    });
    test('кезең бойынша сүзу', () {
      expect(filterAndSort(items, days: 7, now: now).map((e) => e.id).toList(),
          [3, 2]);
      expect(filterAndSort(items, days: 2, now: now).map((e) => e.id).toList(),
          [3]);
    });
    test('атау бойынша сұрыптау', () {
      final r = filterAndSort(items,
          sortBy: 'plant', descending: false, now: now);
      expect(r.map((e) => e.plantName).toList(), ['Алоэ', 'Монстера', 'Фикус']);
    });
    test('күй ауырлығы бойынша сұрыптау', () {
      final r = filterAndSort(items, sortBy: 'status', now: now);
      expect(r.first.status, kCritical);
    });
    test('жасыл үлесі бойынша сұрыптау', () {
      final r = filterAndSort(items,
          sortBy: 'green', descending: false, now: now);
      expect(r.map((e) => e.greenPct).toList(), [30.0, 60.0, 90.0]);
    });
    test('белгісіз кілт/күй/күн — қате', () {
      expect(() => filterAndSort(items, sortBy: 'xxx'),
          throwsA(isA<ValidationError>()));
      expect(() => filterAndSort(items, status: 'xxx'),
          throwsA(isA<ValidationError>()));
      expect(() => filterAndSort(items, days: 0),
          throwsA(isA<ValidationError>()));
    });
    test('бос тізім', () {
      expect(filterAndSort(const [], query: 'а'), isEmpty);
    });
  });

  group('Үрдіс', () {
    test('жеткіліксіз дерек', () {
      expect(trend([]), 'insufficient');
      expect(trend([80]), 'insufficient');
    });
    test('жақсару / нашарлау / тұрақты', () {
      expect(trend([70, 80]), 'improving');
      expect(trend([80, 70]), 'worsening');
      expect(trend([80, 82]), 'stable');
      expect(trend([80, 85]), 'improving'); // дәл +5
      expect(trend([80, 75]), 'worsening'); // дәл -5
    });
  });
}
