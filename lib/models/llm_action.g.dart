// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LlmAction _$LlmActionFromJson(Map<String, dynamic> json) => _LlmAction(
  type: $enumDecode(_$ActionTypeEnumMap, json['type']),
  cssSelector: json['cssSelector'] as String?,
  xpathSelector: json['xpathSelector'] as String?,
  x: (json['x'] as num?)?.toDouble(),
  y: (json['y'] as num?)?.toDouble(),
  value: json['value'] as String?,
  url: json['url'] as String?,
  key: json['key'] as String?,
  scrollDeltaX: (json['scrollDeltaX'] as num?)?.toInt(),
  scrollDeltaY: (json['scrollDeltaY'] as num?)?.toInt(),
  waitMs: (json['waitMs'] as num?)?.toInt(),
  expectedText: json['expectedText'] as String?,
  expectedUrl: json['expectedUrl'] as String?,
  confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
  reasoning: json['reasoning'] as String? ?? '',
);

Map<String, dynamic> _$LlmActionToJson(_LlmAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'cssSelector': instance.cssSelector,
      'xpathSelector': instance.xpathSelector,
      'x': instance.x,
      'y': instance.y,
      'value': instance.value,
      'url': instance.url,
      'key': instance.key,
      'scrollDeltaX': instance.scrollDeltaX,
      'scrollDeltaY': instance.scrollDeltaY,
      'waitMs': instance.waitMs,
      'expectedText': instance.expectedText,
      'expectedUrl': instance.expectedUrl,
      'confidence': instance.confidence,
      'reasoning': instance.reasoning,
    };

const _$ActionTypeEnumMap = {
  ActionType.click: 'click',
  ActionType.doubleClick: 'doubleClick',
  ActionType.longPress: 'longPress',
  ActionType.type: 'type',
  ActionType.scroll: 'scroll',
  ActionType.navigate: 'navigate',
  ActionType.wait: 'wait',
  ActionType.hover: 'hover',
  ActionType.pressKey: 'pressKey',
  ActionType.selectOption: 'selectOption',
  ActionType.assert_text: 'assert_text',
  ActionType.assert_url: 'assert_url',
  ActionType.assert_visible: 'assert_visible',
  ActionType.done: 'done',
  ActionType.fail: 'fail',
};
