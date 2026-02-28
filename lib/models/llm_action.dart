import 'package:freezed_annotation/freezed_annotation.dart';

part 'llm_action.freezed.dart';
part 'llm_action.g.dart';

enum ActionType {
  click,
  doubleClick,
  longPress,
  type,
  scroll,
  navigate,
  wait,
  hover,
  pressKey,
  selectOption,
  // ignore: constant_identifier_names
  assert_text,
  // ignore: constant_identifier_names
  assert_url,
  // ignore: constant_identifier_names
  assert_visible,
  done,
  fail,
}

@freezed
abstract class LlmAction with _$LlmAction {
  const factory LlmAction({
    required ActionType type,
    String? cssSelector,
    String? xpathSelector,
    double? x,
    double? y,
    String? value,
    String? url,
    String? key,
    int? scrollDeltaX,
    int? scrollDeltaY,
    int? waitMs,
    String? expectedText,
    String? expectedUrl,
    @Default(1.0) double confidence,
    @Default('') String reasoning,
  }) = _LlmAction;

  factory LlmAction.fromJson(Map<String, Object?> json) =>
      _$LlmActionFromJson(json);
}
