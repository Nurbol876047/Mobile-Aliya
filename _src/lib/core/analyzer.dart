/// Фотоны ЖИ талдауына дайындау: оқу, тексеру, кішірейту.
/// Ауыр жұмыс compute() арқылы бөлек isolate-та орындалады.
library;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'logic.dart';

class PreparedPhoto {
  /// Кішірейтілген JPEG (base64, ≈480 px) — дерекқорда осы сақталады.
  final String thumb;

  /// Gemini-ге жіберілетін JPEG (≈768 px): баяу желіде де тез жетеді.
  final Uint8List aiJpeg;

  const PreparedPhoto({required this.thumb, required this.aiJpeg});
}

img.Image _fit(img.Image src, int maxSide) {
  if (src.width <= maxSide && src.height <= maxSide) return src;
  return src.width >= src.height
      ? img.copyResize(src, width: maxSide, maintainAspect: true)
      : img.copyResize(src, height: maxSide, maintainAspect: true);
}

PreparedPhoto preparePhotoSync(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const ValidationError('err.imageBroken');
  }
  if (decoded.width <= 0 ||
      decoded.height <= 0 ||
      decoded.width * decoded.height > maxImagePixels) {
    throw const ValidationError('err.imageTooLarge');
  }
  return PreparedPhoto(
    thumb: base64Encode(img.encodeJpg(_fit(decoded, 480), quality: 75)),
    aiJpeg: Uint8List.fromList(img.encodeJpg(_fit(decoded, 768), quality: 82)),
  );
}

Future<PreparedPhoto> preparePhoto(Uint8List bytes) =>
    compute(preparePhotoSync, bytes);
