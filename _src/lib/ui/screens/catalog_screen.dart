import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../data/catalog.dart';
import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../theme.dart';
import '../widgets/ai_card.dart';
import '../widgets/common.dart';
import 'plant_detail_screen.dart';

String categoryLabel(CatalogCategory c, {bool long = false}) => tr(switch (c) {
      CatalogCategory.indoor => long ? 'cat.indoorLong' : 'cat.indoor',
      CatalogCategory.garden => long ? 'cat.gardenLong' : 'cat.garden',
      CatalogCategory.native => long ? 'cat.nativeLong' : 'cat.native',
    });

/// Анықтамалық бөлек бет ретінде (басты беттен «Барлығы»).
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(tr('plants.tabCatalog'))),
        body: SafeArea(top: false, child: const CatalogBody()),
      );
}

/// Іздеу + санат сүзгісі + суретті тор.
class CatalogBody extends StatefulWidget {
  const CatalogBody({super.key, this.bottomPadding = 20});
  final double bottomPadding;

  @override
  State<CatalogBody> createState() => _CatalogBodyState();
}

class _CatalogBodyState extends State<CatalogBody> {
  String _q = '';
  CatalogCategory? _cat;

  @override
  Widget build(BuildContext context) {
    final items = catalog.where((c) => (_cat == null || c.category == _cat) && c.matches(_q)).toList();
    final muted = onSurfaceMuted(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          sliver: SliverList.list(children: [
            Text(tr('cat.title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(tr('cat.subtitle', {'n': catalog.length}), style: TextStyle(fontSize: 12.5, color: muted)),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: tr('cat.search'),
                prefixIcon: const Icon(Icons.search, color: C.muted),
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
            FilterChips(
              value: _cat?.name ?? 'all',
              items: {
                'all': tr('common.all'),
                for (final c in CatalogCategory.values) c.name: categoryLabel(c),
              },
              onChanged: (v) => setState(() =>
                  _cat = v == 'all' ? null : CatalogCategory.values.byName(v)),
            ),
          ]),
        ),
        if (items.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(child: EmptyBox(tr('cat.notFound'), icon: Icons.search_off)),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, widget.bottomPadding),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .74,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => CatalogTile(items[i]),
            ),
          ),
      ],
    );
  }
}

class CatalogTile extends StatelessWidget {
  const CatalogTile(this.plant, {super.key});
  final CatalogPlant plant;

  @override
  Widget build(BuildContext context) {
    final muted = onSurfaceMuted(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => CatalogDetailScreen(plant: plant))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PlantPhoto(
                  thumb: null, seed: plant.id.hashCode, asset: plant.image,
                  width: double.infinity, height: double.infinity, radius: 0),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(plant.latin,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: muted, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 6),
                  _CategoryChip(plant.category),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(this.c);
  final CatalogCategory c;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (c) {
      CatalogCategory.indoor => (C.greenSoft, C.greenInk),
      CatalogCategory.garden => (C.amberSoft, C.amberInk),
      CatalogCategory.native => (C.claySoft, C.clayInk),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(categoryLabel(c),
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

/// Анықтамалықтағы өсімдіктің толық беті.
class CatalogDetailScreen extends StatelessWidget {
  const CatalogDetailScreen({super.key, required this.plant});
  final CatalogPlant plant;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final mine = s.plantForCatalog(plant.id);
    final muted = onSurfaceMuted(context);
    final credit = plant.credit;

    return Scaffold(
      appBar: AppBar(title: Text(plant.title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            PlantPhoto(
                thumb: null, seed: plant.id.hashCode, asset: plant.image,
                height: 260, radius: 28, width: double.infinity),
            if (credit != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  tr('cat.photo', {'author': credit.author, 'license': credit.license}),
                  style: TextStyle(fontSize: 10.5, color: muted),
                ),
              ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plant.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(plant.latin,
                        style: TextStyle(fontSize: 13.5, color: muted, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _CategoryChip(plant.category),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? C.surface2Dark : C.surface2,
                            borderRadius: BorderRadius.circular(99)),
                        child: Text('${tr('cat.family')}: ${plant.family}',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: muted)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            SectionTitle(tr('cat.about')),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(plant.about, style: const TextStyle(fontSize: 14, height: 1.55)),
              ),
            ),
            SectionTitle(tr('cat.inKyzylorda')),
            Card(
              color: C.greenSoft,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, color: C.greenInk, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(plant.localTip,
                          style: const TextStyle(fontSize: 13.5, height: 1.5, color: C.greenInk)),
                    ),
                  ],
                ),
              ),
            ),
            SectionTitle(tr('cat.care')),
            CareGrid(plant.care),
            SectionTitle(tr('cat.toxicity')),
            Card(
              color: C.amberSoft,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, color: C.amberInk, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(plant.tox, style: const TextStyle(fontSize: 13.5, color: C.amberInk))),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            if (mine != null)
              OutlinedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PlantDetailScreen(plantId: mine.id))),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(tr('cat.alreadyMine')),
              )
            else
              FilledButton.icon(
                onPressed: () async {
                  final id = await context
                      .read<AppState>()
                      .addPlant(plant.title, plant.latin, '', catalogId: plant.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(tr('cat.added'))));
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => PlantDetailScreen(plantId: id)));
                },
                icon: const Icon(Icons.add),
                label: Text(tr('cat.addToMine')),
              ),
          ],
        ),
      ),
    );
  }
}
