import '../l10n/l10n.dart';

const _months = {
  Lang.kk: ['қаңтар', 'ақпан', 'наурыз', 'сәуір', 'мамыр', 'маусым', 'шілде', 'тамыз', 'қыркүйек', 'қазан', 'қараша', 'желтоқсан'],
  Lang.ru: ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'],
  Lang.en: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
};

String fmtDate(DateTime d) {
  final m = _months[L10n.current]![d.month - 1];
  return L10n.current == Lang.en ? '$m ${d.day}, ${d.year}' : '${d.day} $m ${d.year}';
}

String fmtDateTime(DateTime d) =>
    '${fmtDate(d)}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String shortDate(DateTime d) => '${d.day}.${d.month}';
