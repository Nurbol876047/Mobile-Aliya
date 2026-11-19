import 'dart:convert';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../core/logic.dart';
import '../../core/models.dart';
import '../../data/catalog.dart';
import '../../l10n/l10n.dart';
import '../theme.dart';

/// Күй белгісі (Дені сау / Назар аудару керек / Қауіпті жағдай).
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.compact = false});
  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusBg(status),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            tr(statusSeverity.containsKey(status) ? 'status.$status' : 'status.none'),
            style: TextStyle(
              fontSize: compact ? 11 : 11.5,
              fontWeight: FontWeight.w600,
              color: statusColor(status),
            ),
          ),
        ],
      ),
    );
  }
}

/// Фото немесе фото болмаса — жасыл градиент (прототиптегідей).
class PlantPhoto extends StatelessWidget {
  const PlantPhoto({
    super.key,
    required this.thumb,
    required this.seed,
    this.asset,
    this.width,
    this.height = 118,
    this.radius = 18,
  });

  final String? thumb;
  final int seed;

  /// Анықтамалық суреті (скан фотосы жоқ болса көрсетіледі).
  final String? asset;
  final double? width;
  final double height;
  final double radius;

  static const _gradients = [
    [Color(0xFF64A379), Color(0xFF24543A)],
    [Color(0xFF8CBB97), Color(0xFF3C7152)],
    [Color(0xFFA9CBA4), Color(0xFF54855F)],
    [Color(0xFF4F8A64), Color(0xFF1C3F2B)],
  ];

  @override
  Widget build(BuildContext context) {
    final radiusGeom = BorderRadius.circular(radius);
    if (thumb != null && thumb!.isNotEmpty) {
      Uint8List? bytes;
      try {
        bytes = base64Decode(thumb!);
      } catch (_) {
        bytes = null;
      }
      if (bytes != null) {
        return ClipRRect(
          borderRadius: radiusGeom,
          child: Image.memory(
            bytes,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    if (asset != null) {
      return ClipRRect(
        borderRadius: radiusGeom,
        child: Image.asset(asset!, width: width, height: height, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(radiusGeom)),
      );
    }
    return _placeholder(radiusGeom);
  }

  Widget _placeholder(BorderRadius radiusGeom) {
    final g = _gradients[seed.abs() % _gradients.length];
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radiusGeom,
        gradient: LinearGradient(
          colors: g,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.spa_outlined,
          color: Colors.white.withValues(alpha: .22),
          size: height < 80 ? 26 : 48,
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard(this.value, this.label, {super.key, this.color});
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 2),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: C.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Пайызды көрсететін жолақ (жасыл / сары / қоңыр).
class PercentBar extends StatelessWidget {
  const PercentBar(this.label, this.value, this.color, {super.key});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: C.muted)),
              Text('${value.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0, 1),
              minHeight: 10,
              backgroundColor: C.beige,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Ұзын тақырып (орысша/ағылшынша) тар экранда шығып кетпеуі үшін
          Expanded(
            child: Text(text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class EmptyBox extends StatelessWidget {
  const EmptyBox(this.text, {super.key, this.icon = Icons.eco_outlined});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          children: [
            Icon(icon, color: C.muted, size: 32),
            const SizedBox(height: 10),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: C.muted, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}

/// Сүзгі «чиптері».
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 7),
        children: items.entries.map((e) {
          final on = e.key == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.value),
              selected: on,
              onSelected: (_) => onChanged(e.key),
              showCheckmark: false,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                color: on ? Colors.white : C.muted,
              ),
              selectedColor: C.green,
              backgroundColor: Theme.of(context).cardTheme.color,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Өсімдіктің мұқабасы: соңғы скан фотосы → анықтамалық суреті → градиент.
PlantPhoto plantCover(Plant p, {double? width, double height = 118, double radius = 18}) {
  String? asset;
  if (p.catalogId != null) {
    for (final c in catalog) {
      if (c.id == p.catalogId) asset = c.image;
    }
  }
  return PlantPhoto(
      thumb: p.lastThumb, seed: p.id, asset: asset, width: width, height: height, radius: radius);
}
