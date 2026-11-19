import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../data/catalog.dart';
import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../app.dart';
import '../format.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'add_plant_screen.dart';
import 'catalog_screen.dart';
import 'plant_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final recent = s.observations.take(3).toList();
    final hero = s.plants.isEmpty ? null : s.plants.first;
    final muted = onSurfaceMuted(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 18, 20, navBarClearance(context)),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('home.greeting'), style: TextStyle(color: muted, fontSize: 13.5)),
            Text(tr('home.title'),
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 18),
        if (hero == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Icon(Icons.photo_camera_outlined, size: 38, color: C.greenBright),
                  const SizedBox(height: 6),
                  Text(tr('home.emptyTitle'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(tr('home.emptyText'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: muted)),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => RootNav.openTab(context, 2),
                    icon: const Icon(Icons.auto_awesome, size: 20),
                    label: Text(tr('home.scanBtn')),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const AddPlantScreen())),
                    child: Text(tr('home.addManual')),
                  ),
                ],
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => PlantDetailScreen(plantId: hero.id))),
            child: Stack(
              children: [
                plantCover(hero, height: 200, radius: 28, width: double.infinity),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF09160E).withValues(alpha: .66),
                          const Color(0xFF09160E).withValues(alpha: .10),
                          Colors.transparent,
                        ],
                        stops: const [0, .45, .7],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 16,
                  right: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hero.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(
                        hero.lastAt == null
                            ? tr('home.noObs')
                            : tr('home.lastObs', {'date': fmtDate(hero.lastAt!)}),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (hero != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              StatCard('${s.plants.length}', tr('home.statTotal')),
              const SizedBox(width: 12),
              StatCard('${s.healthyCount}', tr('home.statHealthy'), color: C.green),
              const SizedBox(width: 12),
              StatCard('${s.attentionCount}', tr('home.statAttention'),
                  color: C.danger),
            ],
          ),
        ],
        if (recent.isNotEmpty) ...[
          SectionTitle(tr('home.recent')),
          ...recent.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => o.plantId == null
                        ? RootNav.openTab(context, 3)
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PlantDetailScreen(plantId: o.plantId!))),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          PlantPhoto(
                              thumb: o.thumb, seed: o.plantId ?? o.id, width: 62, height: 62, radius: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    o.plantId == null
                                        ? (o.ai?.diagnosis ?? tr('diary.unassigned'))
                                        : o.plantName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(fmtDate(o.takenAt),
                                    style: TextStyle(color: muted, fontSize: 12.5)),
                                const SizedBox(height: 6),
                                StatusBadge(o.status, compact: true),
                              ],
                            ),
                          ),
                          Text('${o.greenPct.toStringAsFixed(0)}%',
                              style: const TextStyle(color: C.green, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
        SectionTitle(
          tr('home.popular'),
          trailing: TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CatalogScreen())),
            child: Text(tr('home.seeAll')),
          ),
        ),
        const PopularStrip(),
      ],
    );
  }
}

/// «Қызылордада танымал» — анықтамалықтан көлденең карточкалар.
class PopularStrip extends StatelessWidget {
  const PopularStrip({super.key});

  static const _ids = ['tagetes', 'portulaca', 'rose', 'pelargonium', 'aloe', 'elaeagnus', 'saxaul', 'licorice'];

  @override
  Widget build(BuildContext context) {
    final items = [for (final id in _ids) ...catalog.where((c) => c.id == id)];
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = items[i];
          return SizedBox(
            width: 128,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CatalogDetailScreen(plant: c))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlantPhoto(thumb: null, seed: i, asset: c.image, height: 100, radius: 0, width: 128),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                      child: Text(c.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.25)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
