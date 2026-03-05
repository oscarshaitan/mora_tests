// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_case.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TestCase _$TestCaseFromJson(Map<String, dynamic> json) => _TestCase(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  startUrl: json['startUrl'] as String? ?? '',
  seeder: json['seeder'] == null
      ? null
      : HttpHook.fromJson(json['seeder'] as Map<String, dynamic>),
  teardown: json['teardown'] == null
      ? null
      : HttpHook.fromJson(json['teardown'] as Map<String, dynamic>),
  steps:
      (json['steps'] as List<dynamic>?)
          ?.map((e) => TestStep.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  variables:
      (json['variables'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  status:
      $enumDecodeNullable(_$TestStatusEnumMap, json['status']) ??
      TestStatus.idle,
  filePath: json['filePath'] as String?,
);

Map<String, dynamic> _$TestCaseToJson(_TestCase instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'startUrl': instance.startUrl,
  'seeder': instance.seeder,
  'teardown': instance.teardown,
  'steps': instance.steps,
  'variables': instance.variables,
  'status': _$TestStatusEnumMap[instance.status]!,
  'filePath': instance.filePath,
};

const _$TestStatusEnumMap = {
  TestStatus.idle: 'idle',
  TestStatus.running: 'running',
  TestStatus.passed: 'passed',
  TestStatus.failed: 'failed',
  TestStatus.partial: 'partial',
};
