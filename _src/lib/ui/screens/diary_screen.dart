import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/ai.dart';
import '../../core/logic.dart';
import '../../core/models.dart';
import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../app.dart';
import '../format.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'plant_detail_screen.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.visibleObservations;
    final muted = onSurfaceMuted(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('diary.title'),
                  style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: tr('diary.search'),
                  prefixIcon: Icon(Icons.search, color: muted),
                ),
                onChanged: s.setDiaryQuery,
              ),
              FilterChips(
                value: s.diaryFilter,
                items: {
                  'all': tr('common.all'),
                  kHealthy: tr('status.healthy'),
                  kWarning: tr('status.warning'),
                  kCritical: tr('status.critical'),
                },
                onChanged: s.setDiaryFilter,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: s.diarySort,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                      items: sortKeys
                          .map((k) => DropdownMenuItem(
                                value: k,
                                child: Text(
                                    tr('sort.prefix', {'x': tr('sort.$k')}),
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (v) => s.setDiarySort(v ?? 'date'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: s.diaryDays ?? 0,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: 0,
                            child: Text(tr('period.all'),
                                style: const TextStyle(fontSize: 13))),
                        DropdownMenuItem(
                            value: 7,
                            child: Text(tr('period.7'),
                                style: const TextStyle(fontSize: 13))),
                        DropdownMenuItem(
                            value: 30,
                            child: Text(tr('period.30'),
                                style: const TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) =>
                          s.setDiaryDays(v == null || v == 0 ? null : v),
                    ),
                  ),
                  IconButton(
                    tooltip: s.diaryDesc ? tr('order.desc') : tr('order.asc'),
                    onPressed: () => s.setDiaryDesc(!s.diaryDesc),
                    icon: Icon(
                        s.diaryDesc ? Icons.arrow_downward : Icons.arrow_upward),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: EmptyBox(tr('diary.empty'),
                      icon: Icons.menu_book_outlined),
                )
              : ListView.separated(
                  padding:
                      EdgeInsets.fromLTRB(20, 10, 20, navBarClearance(context)),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _ScanCard(list[i]),
                ),
        ),
      ],
    );
  }
}

/// Тарихтағы бір скан. Өсімдікке тіркелмеген скан да сақталады.
class _ScanCard extends StatelessWidget {
  const _ScanCard(this.o);
  final Observation o;

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final muted = onSurfaceMuted(context);
    final ai = o.ai;
    final title = o.plantId != null
        ? o.plantName
        : (ai != null && ai.diagnosis.isNotEmpty
            ? ai.diagnosis
            : tr('diary.unassigned'));

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: o.plantId == null
            ? () => _assign(context, o)
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PlantDetailScreen(plantId: o.plantId!)),
                ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PlantPhoto(
                      thumb: o.thumb,
                      seed: o.plantId ?? o.id,
                      width: 70,
                      height: 70,
                      radius: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(fmtDateTime(o.takenAt),
                            style: TextStyle(color: muted, fontSize: 12.5)),
                        const SizedBox(height: 6),
                        StatusBadge(o.status, compact: true),
                        if (o.plantId == null) ...[
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _assign(context, o),
                            child: Row(children: [
                              const Icon(Icons.link, size: 14, color: C.greenBright),
                              const SizedBox(width: 4),
                              Text(tr('diary.assign'),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: C.greenBright)),
                            ]),
                          ),
                        ] else if (ai != null && ai.diagnosis.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.auto_awesome,
                                size: 13, color: C.greenBright),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(ai.diagnosis,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TextStyle(fontSize: 12, color: muted)),
                            ),
                          ]),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: tr('diary.deleteTitle'),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(tr('diary.deleteTitle')),
                          content: Text(tr('diary.deleteText')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(tr('common.cancel')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(tr('common.delete')),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) await s.deleteObservation(o.id);
                    },
                    icon: Icon(Icons.delete_outline, color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Pct(tr('ai.green'), o.greenPct, C.green),
                  _Pct(tr('ai.yellow'), o.yellowPct, C.warn),
                  _Pct(tr('ai.brown'), o.brownPct, C.danger),
                ],
              ),
              if (o.note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(o.note, style: TextStyle(fontSize: 13.5, color: muted)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Сканды бар өсімдікке тіркеу немесе ЖИ анықтаған атаумен жаңа өсімдік ашу.
Future<void> _assign(BuildContext context, Observation o) async {
  final s = context.read<AppState>();
  final choice = await showDialog<int?>(
    context: context,
    builder: (_) => SimpleDialog(
      title: Text(tr('scan.assignTitle')),
      children: [
        ...s.plants.map((p) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, p.id),
              child: Text(p.name),
            )),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, -1),
          child: Text(tr('scan.newPlant'),
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  if (choice == null) return;
  var plantId = choice;
  if (plantId == -1) {
    final guess = plantGuess(o.ai);
    final name = guess.name.isEmpty ? tr('home.addPlant') : guess.name;
    plantId = await s.addPlant(name, guess.species, '');
  }
  await s.attachObservation(o.id, plantId);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(tr('scan.assigned'))));
}

class _Pct extends StatelessWidget {
  const _Pct(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text('$label ${value.toStringAsFixed(0)}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12, color: onSurfaceMuted(context))),
            ),
          ],
        ),
      );
}
