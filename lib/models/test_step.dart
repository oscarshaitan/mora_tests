import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_step.freezed.dart';
part 'test_step.g.dart';

@freezed
abstract class TestStep with _$TestStep {
  const factory TestStep({
    required String id,
    required String instruction,
    String? hint,
    String? assertion,
    @Default(30) int timeoutSeconds,
  }) = _TestStep;

  factory TestStep.fromJson(Map<String, Object?> json) =>
      _$TestStepFromJson(json);
}
