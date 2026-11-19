/// Вебте алдын ала қарауға арналған қойма (sqflite вебте жұмыс істемейді).
/// Дәл сол интерфейс, бірақ деректер JSON түрінде SharedPreferences-те сақталады.
library;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'logic.dart';
import 'models.dart';
import 'repo.dart';

PlantRepo createRepo() => PrefsRepo();

class PrefsRepo implements PlantRepo {
  static const _key = 'floracare_data_v1';
  late SharedPreferences _prefs;
  final List<Map<String, Object?>> _plants = [];
  final List<Map<String, Object?>> _obs = [];
  int _nextId = 1;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_key);
    if (raw == null) return; // бос қолданба — шаблон деректер жоқ
    final data = jsonDecode(raw) as Map<String, dynamic>;
    _plants
      ..clear()
      ..addAll((data['plants'] as List).cast<Map<String, Object?>>());
    _obs
      ..clear()
      ..addAll((data['observations'] as List).cast<Map<String, Object?>>());
    _nextId = (data['next_id'] as num?)?.toInt() ?? 1;
  }

  Future<void> _save() async {
    await _prefs.setString(
      _key,
      jsonEncode({'plants': _plants, 'observations': _obs, 'next_id': _nextId}),
    );
  }

  @override
  Future<List<Plant>> listPlants() async {
    final list = _plants.map((m) {
      final obs = _obs.where((o) => o['plant_id'] == m['id']).toList()
        ..sort((a, b) =>
            (b['taken_at'] as String).compareTo(a['taken_at'] as String));
      return Plant.fromMap({
        ...m,
        'last_status': obs.isEmpty ? null : obs.first['status'],
        'last_thumb': obs.isEmpty ? null : obs.first['thumb'],
        'last_at': obs.isEmpty ? null : obs.first['taken_at'],
        'obs_count': obs.length,
      });
    }).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  @override
  Future<Plant?> getPlant(int id) async {
    final all = await listPlants();
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<int> addPlant(String name,
      {String species = '', String location = '', String? catalogId}) async {
    final id = _nextId++;
    _plants.add({
      'id': id,
      'name': validatePlantName(name),
      'species': validateNote(species),
      'location': validateNote(location),
      'created_at': DateTime.now().toIso8601String(),
      'catalog_id': catalogId,
    });
    await _save();
    return id;
  }

  @override
  Future<List<String>> deletePlant(int id) async {
    _plants.removeWhere((m) => m['id'] == id);
    final paths = _obs
        .where((o) => o['plant_id'] == id)
        .map((o) => (o['photo_path'] ?? '') as String)
        .where((s) => s.isNotEmpty)
        .toList();
    _obs.removeWhere((o) => o['plant_id'] == id);
    await _save();
    return paths;
  }

  @override
  Future<List<Observation>> listObservations({int? plantId}) async {
    final names = {for (final p in _plants) p['id']: p['name'] as String};
    final list = _obs
        .where((o) => plantId == null || o['plant_id'] == plantId)
        .map((o) => Observation.fromMap({...o, 'plant_name': names[o['plant_id']] ?? ''}))
        .toList();
    list.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return list;
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
    if (plantId != null && !_plants.any((m) => m['id'] == plantId)) {
      throw const ValidationError('err.plantNotFound');
    }
    final id = _nextId++;
    _obs.add({
      'id': id,
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
    await _save();
    return id;
  }

  @override
  Future<String?> deleteObservation(int id) async {
    final idx = _obs.indexWhere((o) => o['id'] == id);
    if (idx < 0) return null;
    final path = (_obs[idx]['photo_path'] ?? '') as String;
    _obs.removeAt(idx);
    await _save();
    return path;
  }

  @override
  Future<void> updateObservation(int id, {int? plantId, String? note}) async {
    if (plantId != null && !_plants.any((m) => m['id'] == plantId)) {
      throw const ValidationError('err.plantNotFound');
    }
    final i = _obs.indexWhere((o) => o['id'] == id);
    if (i < 0) return;
    _obs[i] = {
      ..._obs[i],
      'plant_id': plantId,
      if (note != null) 'note': validateNote(note),
    };
    await _save();
  }
}
