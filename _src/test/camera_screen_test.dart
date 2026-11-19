import 'package:flora_care/core/web_camera.dart';
import 'package:flora_care/l10n/l10n.dart';
import 'package:flora_care/ui/screens/camera_screen.dart';
import 'package:flora_care/ui/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Телефон/VM нұсқасында браузер камерасы жоқ (жүйелік камера қолданылады) —
/// экран түсінікті хабарлама мен «Галереядан» түймесін көрсетуі керек.
void main() {
  tearDown(() => L10n.current = Lang.kk);

  test('веб-камера модулі платформаға қарай таңдалады', () {
    expect(webCameraAvailable, isFalse); // тесттер VM-де жүреді
    expect(const WebCameraError('denied').code, 'denied');
  });

  testWidgets('камера қолжетімсіз болса — хабарлама мен галерея түймесі', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: buildTheme(dark: false),
      home: const CameraScreen(),
    ));
    await t.pumpAndSettle();

    expect(find.text(tr('cam.title')), findsOneWidget);
    expect(find.text(tr('cam.failed')), findsOneWidget);
    expect(find.text(tr('scan.gallery')), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('қате мәтіні таңдалған тілде шығады', (t) async {
    L10n.current = Lang.ru;
    await t.pumpWidget(MaterialApp(
      theme: buildTheme(dark: false),
      home: const CameraScreen(),
    ));
    await t.pumpAndSettle();

    expect(find.text('Не удалось включить камеру.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
