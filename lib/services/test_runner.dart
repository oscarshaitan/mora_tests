import 'dart:async';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../models/llm_action.dart';
import '../models/step_result.dart';
import '../models/test_case.dart';
import '../models/test_run.dart';
import '../models/test_step.dart';
import 'http_hook_service.dart';
import 'llm_service.dart';
import 'webview_service.dart';

class TestRunner {
  final WebViewService webViewService;
  final LlmService llmService;
  final HttpHookService httpHookService;

  static const _uuid = Uuid();

  bool _aborted = false;

  TestRunner({
    required this.webViewService,
    required this.llmService,
    required this.httpHookService,
  });

  void abort() => _aborted = true;

  /// Runs a [TestCase] and emits [StepResult]s via [onStepResult].
  /// Returns the completed [TestRun].
  Future<TestRun> run({
    required TestCase testCase,
    required void Function(StepResult) onStepResult,
    bool stopOnFirstFailure = true,
  }) async {
    _aborted = false;

    final run = TestRun(
      id: _uuid.v4(),
      testCaseId: testCase.id,
      testCaseName: testCase.name,
      startedAt: DateTime.now(),
    );

    // 1. Call seeder
    if (testCase.seeder != null) {
      try {
        await httpHookService.call(testCase.seeder!);
      } catch (e) {
        // Seeder failure is non-fatal — log and continue
      }
    }

    try {
      // 2. Navigate to start URL using whatever session state exists.
      await webViewService.navigate(testCase.startUrl);
      await Future.delayed(const Duration(seconds: 1));

      // 3. Run steps
      for (final step in testCase.steps) {
        if (_aborted) break;

        final result = await _runStep(
          step: step,
          variables: testCase.variables,
        );

        onStepResult(result);

        final dur = _formatDuration(result.duration);
        if (result.success) {
          dev.log('PASS ($dur)', name: 'SymUITest');
        } else {
          final reason = result.errorMessage ?? 'unknown error';
          dev.log('FAIL ($dur) — $reason', name: 'SymUITest');
        }

        if (!result.success && stopOnFirstFailure) break;

        await Future.delayed(
          const Duration(milliseconds: AppConstants.settleDelayMs),
        );
      }
    } finally {
      // 4. Always call teardown hook
      if (testCase.teardown != null) {
        try {
          await httpHookService.call(testCase.teardown!);
        } catch (_) {}
      }

      // 5. Clean browser state after every run (pass, fail or abort) so the
      //    next run always starts from a logged-out baseline.
      //    Uses navigate(clean:true): clears cookies, cache, localStorage,
      //    sessionStorage, then reloads — browser ends on the login screen.
      try {
        await webViewService.navigate(testCase.startUrl, clean: true);
      } catch (_) {}
    }

    return run.copyWith(
      status: _aborted ? RunStatus.aborted : RunStatus.completed,
      finishedAt: DateTime.now(),
    );
  }

