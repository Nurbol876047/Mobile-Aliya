/// Фотоны құрылғының жеке қалтасына сақтау.
/// Вебте файлдық жүйе жоқ, сондықтан платформаға қарай әртүрлі іске асыру.
library;
export 'photo_store_web.dart' if (dart.library.io) 'photo_store_io.dart';
