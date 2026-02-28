import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'injection.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  await windowManager.setMinimumSize(const Size(1024, 700));
  await windowManager.setTitle('SymUITest');

  await setupInjection();

  runApp(const SymUITestApp());
}

class SymUITestApp extends StatelessWidget {
  const SymUITestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SymUITest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}
