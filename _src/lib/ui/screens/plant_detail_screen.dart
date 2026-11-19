import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/ai.dart';
import '../../core/logic.dart';
import '../../core/models.dart';
import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../format.dart';
import '../theme.dart';
import '../widgets/ai_card.dart';
import '../widgets/common.dart';
import 'analyze_screen.dart';

class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key, required this.plantId});
  final int plantId;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final muted = onSurfaceMuted(context);
    Plant? found;
    for (final p in s.plants) {
      if (p.id == plantId) {
        found = p;
        break;
      }
    }
    if (found == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(tr('det.notFound'))),
      );
    }
    final plant = found;
    final history = s.observationsOf(plantId); // хронологиялық (ескіден жаңаға)
    final greens = history.map((o) => o.greenPct).toList();
    final status = plant.lastStatus ?? kNone;
    (Observation, AiAnalysis)? lastAi;
    for (final o in history.reversed) {
      final a = o.ai;
      if (a != null) {
        lastAi = (o, a);
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(plant.name)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            plantCover(plant, height: 240, radius: 28, width: double.infinity),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plant.name,
                              style: const TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w800)),
                          Text(plant.species.isEmpty ? '—' : plant.species,
                              style: TextStyle(color: muted, fontSize: 13)),
                        ],
                      ),
                    ),
                    StatusBadge(status),
                  ],
                ),
              ),
            ),
            SectionTitle(tr('det.about')),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(tr('det.location'),
                        plant.location.isEmpty ? '—' : plant.location),
                    _Row(tr('det.added'), fmtDate(plant.createdAt)),
                    _Row(tr('det.scans'), '${plant.obsCount}'),
                    _Row(tr('det.lastObs'),
                        plant.lastAt == null ? '—' : fmtDateTime(plant.lastAt!)),
                    _Row(tr('det.trend'), tr('trend.${trend(greens)}')),
                  ],
                ),
              ),
            ),
            SectionTitle(tr('det.chart')),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: history.isEmpty
                    ? Text(tr('det.noAi'), style: TextStyle(color: muted))
                    : SizedBox(
                        height: 120,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: history
                              .sublist(history.length > 8 ? history.length - 8 : 0)
                              .map((o) => Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 4),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(o.greenPct.toStringAsFixed(0),
                                              style: TextStyle(
                                                  fontSize: 10, color: muted)),
                                          const SizedBox(height: 4),
                                          Container(
                                            height: (o.greenPct * 0.8)
                                                .clamp(6, 80)
                                                .toDouble(),
                                            decoration: BoxDecoration(
                                              color: barColor(o.status),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(shortDate(o.takenAt),
                                              style: TextStyle(
                                                  fontSize: 9, color: muted)),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
              ),
            ),
            if (lastAi != null) ...[
              SectionTitle(tr('ai.adviceTitle')),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AiTag(fmtDate(lastAi.$1.takenAt)),
                          Text('${lastAi.$2.healthScore}/100',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, color: muted)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(lastAi.$2.diagnosis,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      if (lastAi.$2.summary.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(lastAi.$2.summary,
                            style: TextStyle(fontSize: 13, color: muted)),
                      ],
                      ...lastAi.$2.advice
                          .asMap()
                          .entries
                          .map((e) => BulletItem(e.value, number: e.key + 1)),
                      if (lastAi.$2.prognosis.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(tr('ai.prognosis'),
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: C.greenInk)),
                        const SizedBox(height: 4),
                        Text(lastAi.$2.prognosis,
                            style: const TextStyle(fontSize: 13.5)),
                      ],
                      if (lastAi.$2.isPlant) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: C.greenSoft,
                              borderRadius: BorderRadius.circular(14)),
                          child: Row(children: [
                            const Icon(Icons.event_outlined,
                                size: 18, color: C.greenInk),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tr('ai.nextCheckDate', {
                                  'date': fmtDate(lastAi.$1.takenAt.add(
                                      Duration(days: lastAi.$2.nextCheckDays)))
                                }),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: C.greenInk),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (lastAi.$2.hasPlantInfo) ...[
                SectionTitle(tr('ai.plantInfo')),
                PlantInfoCard(lastAi.$2.plantInfo),
              ],
              if (lastAi.$2.hasCare) ...[
                SectionTitle(tr('ai.care')),
                CareGrid(lastAi.$2.care),
              ],
            ],
            SectionTitle(tr('det.history')),
            if (history.isEmpty)
              EmptyBox(tr('diary.empty'))
            else
              ...history.reversed.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            PlantPhoto(
                                thumb: o.thumb,
                                seed: o.plantId ?? o.id,
                                width: 56,
                                height: 56,
                                radius: 14),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fmtDateTime(o.takenAt),
                                      style: TextStyle(
                                          fontSize: 12.5, color: muted)),
                                  const SizedBox(height: 4),
                                  StatusBadge(o.status, compact: true),
                                  if (o.note.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(o.note,
                                        style: const TextStyle(fontSize: 13)),
                                  ],
                                ],
                              ),
                            ),
                            Text('${o.greenPct.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: C.green,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  )),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AnalyzeScreen(plantId: plant.id)),
              ),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(tr('det.newScan')),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(tr('det.delete')),
                    content: Text(tr('det.deleteText')),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(tr('common.cancel'))),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(tr('common.delete'))),
                    ],
                  ),
                );
                if (ok == true) {
                  await context.read<AppState>().deletePlant(plant.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: Text(tr('det.delete')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: const Color(0xFF7C4C30),
                backgroundColor: C.dangerBg,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13, color: onSurfaceMuted(context))),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
