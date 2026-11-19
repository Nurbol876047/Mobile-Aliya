import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../core/web_camera.dart';
import '../../l10n/l10n.dart';
import '../theme.dart';

/// Браузердегі камера экраны: тікелей көрініс + түсіру түймесі.
/// Файл таңдағыш ашылмайды — кадр камерадан тікелей алынады.
/// Нәтижесі — JPEG байттары (`Navigator.pop`).
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  WebCamera? _camera;
  bool _multiple = false;
  bool _front = false;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _open(front: false);
    webCameraHasMultiple().then((v) {
      if (mounted) setState(() => _multiple = v);
    });
  }

  @override
  void dispose() {
    _camera?.stop();
    super.dispose();
  }

  Future<void> _open({required bool front}) async {
    final old = _camera;
    setState(() {
      _camera = null;
      _error = null;
      _front = front;
    });
    old?.stop();
    try {
      final cam = await startWebCamera(front: front);
      if (!mounted) {
        cam.stop();
        return;
      }
      setState(() => _camera = cam);
    } on WebCameraError catch (e) {
      if (mounted) setState(() => _error = tr('cam.${e.code}'));
    } catch (_) {
      if (mounted) setState(() => _error = tr('cam.failed'));
    }
  }

  Future<void> _shoot() async {
    final cam = _camera;
    if (cam == null || _busy) return;
    setState(() => _busy = true);
    try {
      final Uint8List bytes = await cam.capture();
      if (!mounted) return;
      Navigator.pop(context, bytes);
    } on WebCameraError catch (e) {
      if (mounted) setState(() => _error = tr('cam.${e.code}'));
    } catch (_) {
      if (mounted) setState(() => _error = tr('cam.failed'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cam = _camera;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(tr('cam.title'), style: const TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _error != null
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.no_photography_outlined,
                                color: Colors.white54, size: 40),
                            const SizedBox(height: 12),
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: Text(tr('scan.gallery')),
                            ),
                          ],
                        ),
                      )
                    : cam == null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: Colors.white),
                              const SizedBox(height: 14),
                              Text(tr('cam.starting'),
                                  style: const TextStyle(color: Colors.white70)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox.expand(
                              child: HtmlElementView(
                                  key: ValueKey(cam.viewType),
                                  viewType: cam.viewType),
                            ),
                          ),
              ),
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 56,
                    child: _multiple
                        ? IconButton(
                            tooltip: tr('cam.switch'),
                            onPressed: _busy ? null : () => _open(front: !_front),
                            icon: const Icon(Icons.cameraswitch_outlined,
                                color: Colors.white, size: 28),
                          )
                        : null,
                  ),
                  GestureDetector(
                    onTap: (cam != null && !_busy) ? _shoot : null,
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: C.greenBright, width: 4),
                      ),
                      child: _busy
                          ? const Padding(
                              padding: EdgeInsets.all(22),
                              child: CircularProgressIndicator(
                                  strokeWidth: 3, color: C.green),
                            )
                          : const Icon(Icons.photo_camera,
                              color: C.greenInk, size: 32),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: IconButton(
                      tooltip: tr('common.cancel'),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white, size: 26),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
