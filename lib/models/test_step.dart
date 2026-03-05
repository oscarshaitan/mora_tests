import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_step.freezed.dart';
part 'test_step.g.dart';

@freezed
abstract class TestStep with _$TestStep {
  const factory TestStep({
    required String id,
    @Default('') String instruction,
    String? hint,
    String? assertion,
    @Default(30) int timeoutSeconds,
    /// When set, the step runs as an explore/multi-turn loop.
    /// The LLM will take up to [maxSubSteps] individual actions (click, scroll,
    /// type, navigate, etc.) until it decides the goal is reached (done) or
    /// gives up (fail). Useful for vague navigation instructions like
    /// "go to Company X → Programme Y → Project Z".
    @Default(null) int? maxSubSteps,
    /// Path to another YAML test file to run inline as a sub-test (relative
    /// to the calling file's directory). When set, [instruction] is unused.
    @Default(null) String? call,
    /// Variable overrides passed into the sub-test. Merged on top of the
    /// sub-test's own `variables` block, so callers can supply values like
    /// username/password without editing the sub-test file.
    @Default({}) Map<String, String> withVars,
  }) = _TestStep;

  factory TestStep.fromJson(Map<String, Object?> json) =>
      _$TestStepFromJson(json);
}
