import 'package:freezed_annotation/freezed_annotation.dart';

import 'step_result.dart';

part 'test_run.freezed.dart';

enum RunStatus { running, completed, aborted }

@freezed
abstract class TestRun with _$TestRun {
  const factory TestRun({
    required String id,
    required String testCaseId,
    required String testCaseName,
    required DateTime startedAt,
    DateTime? finishedAt,
    @Default(RunStatus.running) RunStatus status,
    @Default([]) List<StepResult> results,
  }) = _TestRun;

  const TestRun._();

  bool get passed =>
      status == RunStatus.completed && results.every((r) => r.success);

  int get passedCount => results.where((r) => r.success).length;

  int get failedCount => results.where((r) => !r.success).length;

  Duration get totalDuration =>
      (finishedAt ?? DateTime.now()).difference(startedAt);
}
