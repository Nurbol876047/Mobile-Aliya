import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'core/repo_factory.dart';
import 'state/app_state.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState(createRepo());
  await state.init();
  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: state,
      child: const FloraCareApp(),
    ),
  );
}
