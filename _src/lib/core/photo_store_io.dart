import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Фотоны қолданбаның жеке қалтасына кездейсоқ атпен сақтайды.
/// Қалта басқа қолданбаларға қолжетімді емес (Android/iOS sandbox).
Future<String> savePhotoBytes(Uint8List bytes, String ext) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'photos'));
  await dir.create(recursive: true);
  final rnd = Random.secure();
  final name = List.generate(16, (_) => rnd.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  final file = File(p.join(dir.path, '$name.$ext'));
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
