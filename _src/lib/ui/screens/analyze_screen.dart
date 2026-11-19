import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/ai.dart';
import '../../core/ai_service.dart';
import '../../core/analyzer.dart';
import '../../core/logic.dart';
import '../../core/photo_store.dart';
import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../app.dart';
import '../theme.dart';
import '../widgets/ai_card.dart';
import '../widgets/common.dart';
import 'camera_screen.dart';
import 'plant_detail_screen.dart';

/// Фото сканер — әрқашан қолжетімді, алдын ала шарт жоқ.
/// Нәтижені тек ЖИ береді; скан бірден тарихқа сақталады,
/// өсімдікке тіркеу — сканнан кейін (міндетті емес).
class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key, this.plantId});
  final int? plantId;

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

const int _newPlant = -1; // «＋ Жаңа өсімдік қосу» таңдауы

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final _picker = ImagePicker();
  final _note = TextEditingController();
  final _newName = TextEditingController();

  int? _plantId; // скан алдындағы контекст (міндетті емес)
  int? _target; // тіркеу таңдауы
  String _newSpecies = '';
  Uint8List? _bytes;
  String _ext = 'jpg';
  PreparedPhoto? _prepared;
  AiAnalysis? _ai;
  int? _savedObsId; // тарихқа сақталған сканның id-і
  bool _attached = false;
  String? _aiError;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _plantId = widget.plantId;
  }

  @override
  void dispose() {
    _note.dispose();
    _newName.dispose();
    super.dispose();
  }

  int get _assignTarget => _target ?? _plantId ?? _newPlant;

  void _reset() {
    setState(() {
      _bytes = null;
      _prepared = null;
      _ai = null;
      _savedObsId = null;
      _attached = false;
      _aiError = null;
      _error = null;
      _target = null;
      _newSpecies = '';
      _note.clear();
      _newName.clear();
    });
  }

  /// Камераны ашу: вебте — қолданба ішіндегі камера (файл таңдағыш емес),
  /// телефонда — жүйелік камера қосымшасы.
  Future<void> _openCamera() async {
    if (!kIsWeb) {
      await _pick(ImageSource.camera);
      return;
    }
    setState(() => _error = null);
    final bytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (bytes == null || !mounted) return;
    try {
      _ext = validatePhotoUpload('camera.jpg', bytes.length); // камера әрқашан JPEG
      setState(() {
        _bytes = bytes;
        _prepared = null;
        _ai = null;
        _savedObsId = null;
        _attached = false;
        _aiError = null;
      });
    } on ValidationError catch (e) {
      setState(() => _error = e.text);
    }
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _error = null);
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 92);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      // Кеңейтім мен өлшемді тексеру (10 МБ шегі, тек JPG/PNG/WEBP)
      _ext = validatePhotoUpload(file.name, bytes.length);
      setState(() {
        _bytes = bytes;
        _prepared = null;
        _ai = null;
        _savedObsId = null;
        _attached = false;
        _aiError = null;
      });
    } on ValidationError catch (e) {
      setState(() => _error = e.text);
    } catch (_) {
      setState(() => _error = tr('err.pickFailed'));
    }
  }

  Future<void> _scan() async {
    final bytes = _bytes;
    if (bytes == null) {
      setState(() => _error = tr('scan.hintPick'));
      return;
    }
    if (!AiService.enabled) {
      setState(() => _error = tr('err.ai.notConfigured'));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _ai = null;
      _aiError = null;
    });
    try {
      _prepared ??= await preparePhoto(bytes); // оқу + кішірейту (isolate)
      await _runAi();
    } on ValidationError catch (e) {
      setState(() => _error = e.text);
    } catch (_) {
      setState(() => _error = tr('err.processFailed'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runAi() async {
    final prepared = _prepared;
    if (prepared == null) return;
    final s = context.read<AppState>();
    final plant = s.plants.where((p) => p.id == _plantId).toList();
    setState(() {
      _busy = true;
      _aiError = null;
    });
    try {
      final ai = await AiService.analyze(
        prepared.aiJpeg,
        plant: plant.isEmpty ? '' : plant.first.name,
        species: plant.isEmpty ? '' : plant.first.species,
      );
      final guess = plantGuess(ai);
      if (!mounted) return;
      setState(() {
        _ai = ai;
        _target = null;
        _newName.text = guess.name;
        _newSpecies = guess.species;
      });
      await _saveScan(ai); // нәтиже бірден тарихқа сақталады
    } on ValidationError catch (e) {
      if (mounted) setState(() => _aiError = e.text);
    } catch (_) {
      if (mounted) setState(() => _aiError = tr('ai.failed'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Сканды (ЖИ нәтижесімен) тарихқа сақтау. Өсімдік міндетті емес.
  Future<void> _saveScan(AiAnalysis ai) async {
    final prepared = _prepared;
    final bytes = _bytes;
    if (prepared == null || bytes == null) return;
    final s = context.read<AppState>();
    try {
      final path = await savePhotoBytes(bytes, _ext);
      final id = await s.addObservation(
        plantId: _plantId,
        ai: ai,
        thumb: prepared.thumb,
        photoPath: path,
      );
      if (!mounted) return;
      setState(() {
        _savedObsId = id;
        _attached = _plantId != null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('scan.saved'))));
    } on ValidationError catch (e) {
      if (mounted) setState(() => _error = e.text);
    }
  }

  /// Сақталған сканды өсімдікке тіркеу (бар өсімдік немесе жаңасы) + жазба.
  Future<void> _attach() async {
    final s = context.read<AppState>();
    final obsId = _savedObsId;
    if (obsId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      var plantId = _assignTarget;
      if (plantId == _newPlant) {
        // Атауы ЖИ-ден алдын ала толтырылған, пайдаланушы өзгерте алады
        plantId = await s.addPlant(_newName.text, _newSpecies, '');
      }
      await s.attachObservation(obsId, plantId,
          note: _note.text.trim().isEmpty ? null : _note.text);
      if (!mounted) return;
      setState(() => _attached = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('scan.assigned'))));
      final savedId = plantId;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        _reset();
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => PlantDetailScreen(plantId: savedId)));
      }
    } on ValidationError catch (e) {
      setState(() => _error = e.text);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final muted = onSurfaceMuted(context);
    final aiPending = _busy && _prepared != null && _ai == null && _aiError == null;
    final target = _assignTarget;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final body = ListView(
      padding: EdgeInsets.fromLTRB(20, 16, 20,
          widget.plantId == null ? navBarClearance(context) + 12 : 28),
      children: [
        if (widget.plantId == null) ...[
          Text(tr('scan.title'),
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(tr('scan.subtitle'),
              style: TextStyle(fontSize: 13, color: muted)),
        ],
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _pick(ImageSource.gallery),
          child: Container(
            height: 260,
            decoration: BoxDecoration(
              color: dark ? C.surface2Dark : C.surface2,
              borderRadius: BorderRadius.circular(22),
              border: _bytes == null
                  ? Border.all(color: C.greenBright, width: 1.5)
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: _bytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_camera_outlined,
                          size: 40, color: C.greenInk),
                      const SizedBox(height: 8),
                      Text(tr('scan.pick'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: C.greenInk, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(tr('scan.formats'),
                          style: TextStyle(fontSize: 12, color: muted)),
                    ],
                  )
                : Image.memory(_bytes!, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(tr('scan.camera')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(tr('scan.gallery')),
              ),
            ),
          ],
        ),
        if (s.plants.isNotEmpty && widget.plantId == null && _savedObsId == null) ...[
          const SizedBox(height: 14),
          Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: '${tr('scan.plant')} ',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: C.greenInk)),
                TextSpan(text: tr('scan.plantHint'), style: TextStyle(color: muted)),
              ]),
              style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<int?>(
            initialValue: _plantId,
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(tr('scan.none'))),
              ...s.plants.map(
                  (p) => DropdownMenuItem<int?>(value: p.id, child: Text(p.name))),
            ],
            onChanged: (v) => setState(() {
              _plantId = v;
              _target = null;
            }),
          ),
        ],
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: (_busy || _bytes == null || !AiService.enabled) ? null : _scan,
          icon: const Icon(Icons.auto_awesome, size: 20),
          label: Text(_busy ? tr('scan.busy') : tr('scan.btn')),
        ),
        const SizedBox(height: 8),
        Text(
          !AiService.enabled
              ? tr('scan.aiOff')
              : _bytes == null
                  ? tr('scan.hintPick')
                  : tr('scan.hintReady'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: muted),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Card(
            color: C.dangerBg,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(_error!, style: const TextStyle(color: C.clayInk)),
            ),
          ),
        ],
        if (aiPending || _ai != null || _aiError != null) ...[
          SectionTitle(tr('scan.result')),
          if (aiPending)
            const AiLoadingCard()
          else if (_ai != null)
            AiCard(_ai!)
          else
            AiErrorCard(_aiError!, onRetry: _busy ? null : _runAi),
        ],
        if (_ai != null && _savedObsId != null && !_attached && !_busy) ...[
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(tr('scan.assignTitle'),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: C.greenInk)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    key: ValueKey('target-$target-${s.plants.length}'),
                    initialValue: target,
                    items: [
                      ...s.plants.map((p) =>
                          DropdownMenuItem(value: p.id, child: Text(p.name))),
                      DropdownMenuItem(
                          value: _newPlant, child: Text(tr('scan.newPlant'))),
                    ],
                    onChanged: (v) => setState(() => _target = v),
                  ),
                  if (target == _newPlant) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newName,
                      maxLength: maxNameLen,
                      decoration: InputDecoration(
                          labelText: tr('scan.newName'),
                          hintText: tr('add.nameHint')),
                    ),
                    if (_newSpecies.isNotEmpty)
                      Text(tr('scan.speciesAi', {'s': _newSpecies}),
                          style: TextStyle(fontSize: 12, color: muted)),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _note,
                    maxLines: 3,
                    maxLength: maxNoteLen,
                    decoration: InputDecoration(hintText: tr('scan.note')),
                  ),
                  FilledButton.icon(
                    onPressed: _busy ? null : _attach,
                    icon: const Icon(Icons.link, size: 20),
                    label: Text(tr('scan.assignBtn')),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_savedObsId != null && !_busy) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(tr('scan.newScan')),
          ),
        ],
        const SizedBox(height: 10),
        Text(tr('scan.disclaimer'),
            style: TextStyle(fontSize: 12, color: muted)),
      ],
    );

    if (widget.plantId == null) return body;
    return Scaffold(
      appBar: AppBar(title: Text(tr('scan.newScan'))),
      body: SafeArea(top: false, child: body),
    );
  }
}
