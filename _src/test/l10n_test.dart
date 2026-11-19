import 'dart:io';

import 'package:flora_care/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

/// lib/ ішіндегі барлық tr('...') кілттері.
Set<String> usedKeys() {
  final re = RegExp(r"""tr\(\s*'([a-zA-Z0-9_.]+)'""");
  final keys = <String>{};
  for (final f in Directory('lib').listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart')) {
      for (final m in re.allMatches(f.readAsStringSync())) {
        keys.add(m.group(1)!);
      }
    }
  }
  return keys;
}

final _placeholder = RegExp(r'\{(\w+)\}');

void main() {
  tearDown(() => L10n.current = Lang.kk);

  group('Локализация (қазақша / русский / English)', () {
    test('әр кілтте үш тілдің де мәні бар және бос емес', () {
      for (final key in L10n.keys) {
        final values = L10n.raw(key)!;
        expect(values.length, Lang.values.length, reason: key);
        for (var i = 0; i < values.length; i++) {
          expect(values[i].trim(), isNotEmpty,
              reason: '$key → ${Lang.values[i].code}');
        }
      }
    });

    test('орын басарлар ({n}, {date}…) барлық тілде бірдей', () {
      for (final key in L10n.keys) {
        final values = L10n.raw(key)!;
        final expected = _placeholder
            .allMatches(values.first)
            .map((m) => m.group(1)!)
            .toSet();
        for (var i = 1; i < values.length; i++) {
          final actual =
              _placeholder.allMatches(values[i]).map((m) => m.group(1)!).toSet();
          expect(actual, expected,
              reason: '$key → ${Lang.values[i].code}');
        }
      }
    });

    test('интерфейстегі барлық tr() кілті аударылған', () {
      final used = usedKeys();
      expect(used, isNotEmpty); // іздеу жұмыс істеп тұрғанының тексерісі
      final missing = used
          .where((k) => !k.contains(r'$') && !L10n.has(k))
          .toList()
        ..sort();
      expect(missing, isEmpty, reason: 'аудармасы жоқ кілттер: $missing');
    });

    test('tr() таңдалған тілге сәйкес мәтін береді', () {
      L10n.current = Lang.kk;
      expect(tr('nav.home'), 'Басты бет');
      L10n.current = Lang.ru;
      expect(tr('nav.home'), 'Главная');
      L10n.current = Lang.en;
      expect(tr('nav.home'), 'Home');
    });

    test('аргументтер қойылады, белгісіз кілт өзі қайтады', () {
      L10n.current = Lang.ru;
      expect(tr('cat.subtitle', {'n': 27}), contains('27'));
      expect(tr('жоқ.кілт'), 'жоқ.кілт');
    });

    test('тіл коды сақталады және оқылады', () {
      expect(LangX.parse('ru'), Lang.ru);
      expect(LangX.parse('en'), Lang.en);
      expect(LangX.parse(null), Lang.kk);
      expect(LangX.parse('de'), Lang.kk); // белгісіз код → әдепкі
      for (final l in Lang.values) {
        expect(LangX.parse(l.code), l);
        expect(l.label.trim(), isNotEmpty);
        expect(l.aiName.trim(), isNotEmpty);
      }
    });
  });
}
