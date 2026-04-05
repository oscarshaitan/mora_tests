import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../cubits/builder/builder_cubit.dart';
import '../../cubits/builder/builder_state.dart';
import '../../models/test_case.dart';
import '../../services/webview_service.dart';
import 'test_form.dart';

class BuilderScreen extends StatelessWidget {
  const BuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuilderCubit, BuilderState>(
      builder: (context, state) {
        return Row(
          children: [
            // Left: Test List
            SizedBox(
              width: 240,
              child: _TestList(state: state),
            ),
            const VerticalDivider(width: 1),
            // Center: Editor
            Expanded(
              flex: 2,
              child: state.selectedTest != null
                  ? TestForm(test: state.selectedTest!)
                  : const _EmptyEditor(),
            ),
            const VerticalDivider(width: 1),
            // Right: Live WebView preview
            Expanded(
              flex: 3,
              child: state.selectedTest != null
                  ? _BuilderWebViewPanel(test: state.selectedTest!)
                  : const _EmptyWebView(),
            ),
          ],
        );
      },
    );
  }
}

class _TestList extends StatelessWidget {
  final BuilderState state;
  const _TestList({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuilderCubit>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: cubit.createNewTest,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Test'),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.folder_open),
                tooltip: 'Open YAML file',
                onPressed: cubit.openFile,
              ),
              PopupMenuButton<_ImportOption>(
                icon: const Icon(Icons.transform_outlined),
                tooltip: 'Import from Maestro',
                onSelected: (opt) {
                  if (opt == _ImportOption.file) cubit.importFromMaestro();
                  if (opt == _ImportOption.folder) cubit.importFromMaestroFolder();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _ImportOption.file,
                    child: ListTile(
                      leading: Icon(Icons.insert_drive_file_outlined),
                      title: Text('Import Maestro file'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  PopupMenuItem(
                    value: _ImportOption.folder,
                    child: ListTile(
                      leading: Icon(Icons.folder_copy_outlined),
                      title: Text('Import Maestro folder'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: state.testCases.length,
            itemBuilder: (context, i) {
              final test = state.testCases[i];
              final selected = state.selectedTest?.id == test.id;
              final incompleteCount = test.steps.where((s) {
                if (s.call != null) return s.call!.trim().isEmpty;
                return s.instruction.trim().isEmpty;
              }).length;
              final coordCount = test.steps
                  .where((s) => s.instruction.contains('coordinate '))
                  .length;
              final hasIncomplete = incompleteCount > 0;
              final hasCoordWarning = !hasIncomplete && coordCount > 0;
              final cs = Theme.of(context).colorScheme;
              return ListTile(
                selected: selected,
                title: Text(
                  test.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  hasIncomplete
                      ? '$incompleteCount incomplete step${incompleteCount == 1 ? '' : 's'}'
                      : hasCoordWarning
                          ? '$coordCount coordinate step${coordCount == 1 ? '' : 's'} need review'
                          : '${test.steps.length} step${test.steps.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasIncomplete
                        ? cs.error
                        : hasCoordWarning
                            ? Colors.amber.shade800
                            : null,
                  ),
                ),
                leading: hasIncomplete
                    ? Icon(Icons.error_outline, size: 18, color: cs.error)
                    : hasCoordWarning
                        ? Icon(Icons.warning_amber_rounded,
                            size: 18, color: Colors.amber.shade700)
                        : null,
                onTap: () => cubit.selectTest(test),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _confirmDelete(context, cubit, test),
                ),
              );
            },
          ),
        ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.error, width: 1),
                ),
                icon: const Icon(Icons.warning_amber_rounded, size: 16),
                label: Text(_issueButtonLabel(state.errorMessage!)),
                onPressed: () =>
                    _showIssues(context, state.errorMessage!),
              ),
            ),
          ),
      ],
    );
  }

  String _issueButtonLabel(String errorMessage) {
    final count = '\n'.allMatches(errorMessage).length + 1;
    return '$count translation issue${count == 1 ? '' : 's'}';
  }

  void _showIssues(BuildContext context, String errorMessage) {
    final issues = errorMessage.split('\n');
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error, size: 20),
            const SizedBox(width: 8),
            const Text('Translation Issues'),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: issues.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(issues[i].trim(),
                  style: const TextStyle(fontSize: 13)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    BuilderCubit cubit,
    TestCase test,
  ) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete test?'),
        content: Text('Delete "${test.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) cubit.deleteTest(test.id);
    });
  }
}

enum _ImportOption { file, folder }

// ── Builder WebView panel ────────────────────────────────────────────────────

class _BuilderWebViewPanel extends StatelessWidget {
  final TestCase test;
  const _BuilderWebViewPanel({required this.test});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuilderCubit>();
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Toolbar with viewport info and navigate button
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            border: Border(bottom: BorderSide(color: cs.outlineVariant)),
          ),
          child: Row(
            children: [
              Icon(Icons.web, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                '${test.viewportWidth} x ${test.viewportHeight}',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: cubit.navigateToStartUrl,
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Navigate'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        // WebView constrained to viewport dimensions
        Expanded(
          child: Center(
            child: Container(
              width: test.viewportWidth.toDouble(),
              height: test.viewportHeight.toDouble(),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outlineVariant),
              ),
              child: _BuilderInAppWebView(
                webViewService: cubit.webViewService,
                onReady: cubit.onWebViewReady,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BuilderInAppWebView extends StatelessWidget {
  final WebViewService webViewService;
  final VoidCallback onReady;

  const _BuilderInAppWebView({
    required this.webViewService,
    required this.onReady,
  });

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        useHybridComposition: true,
      ),
      onWebViewCreated: (controller) {
        webViewService.attach(controller);
        onReady();
      },
      onLoadStop: (controller, url) {
        webViewService.notifyLoadStop();
      },
      onReceivedError: (controller, request, error) {
        webViewService.notifyLoadStop();
      },
    );
  }
}

// ── Empty states ─────────────────────────────────────────────────────────────

class _EmptyEditor extends StatelessWidget {
  const _EmptyEditor();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_note,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Select or create a test to edit',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWebView extends StatelessWidget {
  const _EmptyWebView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.web_outlined, size: 56, color: cs.outlineVariant),
          const SizedBox(height: 12),
          Text(
            'Live preview will appear here',
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a test to start the browser',
            style: TextStyle(fontSize: 12, color: cs.outlineVariant),
          ),
        ],
      ),
    );
  }
}
