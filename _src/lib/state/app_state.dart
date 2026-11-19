import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/ai.dart';
import '../core/logic.dart';
import '../core/models.dart';
import '../core/repo.dart';
import '../l10n/l10n.dart';

/// Қолданбаның ортақ күйі: деректер, баптаулар, сүзгілер.
class AppState extends ChangeNotifier {
  AppState(this.repo);

  final PlantRepo repo;

  List<Plant> plants = [];
  List<Observation> observations = [];
  bool loading = true;
  bool dark = false;
  bool seenOnboarding = false;
  Lang lang = Lang.kk;
  String userName = '';

  /// Ашық тұрған қойынды (тіл ауысқанда интерфейс қайта сызылады —
  /// пайдаланушы сол бетте қалуы үшін индексі осында сақталады).
  int navIndex = 0;

  // Өсімдіктер экранының сүзгілері
  String plantQuery = '';
  String plantFilter = 'all';
  bool gridView = true;

  // Күнделік экранының сүзгілері
  String diaryQuery = '';
  String diaryFilter = 'all';
  int? diaryDays;
  String diarySort = 'date';
  bool diaryDesc = true;

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    dark = _prefs.getBool('dark') ?? false;
    seenOnboarding = _prefs.getBool('seen_onboarding') ?? false;
    lang = LangX.parse(_prefs.getString('lang'));
    L10n.current = lang;
    userName = _prefs.getString('user_name') ?? '';
    await repo.init();
    await reload();
    loading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    plants = await repo.listPlants();
    observations = await repo.listObservations();
    notifyListeners();
  }

  // --- баптаулар ---
  Future<void> setDark(bool value) async {
    dark = value;
    await _prefs.setBool('dark', value);
    notifyListeners();
  }

  Future<void> setLang(Lang value) async {
    lang = value;
    L10n.current = value;
    await _prefs.setString('lang', value.code);
    notifyListeners();
  }

  Future<void> setUserName(String value) async {
    userName = value.trim().length > 40 ? value.trim().substring(0, 40) : value.trim();
    await _prefs.setString('user_name', userName);
    notifyListeners();
  }

  /// Қойындыны есте сақтау (қайта сызуды тудырмайды — тек күй).
  void setNavIndex(int index) => navIndex = index;

  Future<void> finishOnboarding() async {
    seenOnboarding = true;
    await _prefs.setBool('seen_onboarding', true);
    notifyListeners();
  }


  // --- сүзгі баптаулары ---
  void setGridView(bool value) {
    gridView = value;
    notifyListeners();
  }

  void setPlantQuery(String value) {
    plantQuery = value;
    notifyListeners();
  }

  void setPlantFilter(String value) {
    plantFilter = value;
    notifyListeners();
  }

  void setDiaryQuery(String value) {
    diaryQuery = value;
    notifyListeners();
  }

  void setDiaryFilter(String value) {
    diaryFilter = value;
    notifyListeners();
  }

  void setDiaryDays(int? value) {
    diaryDays = value;
    notifyListeners();
  }

  void setDiarySort(String value) {
    diarySort = value;
    notifyListeners();
  }

  void setDiaryDesc(bool value) {
    diaryDesc = value;
    notifyListeners();
  }

  // --- деректер ---
  Future<int> addPlant(String name, String species, String location,
      {String? catalogId}) async {
    final id = await repo.addPlant(name,
        species: species, location: location, catalogId: catalogId);
    await reload();
    return id;
  }

  Future<void> deletePlant(int id) async {
    await repo.deletePlant(id);
    await reload();
  }

  /// Скан ЖИ нәтижесімен бірден тарихқа сақталады (өсімдік міндетті емес).
  /// Пайдаланушы өзі жоймайынша қалады. Жаңа жазбаның id-ін қайтарады.
  Future<int> addObservation({
    int? plantId,
    required AiAnalysis ai,
    required String thumb,
    required String photoPath,
    String note = '',
  }) async {
    final id = await repo.addObservation(
      plantId: plantId,
      thumb: thumb,
      photoPath: photoPath,
      status: ai.status,
      greenPct: ai.greenPct,
      yellowPct: ai.yellowPct,
      brownPct: ai.brownPct,
      note: note,
      aiJson: ai.encode(),
    );
    await reload();
    return id;
  }

  /// Сканды өсімдікке тіркеу / жазбаны өзгерту.
  Future<void> attachObservation(int obsId, int? plantId, {String? note}) async {
    await repo.updateObservation(obsId, plantId: plantId, note: note);
    await reload();
  }

  Plant? plantById(int? id) {
    if (id == null) return null;
    for (final p in plants) {
      if (p.id == id) return p;
    }
    return null;
  }

  Plant? plantForCatalog(String catalogId) {
    for (final p in plants) {
      if (p.catalogId == catalogId) return p;
    }
    return null;
  }

  Future<void> deleteObservation(int id) async {
    await repo.deleteObservation(id);
    await reload();
  }

  // --- көріністер ---
  List<Plant> get visiblePlants {
    final q = plantQuery.trim().toLowerCase();
    return plants.where((p) {
      if (plantFilter != 'all' && (p.lastStatus ?? kNone) != plantFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return '${p.name} ${p.species} ${p.location}'.toLowerCase().contains(q);
    }).toList();
  }

  List<Observation> get visibleObservations => filterAndSort(
        observations,
        query: diaryQuery,
        status: diaryFilter == 'all' ? null : diaryFilter,
        days: diaryDays,
        sortBy: diarySort,
        descending: diaryDesc,
      );

  List<Observation> observationsOf(int plantId) =>
      filterAndSort(observations, plantId: plantId, descending: false);

  int get healthyCount => plants.where((p) => p.lastStatus == kHealthy).length;

  /// Тек ЖИ «назар аудару» не «қауіпті» деп бағалағандар (тексерілмегендер емес).
  int get attentionCount => plants
      .where((p) => p.lastStatus == kWarning || p.lastStatus == kCritical)
      .length;
}
