/// SQLite қабаты (Android/iOS/десктоп). Барлық сұраулар параметрленген —
/// SQL injection мүмкін емес. Дерекқор қолданбаның жеке қалтасында жатады.
library;
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'logic.dart';
import 'models.dart';
import 'repo.dart';

PlantRepo createRepo() => SqliteRepo();

class SqliteRepo implements PlantRepo {
  late final Database _db;
  late final String photosDir;

  @override
  Future<void> init() async {
    final docs = await getApplicationDocumentsDirectory();
    photosDir = p.join(docs.path, 'photos');
    await Directory(photosDir).create(recursive: true);

    final path = p.join(docs.path, 'floracare.db');
    _db = await openDatabase(
      path,
      version: 2,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute(_diagnosesSql);
        await db.execute(_plantsSql);
        await db.execute(_observationsSql);
        await db.execute(_indexSql);
        await _seedDiagnoses(db);
      },
      onUpgrade: (db, from, to) async {
        if (from < 2) {
          // v2: plants.catalog_id; observations.plant_id NULL болуы мүмкін
          // (SQLite NOT NULL-ды ALTER арқылы алып тастай алмайды → кестені қайта құрамыз)
          await db.execute('ALTER TABLE plants ADD COLUMN catalog_id TEXT');
          await db.execute('ALTER TABLE observations RENAME TO observations_v1');
          await db.execute(_observationsSql);
          await db.execute('INSERT INTO observations SELECT id, plant_id, thumb, photo_path, '
              'taken_at, status, green_pct, yellow_pct, brown_pct, note, ai_json FROM observations_v1');
          await db.execute('DROP TABLE observations_v1');
          await db.execute(_indexSql);
        }
      },
    );
  }

  static const _diagnosesSql = '''
    CREATE TABLE diagnoses (
      code   TEXT PRIMARY KEY,
      title  TEXT NOT NULL,
      advice TEXT NOT NULL
    )''';

  static const _plantsSql = '''
    CREATE TABLE plants (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      name       TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 60),
      species    TEXT NOT NULL DEFAULT '',
      location   TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL,
      catalog_id TEXT
    )''';

  // plant_id NULL — скан әлі өсімдікке тіркелмеген; өсімдік жойылса, скандары да жойылады
  static const _observationsSql = '''
    CREATE TABLE observations (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      plant_id   INTEGER REFERENCES plants(id) ON DELETE CASCADE,
      thumb      TEXT NOT NULL DEFAULT '',
      photo_path TEXT NOT NULL DEFAULT '',
      taken_at   TEXT NOT NULL,
      status     TEXT NOT NULL REFERENCES diagnoses(code),
      green_pct  REAL NOT NULL,
      yellow_pct REAL NOT NULL,
      brown_pct  REAL NOT NULL,
      note       TEXT NOT NULL DEFAULT '',
      ai_json    TEXT NOT NULL DEFAULT ''
    )''';

  static const _indexSql =
      'CREATE INDEX IF NOT EXISTS idx_obs_plant_date ON observations(plant_id, taken_at)';

  static Future<void> _seedDiagnoses(Database db) async {
    for (final e in statusLabels.entries) {
      await db.insert('diagnoses', {'code': e.key, 'title': e.value, 'advice': advice[e.key]});
    }
  }

  @override
  Future<List<Plant>> listPlants() async {
    final rows = await _db.rawQuery('''
      SELECT p.*,
        (SELECT status     FROM observations o WHERE o.plant_id=p.id ORDER BY taken_at DESC, id DESC LIMIT 1) AS last_status,
        (SELECT thumb      FROM observations o WHERE o.plant_id=p.id ORDER BY taken_at DESC, id DESC LIMIT 1) AS last_thumb,
        (SELECT taken_at   FROM observations o WHERE o.plant_id=p.id ORDER BY taken_at DESC, id DESC LIMIT 1) AS last_at,
        (SELECT COUNT(*)   FROM observations o WHERE o.plant_id=p.id) AS obs_count
      FROM plants p ORDER BY p.name COLLATE NOCASE''');
    return rows.map(Plant.fromMap).toList();
  }

  @override
  Future<Plant?> getPlant(int id) async {
    final rows = await _db.query('plants', where: 'id=?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Plant.fromMap(rows.first);
  }

  @override
  Future<int> addPlant(String name,
      {String species = '', String location = '', String? catalogId}) async {
    return _db.insert('plants', {
      'name': validatePlantName(name),
      'species': validateNote(species),
      'location': validateNote(location),
      'created_at': DateTime.now().toIso8601String(),
      'catalog_id': catalogId,
    });
  }

  @override
  Future<List<String>> deletePlant(int id) async {
    final rows = await _db.query('observations',
        columns: ['photo_path'], where: 'plant_id=?', whereArgs: [id]);
    await _db.delete('plants', where: 'id=?', whereArgs: [id]);
    final paths = rows
        .map((r) => (r['photo_path'] ?? '') as String)
        .where((s) => s.isNotEmpty)
        .toList();
    for (final path in paths) {
      try {
        await File(path).delete();
      } on FileSystemException {
        // файл жоқ болса, елемейміз
      }
    }
    return paths;
  }

  @override
  Future<List<Observation>> listObservations({int? plantId}) async {
    final rows = await _db.rawQuery(
      'SELECT o.*, p.name AS plant_name FROM observations o '
      'LEFT JOIN plants p ON p.id = o.plant_id'
      '${plantId != null ? ' WHERE o.plant_id=?' : ''}'
      ' ORDER BY o.taken_at DESC, o.id DESC',
      plantId != null ? [plantId] : const [],
    );
    return rows.map(Observation.fromMap).toList();
  }

  @override
  Future<int> addObservation({
    int? plantId,
    required String thumb,
    required String photoPath,
    required String status,
    required double greenPct,
    required double yellowPct,
    required double brownPct,
    String note = '',
    String aiJson = '',
    DateTime? takenAt,
  }) async {
    if (plantId != null && await getPlant(plantId) == null) {
      throw const ValidationError('err.plantNotFound');
    }
    return _db.insert('observations', {
      'plant_id': plantId,
      'thumb': thumb,
      'photo_path': photoPath,
      'taken_at': (takenAt ?? DateTime.now()).toIso8601String(),
      'status': status,
      'green_pct': greenPct,
      'yellow_pct': yellowPct,
      'brown_pct': brownPct,
      'note': validateNote(note),
      'ai_json': aiJson,
    });
  }

  @override
  Future<String?> deleteObservation(int id) async {
    final rows = await _db.query('observations',
        columns: ['photo_path'], where: 'id=?', whereArgs: [id]);
    await _db.delete('observations', where: 'id=?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final path = (rows.first['photo_path'] ?? '') as String;
    if (path.isNotEmpty) {
      try {
        await File(path).delete();
      } on FileSystemException {
        // файл жоқ
      }
    }
    return path;
  }

  @override
  Future<void> updateObservation(int id, {int? plantId, String? note}) async {
    if (plantId != null && await getPlant(plantId) == null) {
      throw const ValidationError('err.plantNotFound');
    }
    await _db.update(
      'observations',
      {'plant_id': plantId, if (note != null) 'note': validateNote(note)},
      where: 'id=?',
      whereArgs: [id],
    );
  }
}
