// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TestStep _$TestStepFromJson(Map<String, dynamic> json) => _TestStep(
  id: json['id'] as String,
  instruction: json['instruction'] as String,
  hint: json['hint'] as String?,
  assertion: json['assertion'] as String?,
  timeoutSeconds: (json['timeoutSeconds'] as num?)?.toInt() ?? 30,
  maxSubSteps: (json['maxSubSteps'] as num?)?.toInt() ?? null,
);

Map<String, dynamic> _$TestStepToJson(_TestStep instance) => <String, dynamic>{
  'id': instance.id,
  'instruction': instance.instruction,
  'hint': instance.hint,
  'assertion': instance.assertion,
  'timeoutSeconds': instance.timeoutSeconds,
  'maxSubSteps': instance.maxSubSteps,
};
