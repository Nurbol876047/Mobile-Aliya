import 'package:flora_care/core/prefs_repo.dart';
import 'package:flora_care/state/app_state.dart';
import 'package:flora_care/ui/app.dart';
import 'package:flora_care/ui/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Телефондағы жүйелік панельдер (жоғарыда күй жолағы, төменде «артқа/үй/соңғылар»)
/// қолданба мәзірін жаппауы керек: мәзір SafeArea ішінде тұр.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const double systemNavBar = 48; // Android 3 түймелі панелі
  const Size phone = Size(400, 800);

  Future<AppState> buildState() async {
    SharedPreferences.setMockInitialValues(<String, Object>{'seen_onboarding': true});
    final state = AppState(PrefsRepo());
    await state.init();
    return state;
  }

  Future<void> pumpApp(WidgetTester t, AppState state, EdgeInsets padding) async {
    await t.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        theme: buildTheme(dark: false),
        home: MediaQuery(
          data: MediaQueryData(size: phone, padding: padding),
          child: const RootNav(),
        ),
      ),
    ));
    await t.pump();
  }

  testWidgets('мәзір жүйелік панельдің үстінде тұрады', (t) async {
    t.view.physicalSize = const Size(400 * 3, 800 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);

    final state = await buildState();
    await pumpApp(t, state, const EdgeInsets.only(bottom: systemNavBar));

    final bar = t.getRect(find.byType(NavigationBar));
    expect(bar.bottom, lessThanOrEqualTo(phone.height - systemNavBar),
        reason: 'мәзір жүйелік түймелердің үстінде болуы керек');
    expect(bar.top, greaterThan(0));
  });

  testWidgets('жүйелік панель жоқ құрылғыда мәзір төменгі шетке жабыспайды', (t) async {
    t.view.physicalSize = const Size(400 * 3, 800 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);

    final state = await buildState();
    await pumpApp(t, state, EdgeInsets.zero);

    final bar = t.getRect(find.byType(NavigationBar));
    expect(bar.bottom, lessThanOrEqualTo(phone.height - 12)); // SafeArea minimum
  });

  testWidgets('тізімнің төменгі шегінісі жүйелік панельді ескереді', (t) async {
    const padded = MediaQueryData(size: phone, padding: EdgeInsets.only(bottom: systemNavBar));
    late double clearance;
    await t.pumpWidget(MediaQuery(
      data: padded,
      child: Builder(builder: (context) {
        clearance = navBarClearance(context);
        return const SizedBox();
      }),
    ));
    expect(clearance, greaterThanOrEqualTo(systemNavBar));
  });
}
