import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../cubits/runner/runner_cubit.dart';
import '../../cubits/runner/runner_state.dart';
import '../../models/step_result.dart';
import '../../services/webview_service.dart';
import '../../widgets/step_card.dart';

class RunView extends StatelessWidget {
  final RunnerRunning state;
  const RunView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RunnerCubit>();

    return Row(
      children: [
        // Left: side panel (step list + info)
        SizedBox(
          width: 300,
          child: Column(
            children: [
              // Header
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.currentTest.name,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: cubit.abort,
                      icon: const Icon(Icons.stop, size: 16),
                      label: const Text('Stop'),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress
              LinearProgressIndicator(
                value: state.totalSteps > 0
                    ? (state.stepIndex + 1) / state.totalSteps
                    : null,
              ),
              // Step list
              Expanded(
                child: ListView.builder(
                  itemCount: state.currentTest.steps.length,
                  itemBuilder: (context, i) {
                    final step = state.currentTest.steps[i];
                    StepCardStatus status;
                    StepResult? result;

                    if (i < state.completedSteps.length) {
                      result = state.completedSteps[i];
                      status = result.success
                          ? StepCardStatus.passed
                          : StepCardStatus.failed;
                    } else if (i == state.stepIndex) {
                      status = StepCardStatus.running;
                    } else {
                      status = StepCardStatus.pending;
                    }

                    return StepCard(
                      index: i,
                      step: step,
                      status: status,
                      result: result,
                    );
                  },
                ),
              ),
              // Action detail panel
              if (state.lastLlmReasoning != null) ...[
                const Divider(height: 1),
                _ActionDetail(state: state),
              ],
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right: live WebView — uses the cubit's shared WebViewService instance
        Expanded(
          child: _WebViewPanel(webViewService: cubit.webViewService),
        ),
      ],
    );
  }
}

class _ActionDetail extends StatelessWidget {
  final RunnerRunning state;
  const _ActionDetail({required this.state});

  @override
  Widget build(BuildContext context) {
    final confidence = state.lastLlmConfidence;
    final confidenceText =
        confidence != null ? '${(confidence * 100).toStringAsFixed(0)}%' : '';

    return Container(
      padding: const EdgeInsets.all(10),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.lastActionName != null)
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    state.lastActionName!,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const Spacer(),
                if (confidenceText.isNotEmpty)
                  Text(
                    'Confidence: $confidenceText',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          if (state.lastLlmReasoning != null &&
              state.lastLlmReasoning!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              state.lastLlmReasoning!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _WebViewPanel extends StatelessWidget {
  final WebViewService webViewService;
  const _WebViewPanel({required this.webViewService});

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
      },
      onLoadStop: (controller, url) {
        webViewService.notifyLoadStop();
      },
      onReceivedError: (controller, request, error) {
        // Still notify so navigate() doesn't hang on error pages
        webViewService.notifyLoadStop();
      },
    );
  }
}
