import 'package:material_ui/material_ui.dart';

import '../../core/ai.dart';
import '../../l10n/l10n.dart';
import '../theme.dart';
import 'common.dart';

/// Gemini қорытындысы: денсаулық сақинасы, диагноз, белгілер, себептер, кеңестер.
class AiCard extends StatelessWidget {
  const AiCard(this.ai, {super.key});
  final AiAnalysis ai;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _main(context),
        if (ai.hasPlantInfo) ...[
          SectionTitle(tr('ai.plantInfo')),
          PlantInfoCard(ai.plantInfo),
        ],
        if (ai.hasCare) ...[
          SectionTitle(tr('ai.care')),
          CareGrid(ai.care),
        ],
      ],
    );
  }

  Widget _main(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AiTag(tr('ai.tag')),
                      const SizedBox(height: 8),
                      Text(
                        ai.diagnosis.isEmpty ? tr('scan.result') : ai.diagnosis,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.3),
                      ),
                      if (ai.plantName.isNotEmpty)
                        Text(ai.plantName,
                            style: TextStyle(
                                fontSize: 12.5, color: onSurfaceMuted(context))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                HealthRing(score: ai.healthScore, color: barColor(ai.status)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(ai.status),
                _Chip(ai.urgencyLabel),
                if (ai.isPlant) _Chip(tr('ai.nextCheck', {'n': ai.nextCheckDays})),
              ],
            ),
            if (!ai.isPlant || ai.photoQualityNote.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: C.amberInk),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ai.photoQualityNote.isNotEmpty
                          ? ai.photoQualityNote
                          : tr('ai.noPlant'),
                      style: const TextStyle(fontSize: 13, color: C.amberInk),
                    ),
                  ),
                ],
              ),
            ],
            if (ai.summary.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(ai.summary, style: const TextStyle(fontSize: 14, height: 1.5)),
            ],
            _Label(tr('ai.colorTitle')),
            PercentBar(tr('ai.green'), ai.greenPct, C.greenBright),
            PercentBar(tr('ai.yellow'), ai.yellowPct, C.amber),
            PercentBar(tr('ai.brown'), ai.brownPct, C.clay),
            if (ai.colorExplanation.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(ai.colorExplanation,
                  style: TextStyle(
                      fontSize: 13, height: 1.5, color: onSurfaceMuted(context))),
            ],
            if (ai.symptoms.isNotEmpty) ...[
              _Label(tr('ai.symptoms')),
              ...ai.symptoms.map((t) => BulletItem(t)),
            ],
            if (ai.causes.isNotEmpty) ...[
              _Label(tr('ai.causes')),
              ...ai.causes.map((t) => BulletItem(t)),
            ],
            if (ai.advice.isNotEmpty) ...[
              _Label(tr('ai.advice')),
              ...ai.advice.asMap().entries.map((e) => BulletItem(e.value, number: e.key + 1)),
            ],
            if (ai.prognosis.isNotEmpty) ...[
              _Label(tr('ai.prognosis')),
              const SizedBox(height: 6),
              Text(ai.prognosis, style: const TextStyle(fontSize: 13.5, height: 1.5)),
            ],
            const SizedBox(height: 14),
            Text(
              tr('ai.confidence', {'p': (ai.confidence * 100).round()}) +
                  (ai.ms > 0 ? ' · ${(ai.ms / 1000).toStringAsFixed(1)} s' : ''),
              style: TextStyle(fontSize: 11.5, color: onSurfaceMuted(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class AiLoadingCard extends StatelessWidget {
  const AiLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: C.green),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('ai.analyzing'),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(tr('ai.usually'),
                      style: TextStyle(fontSize: 12.5, color: onSurfaceMuted(context))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiErrorCard extends StatelessWidget {
  const AiErrorCard(this.message, {super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: C.amberSoft,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('ai.failed'),
                style: const TextStyle(fontWeight: FontWeight.w700, color: C.amberInk)),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontSize: 13, color: C.amberInk)),
            if (onRetry != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: onRetry, child: Text(tr('common.retry'))),
              ),
          ],
        ),
      ),
    );
  }
}

