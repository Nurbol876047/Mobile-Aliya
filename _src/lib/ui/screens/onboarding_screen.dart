import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../app.dart';
import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  static const _slides = [
    (
      'onb.t1',
      'onb.d1',
      [Color(0xFF6E9A6A), Color(0xFF294B35)],
    ),
    (
      'onb.t2',
      'onb.d2',
      [Color(0xFF8FB08A), Color(0xFF3F6A49)],
    ),
    (
      'onb.t3',
      'onb.d3',
      [Color(0xFF5D8A63), Color(0xFF1F3D2A)],
    ),
  ];

  Future<void> _finish() async {
    await context.read<AppState>().finishOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RootNav()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_step];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('FloraCare',
                      style: TextStyle(
                          color: C.greenDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  TextButton(
                    onPressed: _finish,
                    child: Text(tr('onb.skip'),
                        style: const TextStyle(color: C.muted)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    gradient: LinearGradient(
                      colors: slide.$3,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.spa, size: 96, color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 8,
                    width: i == _step ? 26 : 8,
                    decoration: BoxDecoration(
                      color: i == _step ? C.green : C.beige,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(tr(slide.$1),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(tr(slide.$2),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: C.muted, fontSize: 13.5)),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () {
                  if (_step < _slides.length - 1) {
                    setState(() => _step++);
                  } else {
                    _finish();
                  }
                },
                child: Text(tr(_step == _slides.length - 1 ? 'onb.start' : 'onb.next')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
