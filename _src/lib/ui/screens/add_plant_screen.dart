import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/logic.dart';
import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../theme.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _name = TextEditingController();
  final _species = TextEditingController();
  final _location = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      await context
          .read<AppState>()
          .addPlant(_name.text, _species.text, _location.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('add.saved'))),
        );
        Navigator.pop(context);
      }
    } on ValidationError catch (e) {
      setState(() => _error = e.text);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('add.title'))),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _Label(tr('add.name')),
            TextField(
              controller: _name,
              maxLength: maxNameLen,
              decoration: InputDecoration(hintText: tr('add.nameHint')),
              onChanged: (_) => setState(() => _error = null),
            ),
            _Label(tr('add.species')),
            TextField(
              controller: _species,
              decoration: const InputDecoration(hintText: 'Ficus elastica'),
            ),
            _Label(tr('add.location')),
            TextField(
              controller: _location,
              maxLines: 3,
              decoration: InputDecoration(hintText: tr('add.locationHint')),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: C.clayInk, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? tr('add.saving') : tr('add.save')),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? C.textDark
                    : C.greenInk)),
      );
}
