import 'package:material_ui/material_ui.dart';

import '../core/logic.dart';

class C {
  // Жарық тақырып
  static const bg = Color(0xFFF5F8F3);
  static const card = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFEDF3EB);
  static const line = Color(0xFFE3EAE0);
  static const text = Color(0xFF17231B);
  static const muted = Color(0xFF6C7D70);

  static const green = Color(0xFF2F6B4C);        // негізгі жасыл
  static const greenInk = Color(0xFF1E4A34);     // қою жасыл (мәтін)
  static const greenSoft = Color(0xFFDEEFE4);    // ашық жасыл фон
  static const greenBright = Color(0xFF49946B);

  static const amber = Color(0xFFE0A42A);
  static const amberSoft = Color(0xFFFBF1DA);
  static const amberInk = Color(0xFF8A6512);

  static const clay = Color(0xFFBE6A4C);
  static const claySoft = Color(0xFFF9E5DC);
  static const clayInk = Color(0xFF8C4728);

  // Қараңғы тақырып
  static const bgDark = Color(0xFF121711);
  static const cardDark = Color(0xFF1B211B);
  static const surface2Dark = Color(0xFF232C23);
  static const lineDark = Color(0xFF2C362D);
  static const textDark = Color(0xFFE9F0E7);
  static const mutedDark = Color(0xFF9BAA9D);
  static const greenDarkTheme = Color(0xFF5FA87C);
  static const greenSoftDark = Color(0xFF24392C);
  static const amberSoftDark = Color(0xFF3A2F17);
  static const amberInkDark = Color(0xFFF0C96A);
  static const claySoftDark = Color(0xFF3A271E);
  static const clayInkDark = Color(0xFFE8A98A);

  // Ескі атаулармен үйлесімділік
  static const greenDark = greenInk;
  static const greenLight = greenSoft;
  static const beige = surface2;
  static const warn = amber;
  static const warnBg = amberSoft;
  static const danger = clay;
  static const dangerBg = claySoft;
}

/// Қараңғы режимде түстерді ауыстыру.
Color onSurfaceMuted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? C.mutedDark : C.muted;

Color statusColor(String status) => switch (status) {
      kHealthy => C.greenInk,
      kWarning => C.amberInk,
      kCritical => C.clayInk,
      _ => C.muted,
    };

Color statusBg(String status) => switch (status) {
      kHealthy => C.greenSoft,
      kWarning => C.amberSoft,
      kCritical => C.claySoft,
      _ => C.surface2,
    };

Color barColor(String status) => switch (status) {
      kHealthy => C.greenBright,
      kWarning => C.amber,
      kCritical => C.clay,
      _ => C.muted,
    };

ThemeData buildTheme({required bool dark}) {
  final surface = dark ? C.cardDark : C.card;
  final border = dark ? C.lineDark : C.line;
  final onSurface = dark ? C.textDark : C.text;
  final primary = dark ? C.greenDarkTheme : C.green;

  final scheme = ColorScheme.fromSeed(
    seedColor: C.green,
    brightness: dark ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: primary,
    surface: dark ? C.bgDark : C.bg,
    onSurface: onSurface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? C.bgDark : C.bg,
    splashFactory: InkSparkle.splashFactory,
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: border),
      ),
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? C.bgDark : C.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 21,
        fontWeight: FontWeight.w800,
        letterSpacing: -.5,
      ),
      iconTheme: IconThemeData(color: onSurface),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: dark ? C.greenSoftDark : C.greenSoft,
      indicatorShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      height: 72,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 10.5,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? (dark ? C.textDark : C.greenInk)
              : (dark ? C.mutedDark : C.muted),
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected)
              ? primary
              : (dark ? C.mutedDark : C.muted),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      hintStyle: TextStyle(color: dark ? C.mutedDark : C.muted, fontSize: 14.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: C.greenBright, width: 1.6),
      ),
      counterStyle: TextStyle(color: dark ? C.mutedDark : C.muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: dark ? const Color(0xFF0E1A12) : Colors.white,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        foregroundColor: dark ? C.textDark : C.greenInk,
        backgroundColor: dark ? C.greenSoftDark : C.greenSoft,
        side: BorderSide.none,
        textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: primary,
      side: BorderSide(color: border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: TextStyle(color: dark ? C.mutedDark : C.muted),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? C.greenDarkTheme : C.greenInk,
      contentTextStyle: TextStyle(
        color: dark ? const Color(0xFF0E1A12) : Colors.white,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: TextStyle(
          fontSize: 14.5, fontWeight: FontWeight.w600, color: onSurface),
      subtitleTextStyle:
          TextStyle(fontSize: 12, color: dark ? C.mutedDark : C.muted),
    ),
    textTheme: Typography.material2021().black.apply(
          bodyColor: onSurface,
          displayColor: onSurface,
        ),
  );
}
