import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

/// Вебте камера getUserMedia арқылы ашылады (файл таңдағыш емес).
const bool webCameraAvailable = true;

/// Камера қатесі: 'denied' (рұқсат жоқ) | 'none' (камера жоқ) | 'failed'.
class WebCameraError implements Exception {
  const WebCameraError(this.code);
  final String code;
  @override
  String toString() => 'WebCameraError($code)';
}

int _viewCounter = 0;

/// Ашылған камера: `viewType` — HtmlElementView үшін, `capture()` — JPEG байттары.
class WebCamera {
  WebCamera._(this.viewType, this._video, this._stream, this.front);

  final String viewType;
  final web.HTMLVideoElement _video;
  final web.MediaStream _stream;

  /// Алдыңғы (селфи) камера — көрініс айнадай көрсетіледі.
  final bool front;

  /// Ағымдағы кадрды JPEG ретінде алу.
  Future<Uint8List> capture() async {
    final w = _video.videoWidth;
    final h = _video.videoHeight;
    if (w == 0 || h == 0) throw const WebCameraError('failed');

    final canvas = web.HTMLCanvasElement()
      ..width = w
      ..height = h;
    final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
    if (front) {
      // Көрініс айнадай болғандықтан, суретті де сол күйінде сақтаймыз
      ctx
        ..translate(w.toDouble(), 0)
        ..scale(-1, 1);
    }
    ctx.drawImage(_video, 0, 0, w.toDouble(), h.toDouble());

    final completer = Completer<web.Blob>();
    canvas.toBlob(
      (web.Blob blob) {
        completer.complete(blob);
      }.toJS,
      'image/jpeg',
      0.92.toJS,
    );
    final blob = await completer.future.timeout(const Duration(seconds: 10),
        onTimeout: () => throw const WebCameraError('failed'));
    final buffer = await blob.arrayBuffer().toDart;
    return buffer.toDart.asUint8List();
  }

  /// Камераны өшіру (индикатор сөнеді).
  void stop() {
    for (final track in _stream.getTracks().toDart) {
      track.stop();
    }
    _video.srcObject = null;
  }
}

/// Камераны ашу. `front: false` — артқы камера (өсімдікті түсіруге).
Future<WebCamera> startWebCamera({bool front = false}) async {
  final web.MediaDevices mediaDevices;
  try {
    mediaDevices = web.window.navigator.mediaDevices;
  } catch (_) {
    throw const WebCameraError('none'); // қорғалмаған (http) origin
  }

  final constraints = web.MediaStreamConstraints(
    video: <String, Object>{
      'facingMode': <String, Object>{'ideal': front ? 'user' : 'environment'},
      'width': <String, Object>{'ideal': 1280},
      'height': <String, Object>{'ideal': 960},
    }.jsify()!,
    audio: false.toJS,
  );

  final web.MediaStream stream;
  try {
    stream = await mediaDevices.getUserMedia(constraints).toDart;
  } catch (e) {
    throw WebCameraError(_codeOf(e));
  }

  final video = web.HTMLVideoElement()
    ..autoplay = true
    ..muted = true
    ..srcObject = stream;
  video.setAttribute('playsinline', ''); // iOS Safari толық экранға ауыспасын
  video.style
    ..width = '100%'
    ..height = '100%'
    ..objectFit = 'cover';
  if (front) video.style.transform = 'scaleX(-1)';

  final viewType = 'floracare-camera-${_viewCounter++}';
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) => video);

  // Кадр өлшемі белгілі болғанша күтеміз (≤5 с)
  for (var i = 0; i < 100 && video.videoWidth == 0; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  return WebCamera._(viewType, video, stream, front);
}

/// Бірнеше камера бар ма (ауыстыру түймесін көрсету үшін).
Future<bool> webCameraHasMultiple() async {
  try {
    final devices = await web.window.navigator.mediaDevices.enumerateDevices().toDart;
    var count = 0;
    for (final d in devices.toDart) {
      if (d.kind == 'videoinput') count++;
    }
    return count > 1;
  } catch (_) {
    return false;
  }
}

/// DOMException атауын түсінікті кодқа айналдыру.
String _codeOf(Object error) {
  final name = error is JSObject && error.isA<web.DOMException>()
      ? (error as web.DOMException).name
      : '';
  return switch (name) {
    'NotAllowedError' || 'SecurityError' || 'PermissionDeniedError' => 'denied',
    'NotFoundError' || 'DevicesNotFoundError' || 'OverconstrainedError' => 'none',
    _ => 'failed',
  };
}
