import 'package:freezed_annotation/freezed_annotation.dart';

import 'llm_action.dart';

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
    /// Path to another YAML test file to run inline as a sub-test (relative
    /// to the calling file's directory). When set, [instruction] is unused.
    @Default(null) String? call,
    /// Variable overrides passed into the sub-test. Merged on top of the
    /// sub-test's own `variables` block, so callers can supply values like
    /// username/password without editing the sub-test file.
    @Default({}) Map<String, String> withVars,
    /// Pre-computed action resolved during coop builder mode.
    /// When set, the runner executes this action directly without an LLM call.
    @Default(null) LlmAction? resolvedAction,
  }) = _TestStep;

  factory TestStep.fromJson(Map<String, Object?> json) =>
      _$TestStepFromJson(json);
}
