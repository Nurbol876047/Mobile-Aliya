/// Браузердегі камера (getUserMedia): тікелей көрініс + кадрды JPEG етіп алу.
/// Телефонда жүйелік камера қолданылады, сондықтан онда бұл модуль бос.
library;
export 'web_camera_web.dart' if (dart.library.io) 'web_camera_io.dart';
