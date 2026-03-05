import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/step_result.dart';
import '../../models/test_case.dart';
import '../../models/test_run.dart';
import '../../models/test_step.dart';

part 'runner_state.freezed.dart';

@freezed
sealed class RunnerState with _$RunnerState {
  const factory RunnerState.idle() = RunnerIdle;

  const factory RunnerState.ready({
    required List<TestCase> testCases,
    required List<String> selectedIds,
    String? sourcePath,
  }) = RunnerReady;

  const factory RunnerState.running({
    required TestCase currentTest,
    required List<StepResult> completedSteps,
    required TestStep activeStep,
    required int stepIndex,
    required int totalSteps,
    String? lastLlmReasoning,
    double? lastLlmConfidence,
    String? lastActionName,
    // Sub-test progress (non-null while a call step is executing)
    TestCase? activeSubTest,
    @Default([]) List<StepResult> completedSubSteps,
    @Default(0) int subStepIndex,
    int? totalSubSteps,
  }) = RunnerRunning;

  const factory RunnerState.finished({
    required List<TestRun> runs,
    required List<TestCase> testCases,
    required List<String> selectedIds,
    @Default(0) int selectedRunIndex,
  }) = RunnerFinished;

  const factory RunnerState.error(String message) = RunnerError;
}
