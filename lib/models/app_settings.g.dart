// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  llmBaseUrl: json['llmBaseUrl'] as String? ?? AppConstants.defaultLlmBaseUrl,
  llmApiKey: json['llmApiKey'] as String? ?? '',
  llmModel: json['llmModel'] as String? ?? AppConstants.defaultLlmModel,
  browserHeadless: json['browserHeadless'] as bool? ?? false,
  confidenceThreshold: (json['confidenceThreshold'] as num?)?.toDouble() ?? 0.5,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'llmBaseUrl': instance.llmBaseUrl,
      'llmApiKey': instance.llmApiKey,
      'llmModel': instance.llmModel,
      'browserHeadless': instance.browserHeadless,
      'confidenceThreshold': instance.confidenceThreshold,
    };
