import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Кең экранда (браузер/десктоп) қолданбаны телефон корпусының ішінде көрсетеді
/// және Android жүйелік панельдерін имитациялайды: жоғарыда күй жолағы, төменде
/// «артқа / үй / соңғылар» түймелері. Қолданба SafeArea арқылы оларға тимейді.
/// Нақты телефонда (ені < 600) ешнәрсе өзгермейді — жүйе өз панельдерін береді.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});
  final Widget child;

  static const double _width = 400;
  static const double _bezel = 8;
  static const double _statusBar = 30;
  static const double _navBar = 44;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (mq.size.width < 600) return child;

    final dark = Theme.of(context).brightness == Brightness.dark;
    final height = math.min(mq.size.height - 32, 860.0);
    final inner = Size(_width - _bezel * 2, height - _bezel * 2);
    const insets = EdgeInsets.only(top: _statusBar, bottom: _navBar);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -1.1),
          radius: 1.3,
          colors: dark
              ? const [Color(0xFF1A2119), Color(0xFF0C100B)]
              : const [Color(0xFFE8F0E5), Color(0xFFCFDCCB)],
        ),
      ),
      child: Center(
        child: Container(
          width: _width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF151A16),
            borderRadius: BorderRadius.circular(46),
            boxShadow: const [
              BoxShadow(color: Color(0x5E0C160F), blurRadius: 80, offset: Offset(0, 34)),
            ],
          ),
          padding: const EdgeInsets.all(_bezel),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: Stack(
              children: [
                MediaQuery(
                  data: mq.copyWith(size: inner, padding: insets, viewPadding: insets),
                  child: child,
                ),
                Positioned(
                  top: 0, left: 0, right: 0, height: _statusBar,
                  child: IgnorePointer(child: _StatusBar(dark: dark)),
                ),
                const Positioned(
                  bottom: 0, left: 0, right: 0, height: _navBar,
                  child: IgnorePointer(child: _SystemNavBar()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final c = dark ? Colors.white : const Color(0xFF17231B);
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 8, 22, 0),
      child: Row(
        children: [
          Text('12:30', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c)),
          const Spacer(),
          Icon(Icons.signal_cellular_alt, size: 14, color: c),
          const SizedBox(width: 4),
          Icon(Icons.wifi, size: 14, color: c),
          const SizedBox(width: 4),
          Icon(Icons.battery_5_bar, size: 15, color: c),
        ],
      ),
    );
  }
}

/// Android 3-түймелі навигация жолағы (артқа · үй · соңғылар).
class _SystemNavBar extends StatelessWidget {
  const _SystemNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xE6101410),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white70),
          Icon(Icons.circle_outlined, size: 18, color: Colors.white70),
          Icon(Icons.crop_square, size: 18, color: Colors.white70),
        ],
      ),
    );
  }
}
