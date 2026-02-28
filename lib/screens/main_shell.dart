import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubits/builder/builder_cubit.dart';
import '../cubits/runner/runner_cubit.dart';
import '../cubits/settings/settings_cubit.dart';
import '../injection.dart';
import '../models/app_settings.dart';
import 'builder/builder_screen.dart';
import 'runner/runner_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    NavigationRailDestination(
      icon: Icon(Icons.build_outlined),
      selectedIcon: Icon(Icons.build),
      label: Text('Builder'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.play_circle_outline),
      selectedIcon: Icon(Icons.play_circle),
      label: Text('Runner'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BuilderCubit()),
        BlocProvider(create: (_) => RunnerCubit()),
        BlocProvider(
          create: (_) => SettingsCubit(sl<AppSettings>(), sl<SharedPreferences>()),
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) =>
                    setState(() => _selectedIndex = i),
                labelType: NavigationRailLabelType.all,
                destinations: _destinations,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'SYM',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: const [
                    BuilderScreen(),
                    RunnerScreen(),
                    SettingsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
