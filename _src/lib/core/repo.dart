/// Деректер қоймасының ортақ интерфейсі.
/// Android/iOS — SQLite (sqflite), веб-алдын ала қарау — SharedPreferences (JSON).
library;
import 'models.dart';

abstract class PlantRepo {
  Future<void> init();

  Future<List<Plant>> listPlants();
  Future<Plant?> getPlant(int id);
  Future<int> addPlant(String name,
      {String species = '', String location = '', String? catalogId});

  /// Жойылған бақылаулардың фото жолдарын қайтарады (файлдарды тазалау үшін).
  Future<List<String>> deletePlant(int id);

  Future<List<Observation>> listObservations({int? plantId});
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
  });
  Future<String?> deleteObservation(int id);

  /// Сканды өсімдікке тіркеу (немесе тіркеуді алу) және жазбаны өзгерту.
  Future<void> updateObservation(int id, {int? plantId, String? note});
}
