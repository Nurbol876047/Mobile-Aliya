/// Платформаға қарай қойманы таңдау:
/// Android/iOS — SQLite, веб — SharedPreferences.
library;
export 'prefs_repo.dart' if (dart.library.io) 'sqlite_repo.dart' show createRepo;
