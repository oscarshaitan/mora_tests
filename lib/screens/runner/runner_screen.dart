import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/runner/runner_cubit.dart';
import '../../cubits/runner/runner_state.dart';
import 'results_view.dart';
import 'run_view.dart';

class RunnerScreen extends StatelessWidget {
  const RunnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RunnerCubit, RunnerState>(
      builder: (context, state) {
        return switch (state) {
          RunnerIdle() => const _IdleView(),
          RunnerReady() => _ReadyView(state: state),
          RunnerRunning() => RunView(state: state),
          RunnerFinished() => ResultsView(state: state),
          RunnerError(:final message) => _ErrorView(message: message),
        };
      },
    );
  }
}

// ── Idle ───────────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  const _IdleView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RunnerCubit>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline,
              size: 72,
              color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('Open a test file or folder to get started',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: cubit.openFolder,
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Folder'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: cubit.openFile,
                icon: const Icon(Icons.insert_drive_file_outlined),
                label: const Text('Open File'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: cubit.loadHistory,
                icon: const Icon(Icons.history),
                label: const Text('History'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Ready ──────────────────────────────────────────────────────────────────

class _ReadyView extends StatelessWidget {
  final RunnerReady state;
  const _ReadyView({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RunnerCubit>();

    return Row(
      children: [
        // Left: test list
        SizedBox(
          width: 260,
          child: Column(
            children: [
              // Toolbar
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.folder_open),
                      tooltip: 'Open folder',
                      onPressed: cubit.openFolder,
                    ),
                    IconButton(
                      icon: const Icon(Icons.insert_drive_file_outlined),
                      tooltip: 'Open file',
                      onPressed: cubit.openFile,
                    ),
                    IconButton(
                      icon: const Icon(Icons.history),
                      tooltip: 'View history',
                      onPressed: cubit.loadHistory,
                    ),
                    const Spacer(),
                    TextButton(
                        onPressed: cubit.selectAll,
                        child: const Text('All')),
                    TextButton(
                        onPressed: cubit.deselectAll,
                        child: const Text('None')),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: state.testCases.length,
                  itemBuilder: (context, i) {
                    final tc = state.testCases[i];
                    final selected = state.selectedIds.contains(tc.id);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (_) => cubit.toggleSelection(tc.id),
                      title: Text(
                        tc.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${tc.steps.length} step${tc.steps.length == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.selectedIds.isEmpty
                        ? null
                        : cubit.runSelected,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      'Run ${state.selectedIds.length} test${state.selectedIds.length == 1 ? '' : 's'}',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right: empty placeholder
        Expanded(
          child: Center(
            child: Text(
              'Select tests and press Run',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Error ──────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                context.read<RunnerCubit>().backToReady(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
