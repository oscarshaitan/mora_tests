import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'llm_action.dart';

part 'step_result.freezed.dart';

// Uint8List is not JSON-serializable by default, so no fromJson here.
@freezed
abstract class StepResult with _$StepResult {
  const factory StepResult({
    required String stepId,
    required bool success,
    LlmAction? actionTaken,
    required Uint8List screenshotBefore,
    Uint8List? screenshotAfter,
    String? errorMessage,
    String? rawLlmResponse,
    required Duration duration,
    required DateTime executedAt,
  }) = _StepResult;
}
