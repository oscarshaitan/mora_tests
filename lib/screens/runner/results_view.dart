import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

import '../../cubits/runner/runner_cubit.dart';
import '../../cubits/runner/runner_state.dart';
import '../../models/step_result.dart';
import '../../models/test_run.dart';
import '../../services/report_service.dart';
import '../../widgets/screenshot_panel.dart';

class ResultsView extends StatefulWidget {
  final RunnerFinished state;
  const ResultsView({super.key, required this.state});

  @override
  State<ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView> {
  @override
  Widget build(BuildContext context) {
    final runs = widget.state.runs;
    if (runs.isEmpty) {
      return const Center(child: Text('No runs to display'));
    }

    // Clamp in case the runs list shrank since the index was stored.
    final selectedIndex =
        widget.state.selectedRunIndex.clamp(0, runs.length - 1);
    final run = runs[selectedIndex];
    final cubit = context.read<RunnerCubit>();

    return Row(
      children: [
        // Left: run list
        SizedBox(
          width: 230,
          child: Column(
            children: [
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: cubit.backToReady,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back'),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () => _exportReport(context, runs),
                      icon: const Icon(Icons.file_download_outlined, size: 16),
                      label: Text('Export HTML (${runs.length})'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: runs.length,
                  itemBuilder: (context, i) {
                    final r = runs[i];
                    return ListTile(
                      selected: i == selectedIndex,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.25),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      leading: Icon(
                        r.passed ? Icons.check_circle : Icons.cancel,
                        color: r.passed
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        size: 20,
                      ),
                      title: Text(
                        r.testCaseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        '${r.passedCount}/${r.results.length} passed'
                        '  ·  ${_fmtDuration(r.totalDuration)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () => cubit.selectRun(i),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right: run detail
        Expanded(
          child: _RunDetail(run: run),
        ),
      ],
    );
  }

  String _fmtDuration(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  }

  // ── HTML export ────────────────────────────────────────────────────────────

  Future<void> _exportReport(
      BuildContext context, List<TestRun> runs) async {
    if (runs.isEmpty) return;

    final now = DateTime.now();
    final suggested =
        'mora_report_${now.year}-${_pad(now.month)}-${_pad(now.day)}'
        '_${_pad(now.hour)}-${_pad(now.minute)}.html';

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save HTML report',
      fileName: suggested,
      type: FileType.custom,
      allowedExtensions: ['html'],
    );
    if (savePath == null || !context.mounted) return;

    try {
      // Image compression is CPU-intensive; run synchronously (fast enough
      // for typical test suites; isolate can be added later if needed).
      final html = ReportService.generateHtml(runs);
      await File(savePath).writeAsString(html);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report saved: ${p.basename(savePath)}'),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

String _fmtDuration(Duration d) {
  if (d.inSeconds < 60) return '${d.inSeconds}s';
  return '${d.inMinutes}m ${d.inSeconds % 60}s';
}

class _RunDetail extends StatelessWidget {
  final TestRun run;
  const _RunDetail({required this.run});

  @override
  Widget build(BuildContext context) {
    final passColor = run.passed ? Colors.green.shade700 : Colors.red.shade700;
    final passBg =
        run.passed ? Colors.green.shade50 : Colors.red.shade50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: passBg,
            border: Border(
              bottom: BorderSide(
                  color: run.passed
                      ? Colors.green.shade200
                      : Colors.red.shade200),
            ),
          ),
          child: Row(
            children: [
              Icon(
                run.passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: passColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                run.passed ? 'All steps passed' : 'Some steps failed',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: passColor),
              ),
              const Spacer(),
              Text(
                '${run.passedCount}/${run.results.length} steps'
                '  ·  ${_fmtDuration(run.totalDuration)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: passColor),
              ),
            ],
          ),
        ),
        // Step results
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: run.results.length,
            itemBuilder: (context, i) {
              final result = run.results[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepResultCard(index: i, result: result),
                  if (result.subStepResults.isNotEmpty)
                    _SubStepResults(results: result.subStepResults),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SubStepResults extends StatelessWidget {
  final List<StepResult> results;
  const _SubStepResults({required this.results});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.subdirectory_arrow_right,
                  size: 13, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                '${results.length} sub-step${results.length == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...results.asMap().entries.map((e) =>
              _StepResultCard(index: e.key, result: e.value, compact: true)),
        ],
      ),
    );
  }
}

class _StepResultCard extends StatefulWidget {
  final int index;
  final StepResult result;
  final bool compact;
  const _StepResultCard(
      {required this.index, required this.result, this.compact = false});

  @override
  State<_StepResultCard> createState() => _StepResultCardState();
}

class _StepResultCardState extends State<_StepResultCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final color = result.success ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              result.success ? Icons.check_circle : Icons.cancel,
              color: color,
              size: 20,
            ),
            title: Text('Step ${widget.index + 1}',
                style: const TextStyle(fontSize: 13)),
            subtitle: result.errorMessage != null
                ? Text(result.errorMessage!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12))
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (result.actionTaken != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      result.actionTaken!.type.name,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  _formatMs(result.duration.inMilliseconds),
                  style: const TextStyle(fontSize: 11),
                ),
                IconButton(
                  icon: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result.actionTaken?.reasoning.isNotEmpty == true) ...[
                    Text('Reasoning',
                        style: Theme.of(context).textTheme.labelMedium),
                    Text(result.actionTaken!.reasoning,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (result.screenshotBefore.isNotEmpty)
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Before',
                                  style: TextStyle(fontSize: 11)),
                              const SizedBox(height: 4),
                              ScreenshotPanel(bytes: result.screenshotBefore),
                            ],
                          ),
                        ),
                      if (result.screenshotAfter != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('After',
                                  style: TextStyle(fontSize: 11)),
                              const SizedBox(height: 4),
                              ScreenshotPanel(bytes: result.screenshotAfter!),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatMs(int ms) {
    if (ms < 1000) return '${ms}ms';
    return '${(ms / 1000).toStringAsFixed(1)}s';
  }
}