class HealthRing extends StatelessWidget {
  const HealthRing({super.key, required this.score, required this.color});
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
            color: color,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? C.surface2Dark
                : C.surface2,
          ),
          Center(
            child: Text('$score',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -.5)),
          ),
        ],
      ),
    );
  }
}

class AiTag extends StatelessWidget {
  const AiTag(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? C.greenSoftDark : C.greenSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 12, color: dark ? C.greenDarkTheme : C.green),
          const SizedBox(width: 5),
          Text(text.toUpperCase(),
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                  color: dark ? C.greenDarkTheme : C.green)),
        ],
      ),
    );
  }
}

class BulletItem extends StatelessWidget {
  const BulletItem(this.text, {super.key, this.number});
  final String text;
  final int? number;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dark ? C.greenSoftDark : C.greenSoft,
              shape: BoxShape.circle,
            ),
            child: Text(number == null ? '•' : '$number',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: dark ? C.greenDarkTheme : C.green)),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.45))),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(text,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? C.textDark
                    : C.greenInk)),
      );
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? C.surface2Dark
              : C.surface2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: onSurfaceMuted(context))),
      );
}

/// «Өсімдік туралы»: латынша атауы, тұқымдасы, отаны, сипаттама, уыттылығы, қызықты дерек.
class PlantInfoCard extends StatelessWidget {
  const PlantInfoCard(this.info, {super.key});
  final Map<String, String> info;

  @override
  Widget build(BuildContext context) {
    final muted = onSurfaceMuted(context);
    Widget row(String k, String? v) => (v == null || v.isEmpty)
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 110, child: Text(k, style: TextStyle(fontSize: 13, color: muted))),
                Expanded(
                    child: Text(v,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
              ],
            ),
          );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            row(tr('cat.latin'), info['latin_name']),
            row(tr('cat.family'), info['family']),
            row(tr('ai.origin'), info['origin']),
            if ((info['description'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(info['description']!, style: const TextStyle(fontSize: 13.5, height: 1.55)),
            ],
            if ((info['toxicity'] ?? '').isNotEmpty)
              _Note(Icons.warning_amber_rounded, tr('cat.toxicity'), info['toxicity']!,
                  C.amberSoft, C.amberInk),
            if ((info['fun_fact'] ?? '').isNotEmpty)
              _Note(Icons.lightbulb_outline, tr('ai.funFact'), info['fun_fact']!,
                  C.greenSoft, C.greenInk),
          ],
        ),
      ),
    );
  }
}

/// «Күтім талаптары» — 2 бағанды тор.
class CareGrid extends StatelessWidget {
  const CareGrid(this.care, {super.key});
  final Map<String, String> care;

  static const _icons = {
    'light': Icons.wb_sunny_outlined,
    'watering': Icons.water_drop_outlined,
    'temperature': Icons.thermostat_outlined,
    'humidity': Icons.air,
    'soil': Icons.grass,
    'fertilizer': Icons.science_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final items = careKeys.where((k) => (care[k] ?? '').isNotEmpty).toList();
    return LayoutBuilder(builder: (context, c) {
      final w = (c.maxWidth - 10) / 2;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final k in items)
            SizedBox(
              width: w,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(_icons[k], size: 18, color: C.greenBright),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(tr('care.$k'),
                              softWrap: true,
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w700, color: C.greenInk)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Text(care[k]!, style: const TextStyle(fontSize: 12.5, height: 1.45)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _Note extends StatelessWidget {
  const _Note(this.icon, this.title, this.text, this.bg, this.fg);
  final IconData icon;
  final String title;
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
            ]),
            const SizedBox(height: 4),
            Text(text, style: TextStyle(fontSize: 13, height: 1.45, color: fg)),
          ],
        ),
      );
}
