import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../app.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final muted = onSurfaceMuted(context);
    final name = s.userName.isEmpty ? tr('prof.defaultName') : s.userName;
    final letter = name.characters.first.toUpperCase();

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, navBarClearance(context)),
      children: [
        Text(tr('prof.title'),
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFA6C29C), Color(0xFF294B35)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(letter,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _editName(context, s),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        Icon(Icons.edit_outlined, size: 15, color: muted),
                      ],
                    ),
                  ),
                ),
                Text(tr('prof.role'),
                    style: TextStyle(color: muted, fontSize: 13)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    StatCard('${s.plants.length}', tr('prof.statPlants')),
                    const SizedBox(width: 12),
                    StatCard('${s.observations.length}', tr('prof.statScans')),
                    const SizedBox(width: 12),
                    StatCard('${s.healthyCount}', tr('prof.statHealthy'),
                        color: C.green),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SwitchListTile(
                title: Text(tr('prof.dark')),
                value: s.dark,
                activeThumbColor: C.green,
                onChanged: s.setDark,
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(tr('prof.lang')),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s.lang.label, style: TextStyle(color: muted)),
                    Icon(Icons.chevron_right, color: muted),
                  ],
                ),
                onTap: () => _chooseLang(context, s),
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(tr('prof.privacy')),
                subtitle: Text(tr('prof.privacyToast'),
                    style: TextStyle(fontSize: 12, color: muted, height: 1.35)),
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(tr('prof.about')),
                trailing: Text(kIsWeb ? 'FloraCare 1.0 · web' : 'FloraCare 1.0',
                    style: TextStyle(color: muted)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _editName(BuildContext context, AppState s) async {
    final controller = TextEditingController(text: s.userName);
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr('prof.editName')),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(hintText: tr('prof.defaultName')),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('common.cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(tr('prof.save'))),
        ],
      ),
    );
    controller.dispose();
    if (value != null) await s.setUserName(value);
  }

  Future<void> _chooseLang(BuildContext context, AppState s) async {
    final picked = await showDialog<Lang>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(tr('prof.chooseLang')),
        children: Lang.values
            .map((l) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, l),
                  child: Row(
                    children: [
                      Icon(
                          l == s.lang
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: l == s.lang ? C.green : onSurfaceMuted(context)),
                      const SizedBox(width: 10),
                      Text(l.label),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
    if (picked != null) await s.setLang(picked);
  }

}
