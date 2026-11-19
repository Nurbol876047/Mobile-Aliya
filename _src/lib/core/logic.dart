/// Бизнес-логика: Flutter-ден де, дерекқордан да тәуелсіз таза модуль.
/// Барлық функциялар тестпен қамтылған (test/logic_test.dart).
library;

import '../l10n/l10n.dart';
import 'models.dart';

/// Қате коды (l10n кілті, мыс. 'err.nameRequired'). Мәтіні — tr(code).
class ValidationError implements Exception {
  final String message;
  const ValidationError(this.message);

  /// Пайдаланушыға көрсетілетін мәтін — таңдалған тілде.
  String get text => tr(message);

  @override
  String toString() => text;
}

const String kHealthy = 'healthy';
const String kWarning = 'warning';
const String kCritical = 'critical';

/// Өсімдік әлі ЖИ арқылы талданбаған (күй белгісіз — «дені сау» деп болжамаймыз).
const String kNone = 'none';
/// Дерекқордағы diagnoses кестесінің әдепкі мәтіндері (SPEC, 3-кесте).
/// Интерфейсте көрсетілмейді — ол үшін tr('status.*') қолданылады.
const Map<String, String> statusLabels = {
  kHealthy: 'Дені сау',
  kWarning: 'Назар аудару керек',
  kCritical: 'Қауіпті жағдай',
};

const Map<String, int> statusSeverity = {kHealthy: 0, kWarning: 1, kCritical: 2};

const Map<String, String> advice = {
  kHealthy: 'Жапырақтар жасыл. Күтімді өзгертпеңіз, аптасына бір рет фото түсіріп отырыңыз.',
  kWarning: 'Сарғаю байқалады. Суару режимін, жарықты және тыңайтқышты (азот, темір) тексеріңіз.',
  kCritical: 'Қоңыр дақтар көп: күйік, артық су немесе ауру болуы мүмкін. '
      'Зақымдалған жапырақтарды алыңыз, топырақ ылғалын тексеріңіз, жағдай жалғасса маманға көрсетіңіз.',
};

const Set<String> allowedExt = {'jpg', 'jpeg', 'png', 'webp'};
const int maxPhotoBytes = 10 * 1024 * 1024;
const int maxImagePixels = 40000000;
const int maxNameLen = 60;
const int maxNoteLen = 500;
const List<String> sortKeys = ['date', 'plant', 'status', 'green'];

// ---------- Валидация ----------

String validatePlantName(String? name) {
  final value = (name ?? '').trim();
  if (value.isEmpty) throw const ValidationError('err.nameRequired');
  if (value.length > maxNameLen) {
    throw const ValidationError('err.nameTooLong');
  }
  return value;
}

String validateNote(String? note) {
  final value = (note ?? '').trim();
  if (value.length > maxNoteLen) {
    throw const ValidationError('err.noteTooLong');
  }
  return value;
}

String extensionOf(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot < 0 || dot == fileName.length - 1) return '';
  return fileName.substring(dot + 1).toLowerCase();
}

/// Галереядан/камерадан алынған файл атауы мен өлшемін тексереді.
String validatePhotoUpload(String? name, int? size) {
  final ext = extensionOf(name ?? '');
  if (!allowedExt.contains(ext)) {
    throw const ValidationError('err.photoFormat');
  }
  if (size == null || size <= 0) {
    throw const ValidationError('err.photoEmpty');
  }
  if (size > maxPhotoBytes) {
    throw const ValidationError('err.photoTooBig');
  }
  return ext;
}

// ---------- Іздеу, сүзу, сұрыптау ----------

List<Observation> filterAndSort(
  List<Observation> items, {
  String query = '',
  String? status,
  int? plantId,
  int? days,
  String sortBy = 'date',
  bool descending = true,
  DateTime? now,
}) {
  if (!sortKeys.contains(sortBy)) {
    throw ValidationError('err.badSortKey:$sortBy');
  }
  if (status != null && !statusSeverity.containsKey(status)) {
    throw ValidationError('err.badStatus:$status');
  }
  if (days != null && days <= 0) {
    throw const ValidationError('err.badDays');
  }

  final q = query.trim().toLowerCase();
  final nowValue = now ?? DateTime.now();
  final since = days == null ? null : nowValue.subtract(Duration(days: days));

  final result = items.where((it) {
    if (q.isNotEmpty &&
        !('${it.plantName} ${it.note}'.toLowerCase().contains(q))) {
      return false;
    }
    if (status != null && it.status != status) return false;
    if (plantId != null && it.plantId != plantId) return false;
    if (since != null && it.takenAt.isBefore(since)) return false;
    return true;
  }).toList();

  int cmp(Observation a, Observation b) {
    switch (sortBy) {
      case 'plant':
        return a.plantName.toLowerCase().compareTo(b.plantName.toLowerCase());
      case 'status':
        return (statusSeverity[a.status] ?? -1)
            .compareTo(statusSeverity[b.status] ?? -1);
      case 'green':
        return a.greenPct.compareTo(b.greenPct);
      default:
        return a.takenAt.compareTo(b.takenAt);
    }
  }

  result.sort((a, b) => descending ? cmp(b, a) : cmp(a, b));
  return result;
}

/// Хронологиялық жасыл үлесі бойынша: improving | worsening | stable | insufficient.
String trend(List<double> greenValues) {
  if (greenValues.length < 2) return 'insufficient';
  final diff = greenValues.last - greenValues[greenValues.length - 2];
  if (diff >= 5) return 'improving';
  if (diff <= -5) return 'worsening';
  return 'stable';
}