  Future<StepResult> _runStep({
    required TestStep step,
    required Map<String, String> variables,
  }) async {
    // Explore steps have their own multi-turn loop.
    if (step.maxSubSteps != null) {
      return _runExploreStep(step: step, variables: variables);
    }

    final stopwatch = Stopwatch()..start();
    final instruction = _interpolate(step.instruction, variables);
    final hint = step.hint != null ? _interpolate(step.hint!, variables) : null;
    final assertion =
        step.assertion != null ? _interpolate(step.assertion!, variables) : null;

    dev.log('─' * 56, name: 'SymUITest');
    dev.log('Step: $instruction', name: 'SymUITest');

    String? lastActionName;
    String? lastError;

    for (int attempt = 0; attempt <= AppConstants.maxRetries; attempt++) {
      try {
        // Screenshot before
        final screenshotBefore = await webViewService.screenshot();

        // Ask LLM
        final action = await llmService.interpretStep(
          instruction: instruction,
          screenshot: screenshotBefore,
          hint: hint,
          assertion: assertion,
          previousActionName: lastActionName,
          previousError: lastError,
        );

        lastActionName = action.type.name;

        final conf = '${(action.confidence * 100).toStringAsFixed(0)}%';
        dev.log('LLM: ${_shortenReasoning(action.reasoning)} ($conf)', name: 'SymUITest');

        if (action.type == ActionType.done) {
          final after = await _safeScreenshot();
          return StepResult(
            stepId: step.id,
            success: true,
            actionTaken: action,
            screenshotBefore: screenshotBefore,
            screenshotAfter: after,
            rawLlmResponse: action.reasoning,
            duration: stopwatch.elapsed,
            executedAt: DateTime.now(),
          );
        }

        if (action.type == ActionType.fail) {
          return StepResult(
            stepId: step.id,
            success: false,
            actionTaken: action,
            screenshotBefore: screenshotBefore,
            errorMessage: 'LLM reported failure: ${action.reasoning}',
            rawLlmResponse: action.reasoning,
            duration: stopwatch.elapsed,
            executedAt: DateTime.now(),
          );
        }

        // Execute action
        dev.log(_formatActionLog(action), name: 'SymUITest');
        await webViewService.executeAction(action);
        await Future.delayed(const Duration(milliseconds: 1200));

        // Screenshot after
        final screenshotAfter = await _safeScreenshot();

        return StepResult(
          stepId: step.id,
          success: true,
          actionTaken: action,
          screenshotBefore: screenshotBefore,
          screenshotAfter: screenshotAfter,
          rawLlmResponse: action.reasoning,
          duration: stopwatch.elapsed,
          executedAt: DateTime.now(),
        );
      } catch (e) {
        lastError = e.toString();
        if (attempt == AppConstants.maxRetries) {
          final fallback = await _safeScreenshot();
          return StepResult(
            stepId: step.id,
            success: false,
            screenshotBefore: fallback ?? _emptyPng(),
            errorMessage: lastError,
            duration: stopwatch.elapsed,
            executedAt: DateTime.now(),
          );
        }
        final briefError = lastError.split('\n').first.split(': {').first;
        dev.log(
          '  RETRY ${attempt + 1}/${AppConstants.maxRetries} — $briefError',
          name: 'SymUITest',
        );
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // Unreachable
    throw StateError('Unreachable');
  }

  /// Runs a step in explore / multi-turn mode.
  ///
  /// The LLM is called up to [step.maxSubSteps] times. Each call receives the
  /// current screenshot PLUS the growing history of sub-steps already taken,
  /// so it always knows where it is and what still needs to happen.
  ///
  ///  • LLM returns `done`  → step succeeds (goal reached).
  ///  • LLM returns `fail`  → step fails immediately.
  ///  • All sub-steps used without `done` → step fails with a timeout message.
  Future<StepResult> _runExploreStep({
    required TestStep step,
    required Map<String, String> variables,
  }) async {
    final stopwatch = Stopwatch()..start();
    final instruction = _interpolate(step.instruction, variables);
    final hint = step.hint != null ? _interpolate(step.hint!, variables) : null;
    final assertion =
        step.assertion != null ? _interpolate(step.assertion!, variables) : null;
    final maxSubSteps = step.maxSubSteps!;

    dev.log('─' * 56, name: 'SymUITest');
    dev.log('Explore ($maxSubSteps sub-steps max): $instruction',
        name: 'SymUITest');

    // Capped history: we keep the last 6 entries to bound token usage while
    // still giving the LLM enough context to avoid re-doing completed steps.
    final history = <String>[];
    Uint8List? firstScreenshot;

    for (int sub = 1; sub <= maxSubSteps; sub++) {
      if (_aborted) break;

      try {
        final screenshot = await webViewService.screenshot();
        firstScreenshot ??= screenshot;

        dev.log('  [$sub/$maxSubSteps]', name: 'SymUITest');

        final recentHistory =
            history.length > 6 ? history.sublist(history.length - 6) : history;

        final action = await llmService.interpretStep(
          instruction: instruction,
          screenshot: screenshot,
          hint: hint,
          assertion: assertion,
          subHistory: recentHistory.isEmpty ? null : recentHistory,
        );

        final conf = '${(action.confidence * 100).toStringAsFixed(0)}%';
        dev.log('  LLM: ${_shortenReasoning(action.reasoning)} ($conf)',
            name: 'SymUITest');

        // Goal reached ✓
        if (action.type == ActionType.done) {
          final after = await _safeScreenshot();
          return StepResult(
            stepId: step.id,
            success: true,
            actionTaken: action,
            screenshotBefore: firstScreenshot,
            screenshotAfter: after,
            rawLlmResponse: action.reasoning,
            duration: stopwatch.elapsed,
            executedAt: DateTime.now(),
          );
        }

        // LLM gave up ✗
        if (action.type == ActionType.fail) {
          return StepResult(
            stepId: step.id,
            success: false,
            actionTaken: action,
            screenshotBefore: screenshot,
            errorMessage: 'Explore: LLM reported failure: ${action.reasoning}',
            rawLlmResponse: action.reasoning,
            duration: stopwatch.elapsed,
            executedAt: DateTime.now(),
          );
        }

        // Execute the sub-action
        dev.log('  ${_formatActionLog(action)}', name: 'SymUITest');
        await webViewService.executeAction(action);
        await Future.delayed(
          const Duration(milliseconds: AppConstants.settleDelayMs),
        );

        // Record in history so the LLM sees what was done.
        // "[DONE]" prefix is intentional — it signals to the LLM that this
        // action already succeeded and must not be repeated.
        final coords = (action.x != null && action.y != null)
            ? ' (${action.x!.toStringAsFixed(0)},${action.y!.toStringAsFixed(0)})'
            : '';
        final val =
            action.value != null ? ' value="${action.value}"' : '';
        history.add(
          '[DONE] sub-step $sub: ${action.type.name}$coords$val'
          ' — ${_shortenReasoning(action.reasoning)}',
        );
      } catch (e) {
        // Sub-step errors are non-fatal; log and let the loop continue.
        final brief = e.toString().split('\n').first.split(': {').first;
        dev.log('  [$sub/$maxSubSteps] error: $brief', name: 'SymUITest');
      }
    }

    // Ran out of sub-steps without reaching done
    final fallback = await _safeScreenshot();
    return StepResult(
      stepId: step.id,
      success: false,
      screenshotBefore: firstScreenshot ?? fallback ?? _emptyPng(),
      screenshotAfter: fallback,
      errorMessage:
          'Explore: goal not reached after $maxSubSteps sub-steps',
      duration: stopwatch.elapsed,
      executedAt: DateTime.now(),
    );
  }

  String _formatDuration(Duration d) {
    final s = d.inMilliseconds / 1000.0;
    return '${s.toStringAsFixed(1)}s';
  }

  /// Trims LLM reasoning to the first sentence (or 90 chars) for concise logs.
  String _shortenReasoning(String? reasoning) {
    if (reasoning == null || reasoning.isEmpty) return '—';
    final dot = reasoning.indexOf('.');
    if (dot > 0 && dot < 90) return reasoning.substring(0, dot + 1);
    return reasoning.length > 90 ? '${reasoning.substring(0, 87)}…' : reasoning;
  }

  /// Formats a one-line action log in the agreed style:
  ///   `JS Action: TYPE  val="val"  xy=(x,y)  sel=sel`
  String _formatActionLog(LlmAction action) {
    final type = action.type.name;
    final val  = action.value ?? action.key ?? action.url;
    final xy   = (action.x != null && action.y != null)
        ? '(${action.x!.toStringAsFixed(0)},${action.y!.toStringAsFixed(0)})'
        : 'null';
    final sel  = action.cssSelector ?? 'null';
    final valStr = val != null ? '"$val"' : 'null';
    return 'JS Action: $type  val=$valStr  xy=$xy  sel=$sel';
  }

  String _interpolate(String text, Map<String, String> variables) {
    var result = text;
    for (final entry in variables.entries) {
      result = result.replaceAll('{{${entry.key}}}', entry.value);
    }
    return result;
  }

  Future<Uint8List?> _safeScreenshot() async {
    try {
      return await webViewService.screenshot();
    } catch (_) {
      return null;
    }
  }

  // 1x1 transparent PNG as fallback when screenshot fails
  Uint8List _emptyPng() => Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
        0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0, 144, 119, 83, 222, 0,
        0, 0, 12, 73, 68, 65, 84, 8, 215, 99, 248, 207, 192, 0, 0, 0,
        2, 0, 1, 226, 33, 188, 51, 0, 0, 0, 0, 73, 69, 78, 68, 174,
        66, 96, 130,
      ]);
}
