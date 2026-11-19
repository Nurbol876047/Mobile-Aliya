import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../state/app_state.dart';
import 'screens/analyze_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/plants_screen.dart';
import 'screens/profile_screen.dart';
import 'theme.dart';
import 'widgets/phone_frame.dart';

class FloraCareApp extends StatelessWidget {
  const FloraCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.select<AppState, bool>((s) => s.dark);
    final seen = context.select<AppState, bool>((s) => s.seenOnboarding);
    final lang = context.select<AppState, Lang>((s) => s.lang);
    return MaterialApp(
      // Тіл ауысқанда бүкіл интерфейс жаңа тілде қайта сызылады
      key: ValueKey(lang),
      title: 'FloraCare',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(dark: false),
      darkTheme: buildTheme(dark: true),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => PhoneFrame(child: child ?? const SizedBox()),
      home: seen
          ? RootNav(initialIndex: context.read<AppState>().navIndex)
          : const OnboardingScreen(),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<RootNav> createState() => RootNavState();

  /// Басқа экрандардан қойындыны ауыстыру үшін.
  static void openTab(BuildContext context, int index) {
    context.findAncestorStateOfType<RootNavState>()?.select(index);
  }
}

class RootNavState extends State<RootNav> {
  late int _index = widget.initialIndex;

  void select(int index) {
    context.read<AppState>().setNavIndex(index);
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true, // мазмұн қалқымалы мәзірдің астынан да көрінеді
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            PlantsScreen(),
            AnalyzeScreen(),
            DiaryScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      // Қалқымалы мәзір: жүйелік «артқа/үй» түймелерінің ҮСТІНДЕ (SafeArea + 12 px)
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: dark ? C.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: dark ? C.lineDark : C.line),
            boxShadow: const [
              BoxShadow(color: Color(0x1F17231B), blurRadius: 24, offset: Offset(0, 8)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: NavigationBar(
              height: 66,
              backgroundColor: Colors.transparent,
              selectedIndex: _index,
              onDestinationSelected: select,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home),
                    label: tr('nav.home')),
                NavigationDestination(
                    icon: const Icon(Icons.eco_outlined),
                    selectedIcon: const Icon(Icons.eco),
                    label: tr('nav.plants')),
                NavigationDestination(
                    icon: const Icon(Icons.center_focus_strong_outlined),
                    selectedIcon: const Icon(Icons.center_focus_strong),
                    label: tr('nav.scan')),
                NavigationDestination(
                    icon: const Icon(Icons.history),
                    selectedIcon: const Icon(Icons.history_toggle_off),
                    label: tr('nav.diary')),
                NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person),
                    label: tr('nav.profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Тізім экрандарының төменгі шегінісі — мазмұн қалқымалы мәзірдің астында қалмауы үшін.
/// (extendBody: true болғанда Scaffold мәзір биіктігін padding.bottom-ке қосады.)
double navBarClearance(BuildContext context) => MediaQuery.of(context).padding.bottom + 16;
