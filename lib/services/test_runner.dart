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

    final totalSteps = testCase.steps.length;
    dev.log('═' * 56, name: 'SymUITest');
    dev.log('TEST START: ${testCase.name}  ($totalSteps step${totalSteps == 1 ? '' : 's'})',
        name: 'SymUITest');
    dev.log('═' * 56, name: 'SymUITest');

    try {
      // 2. Navigate to start URL using whatever session state exists.
      await webViewService.navigate(testCase.startUrl);
      await Future.delayed(const Duration(seconds: 1));

      // 3. Run steps
      for (int i = 0; i < testCase.steps.length; i++) {
        if (_aborted) break;
        final step = testCase.steps[i];

        final result = await _runStep(
          step: step,
          stepNumber: i + 1,
          totalSteps: totalSteps,
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
      // ── Guaranteed cleanup — runs on pass, fail, abort, and exceptions ──

      // 4. Call teardown hook (e.g. reset DB state)
      if (testCase.teardown != null) {
        try {
          await httpHookService.call(testCase.teardown!);
        } catch (_) {}
      }

      // 5. Clean browser state so the next run always starts from a
      //    logged-out baseline: clears cookies, cache, localStorage,
      //    sessionStorage, then reloads to the start URL.
      dev.log('─' * 56, name: 'SymUITest');
      dev.log('Cleaning browser state…', name: 'SymUITest');
      try {
        await webViewService
            .navigate(testCase.startUrl, clean: true)
            .timeout(const Duration(seconds: 40));
        dev.log('Browser state cleaned ✓', name: 'SymUITest');
      } catch (e) {
        dev.log('Browser clean failed (non-fatal): $e', name: 'SymUITest');
      }
    }

    return run.copyWith(
      status: _aborted ? RunStatus.aborted : RunStatus.completed,
      finishedAt: DateTime.now(),
    );
  }

  Future<StepResult> _runStep({
    required TestStep step,
    required Map<String, String> variables,
    required int stepNumber,
    required int totalSteps,
  }) async {
    // Explore steps have their own multi-turn loop.
    if (step.maxSubSteps != null) {
      return _runExploreStep(
        step: step,
        variables: variables,
        stepNumber: stepNumber,
        totalSteps: totalSteps,
      );
    }

    final stopwatch = Stopwatch()..start();
    final instruction = _interpolate(step.instruction, variables);
    final hint = step.hint != null ? _interpolate(step.hint!, variables) : null;
    final assertion =
        step.assertion != null ? _interpolate(step.assertion!, variables) : null;

    dev.log('─' * 56, name: 'SymUITest');
    dev.log('Step $stepNumber/$totalSteps: $instruction', name: 'SymUITest');

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
    required int stepNumber,
    required int totalSteps,
  }) async {
    final stopwatch = Stopwatch()..start();
    final instruction = _interpolate(step.instruction, variables);
    final hint = step.hint != null ? _interpolate(step.hint!, variables) : null;
    final assertion =
        step.assertion != null ? _interpolate(step.assertion!, variables) : null;
    final maxSubSteps = step.maxSubSteps!;

    dev.log('─' * 56, name: 'SymUITest');
    dev.log('Step $stepNumber/$totalSteps [Explore, $maxSubSteps sub-steps max]: $instruction',
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

        // Repeat-type guard ✓
        // If the LLM proposes typing the same value that already appears in
        // history, the value was already entered — stop immediately.
        // This handles password fields (dots give no visual confirmation) and
        // similar "invisible" inputs. Clicks are excluded: a repeated click
        // means the element didn't respond and the LLM should keep trying.
        if (_isRepeatAction(action, history)) {
          dev.log(
            '  Repeat action detected — goal achieved',
            name: 'SymUITest',
          );
          final after = await _safeScreenshot();
          return StepResult(
            stepId: step.id,
            success: true,
            actionTaken: action,
            screenshotBefore: firstScreenshot,
            screenshotAfter: after,
            rawLlmResponse: 'Goal achieved (repeat-action guard)',
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

        // Record in history using factual past-tense language.
        // Deliberately NOT using action.reasoning (which is forward-looking:
        // "I should type…") — past-tense facts help the LLM correctly read
        // the history as "already done" rather than "about to do".
        history.add(_historyEntry(sub, action));
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

  /// Formats a one-line action log, omitting null fields.
  /// e.g. `JS Action: click  xy=(378,400)` or `JS Action: type  val="hello"`
  String _formatActionLog(LlmAction action) {
    final parts = <String>['JS Action: ${action.type.name}'];

    final val = action.value ?? action.key ?? action.url;
    if (val != null) parts.add('val="$val"');

    if (action.x != null && action.y != null) {
      parts.add(
        'xy=(${action.x!.toStringAsFixed(0)},${action.y!.toStringAsFixed(0)})',
      );
    }

    if (action.cssSelector != null) parts.add('sel=${action.cssSelector}');

    return parts.join('  ');
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

  /// Returns a factual, past-tense history entry for a completed sub-action.
  ///
  /// Past tense ensures the LLM reads history entries as "already done"
  /// rather than "about to do", which prevents repeated actions.
  String _historyEntry(int sub, LlmAction action) {
    final at = (action.x != null && action.y != null)
        ? ' at (${action.x!.toStringAsFixed(0)},${action.y!.toStringAsFixed(0)})'
        : '';
    switch (action.type) {
      case ActionType.type:
        return '[DONE] sub-step $sub: typed "${action.value}" into the focused field.';
      case ActionType.click:
        return '[DONE] sub-step $sub: clicked$at.';
      case ActionType.doubleClick:
        return '[DONE] sub-step $sub: double-clicked$at.';
      case ActionType.longPress:
        return '[DONE] sub-step $sub: long-pressed$at.';
      case ActionType.scroll:
        return '[DONE] sub-step $sub: scrolled (delta_y=${action.scrollDeltaY}).';
      case ActionType.navigate:
        return '[DONE] sub-step $sub: navigated to ${action.url}.';
      case ActionType.pressKey:
        return '[DONE] sub-step $sub: pressed key "${action.key}".';
      case ActionType.hover:
        return '[DONE] sub-step $sub: hovered$at.';
      case ActionType.wait:
        return '[DONE] sub-step $sub: waited ${action.waitMs ?? 0} ms.';
      default:
        final val = action.value != null ? ' "${action.value}"' : '';
        return '[DONE] sub-step $sub: ${action.type.name}$at$val.';
    }
  }

  /// Returns true if [action] is a repeat of something already in [history].
  ///
  /// Only `type` with the same value is treated as a repeat — this covers the
  /// common case where the LLM re-types a password after it was already entered
  /// (password fields show only dots, so the LLM cannot visually confirm the
  /// text was accepted).
  ///
  /// Clicks are intentionally NOT flagged as repeats: a repeated click usually
  /// means the previous tap was not registered by a Flutter/canvas widget and
  /// the LLM is correctly retrying — treating it as "done" would cause the step
  /// to succeed before the actual goal is reached (e.g. before a form is filled
  /// and submitted).
  bool _isRepeatAction(LlmAction action, List<String> history) {
    if (history.isEmpty) return false;
    if (action.type != ActionType.type || action.value == null) return false;
    return history.any((entry) => entry.contains('typed "${action.value}"'));
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
