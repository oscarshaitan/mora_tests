// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_hook.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HttpHook _$HttpHookFromJson(Map<String, dynamic> json) => _HttpHook(
  url: json['url'] as String,
  method: json['method'] as String? ?? 'POST',
  headers:
      (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  body: json['body'] as String?,
  timeoutSeconds: (json['timeoutSeconds'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$HttpHookToJson(_HttpHook instance) => <String, dynamic>{
  'url': instance.url,
  'method': instance.method,
  'headers': instance.headers,
  'body': instance.body,
  'timeoutSeconds': instance.timeoutSeconds,
};
