import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/builder/builder_cubit.dart';
import '../../cubits/runner/runner_cubit.dart';
import '../../cubits/runner/runner_state.dart';
import '../../models/test_case.dart';
import 'results_view.dart';
import 'run_view.dart';

class RunnerScreen extends StatelessWidget {
  final VoidCallback? onSwitchToBuilder;
  const RunnerScreen({super.key, this.onSwitchToBuilder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RunnerCubit, RunnerState>(
      builder: (context, state) {
        return switch (state) {
          RunnerIdle() => const _IdleView(),
          RunnerReady() => _ReadyView(
              state: state, onSwitchToBuilder: onSwitchToBuilder),
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
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline_rounded,
              size: 72, color: cs.outlineVariant),
          const SizedBox(height: 16),
          Text('Open a test file or folder to get started',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Or view previous runs from History',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 28),
          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: cubit.openFolder,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('Open Folder'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: cubit.openFile,
                  icon: const Icon(Icons.insert_drive_file_outlined, size: 18),
                  label: const Text('Open File'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: cubit.loadHistory,
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('History'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ready ──────────────────────────────────────────────────────────────────

class _ReadyView extends StatelessWidget {
  final RunnerReady state;
  final VoidCallback? onSwitchToBuilder;
  const _ReadyView({required this.state, this.onSwitchToBuilder});

  static bool _hasIncomplete(TestCase tc) => tc.steps.any((s) {
        if (s.call != null) return s.call!.trim().isEmpty;
        return s.instruction.trim().isEmpty;
      });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RunnerCubit>();
    final cs = Theme.of(context).colorScheme;

    // Tests that are selected AND have incomplete steps
    final incompleteSelected = state.testCases
        .where((tc) =>
            state.selectedIds.contains(tc.id) && _hasIncomplete(tc))
        .toList();

    return Row(
      children: [
        // Left: test list
        SizedBox(
          width: 260,
          child: Column(
            children: [
              // Incomplete steps warning
              if (incompleteSelected.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  color: cs.errorContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline,
                              size: 14, color: cs.onErrorContainer),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${incompleteSelected.length} selected test${incompleteSelected.length == 1 ? '' : 's'} have incomplete steps',
                              style: TextStyle(
                                  fontSize: 11, color: cs.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                      ...incompleteSelected.map((tc) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    tc.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onErrorContainer),
                                  ),
                                ),
                                if (tc.filePath != null)
                                  InkWell(
                                    onTap: () {
                                      context
                                          .read<BuilderCubit>()
                                          .openFileByPath(tc.filePath!);
                                      onSwitchToBuilder?.call();
                                    },
                                    child: Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onErrorContainer,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
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
        // Right: empty state placeholder
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.monitor_outlined,
                  size: 56,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'Select tests and press Run',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'The live browser will appear here during execution',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ],
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
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 18, color: cs.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style:
                          TextStyle(color: cs.onErrorContainer, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: context.read<RunnerCubit>().backToReady,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
