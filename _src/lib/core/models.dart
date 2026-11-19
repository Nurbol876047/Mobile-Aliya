/// Деректер моделі: UI-дан да, дерекқордан да тәуелсіз қарапайым кластар.
library;
import 'ai.dart';

class Plant {
  final int id;
  final String name;
  final String species;
  final String location;
  final DateTime createdAt;

  /// Анықтамалықтағы өсімдік id-і (қосылса — мұқаба суреті сонан).
  final String? catalogId;

  /// Соңғы бақылаудан алынған қосымша мәліметтер (тізім экрандарына).
  final String? lastStatus;
  final String? lastThumb;
  final DateTime? lastAt;
  final int obsCount;

  const Plant({
    required this.id,
    required this.name,
    this.species = '',
    this.location = '',
    required this.createdAt,
    this.catalogId,
    this.lastStatus,
    this.lastThumb,
    this.lastAt,
    this.obsCount = 0,
  });

  Plant copyWith({
    String? lastStatus,
    String? lastThumb,
    DateTime? lastAt,
    int? obsCount,
  }) =>
      Plant(
        id: id,
        name: name,
        species: species,
        location: location,
        createdAt: createdAt,
        catalogId: catalogId,
        lastStatus: lastStatus ?? this.lastStatus,
        lastThumb: lastThumb ?? this.lastThumb,
        lastAt: lastAt ?? this.lastAt,
        obsCount: obsCount ?? this.obsCount,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'species': species,
        'location': location,
        'created_at': createdAt.toIso8601String(),
        'catalog_id': catalogId,
      };

  factory Plant.fromMap(Map<String, Object?> m) => Plant(
        id: (m['id'] as num).toInt(),
        name: m['name'] as String,
        species: (m['species'] ?? '') as String,
        location: (m['location'] ?? '') as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        catalogId: m['catalog_id'] as String?,
        lastStatus: m['last_status'] as String?,
        lastThumb: m['last_thumb'] as String?,
        lastAt: m['last_at'] == null ? null : DateTime.parse(m['last_at'] as String),
        obsCount: ((m['obs_count'] ?? 0) as num).toInt(),
      );
}

class Observation {
  final int id;

  /// null — скан әлі ешбір өсімдікке тіркелмеген (тарихта сақталады).
  final int? plantId;
  final String plantName;

  /// Кішірейтілген фото (base64 JPEG) — барлық платформада көрсетіледі.
  final String thumb;

  /// Телефондағы түпнұсқа фотоның жолы (вебте бос болады).
  final String photoPath;
  final DateTime takenAt;
  final String status;
  final double greenPct;
  final double yellowPct;
  final double brownPct;
  final String note;

  /// Gemini талдауының JSON-ы (болмаса — бос жол).
  final String aiJson;

  const Observation({
    required this.id,
    this.plantId,
    this.plantName = '',
    this.thumb = '',
    this.photoPath = '',
    required this.takenAt,
    required this.status,
    required this.greenPct,
    required this.yellowPct,
    required this.brownPct,
    this.note = '',
    this.aiJson = '',
  });

  AiAnalysis? get ai => AiAnalysis.tryDecode(aiJson);

  Map<String, Object?> toMap() => {
        'id': id,
        'plant_id': plantId,
        'thumb': thumb,
        'photo_path': photoPath,
        'taken_at': takenAt.toIso8601String(),
        'status': status,
        'green_pct': greenPct,
        'yellow_pct': yellowPct,
        'brown_pct': brownPct,
        'note': note,
        'ai_json': aiJson,
      };

  factory Observation.fromMap(Map<String, Object?> m) => Observation(
        id: (m['id'] as num).toInt(),
        plantId: (m['plant_id'] as num?)?.toInt(),
        plantName: (m['plant_name'] ?? '') as String,
        thumb: (m['thumb'] ?? '') as String,
        photoPath: (m['photo_path'] ?? '') as String,
        takenAt: DateTime.parse(m['taken_at'] as String),
        status: m['status'] as String,
        greenPct: ((m['green_pct'] ?? 0) as num).toDouble(),
        yellowPct: ((m['yellow_pct'] ?? 0) as num).toDouble(),
        brownPct: ((m['brown_pct'] ?? 0) as num).toDouble(),
        note: (m['note'] ?? '') as String,
        aiJson: (m['ai_json'] ?? '') as String,
      );
}
