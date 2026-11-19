import 'dart:typed_data';

/// Телефон/десктоп нұсқасы: браузер камерасы жоқ (жүйелік камера қолданылады).
const bool webCameraAvailable = false;

/// Камера қатесі: 'denied' (рұқсат жоқ) | 'none' (камера жоқ) | 'failed'.
class WebCameraError implements Exception {
  const WebCameraError(this.code);
  final String code;
  @override
  String toString() => 'WebCameraError($code)';
}

class WebCamera {
  String get viewType => '';
  bool get front => false;
  Future<Uint8List> capture() async => throw const WebCameraError('failed');
  void stop() {}
}

Future<WebCamera> startWebCamera({bool front = false}) async =>
    throw const WebCameraError('failed');

Future<bool> webCameraHasMultiple() async => false;
