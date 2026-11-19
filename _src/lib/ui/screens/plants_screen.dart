import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/logic.dart';
import '../../core/models.dart';
import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../app.dart';
import '../format.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'add_plant_screen.dart';
import 'catalog_screen.dart';
import 'plant_detail_screen.dart';

/// Екі қойынды: «Менің өсімдіктерім» және «Анықтамалық».
class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muted = onSurfaceMuted(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(tr('plants.title'),
                    style: const TextStyle(
                        fontSize: 27, fontWeight: FontWeight.w800)),
              ),
              IconButton(
                tooltip: tr('home.addPlant'),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddPlantScreen())),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          labelColor: C.green,
          unselectedLabelColor: muted,
          indicatorColor: C.green,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: tr('plants.tabMine')),
            Tab(text: tr('plants.tabCatalog')),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _MineTab(onBrowseCatalog: () => _tabs.animateTo(1)),
              CatalogBody(bottomPadding: navBarClearance(context)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MineTab extends StatelessWidget {
  const _MineTab({required this.onBrowseCatalog});
  final VoidCallback onBrowseCatalog;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.visiblePlants;
    final muted = onSurfaceMuted(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: tr('plants.search'),
                        prefixIcon: Icon(Icons.search, color: muted),
                      ),
                      onChanged: s.setPlantQuery,
                    ),
                  ),
                  IconButton(
                    onPressed: () => s.setGridView(true),
                    icon: Icon(Icons.grid_view_rounded,
                        color: s.gridView ? C.green : muted),
                  ),
                  IconButton(
                    onPressed: () => s.setGridView(false),
                    icon: Icon(Icons.view_list_rounded,
                        color: s.gridView ? muted : C.green),
                  ),
                ],
              ),
              FilterChips(
                value: s.plantFilter,
                items: {
                  'all': tr('common.all'),
                  kHealthy: tr('status.healthy'),
                  kWarning: tr('status.warning'),
                  kCritical: tr('status.critical'),
                  kNone: tr('status.noneShort'),
                },
                onChanged: s.setPlantFilter,
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? ListView(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, navBarClearance(context)),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            const Icon(Icons.eco_outlined,
                                size: 36, color: C.greenBright),
                            const SizedBox(height: 8),
                            Text(
                                s.plants.isEmpty
                                    ? tr('plants.emptyTitle')
                                    : tr('plants.notFound'),
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700)),
                            if (s.plants.isEmpty) ...[
                              const SizedBox(height: 6),
                              Text(tr('plants.emptyText'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: muted)),
                              const SizedBox(height: 14),
                              FilledButton.icon(
                                onPressed: onBrowseCatalog,
                                icon: const Icon(Icons.menu_book_outlined, size: 20),
                                label: Text(tr('plants.fromCatalog')),
                              ),
                              TextButton(
                                onPressed: () => RootNav.openTab(context, 2),
                                child: Text(tr('home.scanBtn')),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : (s.gridView ? _Grid(list) : _List(list)),
        ),
      ],
    );
  }
}

void _open(BuildContext context, Plant p) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlantDetailScreen(plantId: p.id)),
    );

class _Grid extends StatelessWidget {
  const _Grid(this.items);
  final List<Plant> items;

  @override
  Widget build(BuildContext context) {
    final muted = onSurfaceMuted(context);
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(20, 4, 20, navBarClearance(context)),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: .72,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final p = items[i];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => _open(context, p),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  plantCover(p, height: 112, width: double.infinity),
                  const SizedBox(height: 8),
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(p.species.isEmpty ? '—' : p.species,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: muted)),
                  const SizedBox(height: 6),
                  StatusBadge(p.lastStatus ?? kNone, compact: true),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _List extends StatelessWidget {
  const _List(this.items);
  final List<Plant> items;

  @override
  Widget build(BuildContext context) {
    final muted = onSurfaceMuted(context);
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 4, 20, navBarClearance(context)),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final p = items[i];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => _open(context, p),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  plantCover(p, width: 88, height: 88),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        Text(p.species.isEmpty ? '—' : p.species,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: muted)),
                        const SizedBox(height: 6),
                        StatusBadge(p.lastStatus ?? kNone, compact: true),
                        const SizedBox(height: 6),
                        Text(
                          p.lastAt == null
                              ? tr('home.noObs')
                              : tr('home.lastObs', {'date': fmtDate(p.lastAt!)}),
                          style: TextStyle(fontSize: 11.5, color: muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
