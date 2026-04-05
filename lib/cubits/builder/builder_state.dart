import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/llm_action.dart';
import '../../models/test_case.dart';

part 'builder_state.freezed.dart';

@freezed
abstract class BuilderState with _$BuilderState {
  const factory BuilderState({
    @Default([]) List<TestCase> testCases,
    TestCase? selectedTest,
    @Default(false) bool isDirty,
    String? savedPath,
    String? errorMessage,

    // ── Coop builder mode ─────────────────────────────────────────────
    /// Whether the builder's WebView is attached and ready.
    @Default(false) bool webViewReady,

    /// Step ID currently being resolved (AI call in progress).
    String? resolvingStepId,

    /// AI-suggested action awaiting user accept/reject.
    LlmAction? pendingAction,

    /// Which step the [pendingAction] belongs to.
    String? pendingStepId,
  }) = _BuilderState;
}
