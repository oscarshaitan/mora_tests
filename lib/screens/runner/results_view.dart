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
  int _selectedRunIndex = 0;

  @override
  Widget build(BuildContext context) {
    final runs = widget.state.runs;
    if (runs.isEmpty) {
      return const Center(child: Text('No runs to display'));
    }

    final run = runs[_selectedRunIndex];

    return Row(
      children: [
        // Left: run list
        SizedBox(
          width: 220,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: context.read<RunnerCubit>().backToReady,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back'),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () => _exportReport(context, runs),
                      icon: const Icon(Icons.file_download_outlined, size: 16),
                      label: Text(
                          'Export HTML (${runs.length})'),
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
                      selected: i == _selectedRunIndex,
                      leading: Icon(
                        r.passed ? Icons.check_circle : Icons.cancel,
                        color: r.passed ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      title: Text(
                        r.testCaseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        '${r.passedCount}/${r.results.length} passed  '
                        '${_formatDuration(r.totalDuration)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () => setState(() => _selectedRunIndex = i),
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

  String _formatDuration(Duration d) {
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

class _RunDetail extends StatelessWidget {
  final TestRun run;
  const _RunDetail({required this.run});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: run.passed ? Colors.green.shade50 : Colors.red.shade50,
          child: Row(
            children: [
              Icon(
                run.passed ? Icons.check_circle : Icons.cancel,
                color: run.passed ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                run.passed ? 'All tests passed' : 'Some tests failed',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              Text(
                '${run.passedCount}/${run.results.length} passed',
                style: Theme.of(context).textTheme.bodySmall,
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
              return _StepResultCard(index: i, result: result);
            },
          ),
        ),
      ],
    );
  }
}

class _StepResultCard extends StatefulWidget {
  final int index;
  final StepResult result;
  const _StepResultCard({required this.index, required this.result});

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
