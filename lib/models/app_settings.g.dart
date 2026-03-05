// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  activeProvider: json['activeProvider'] as String? ?? 'ovh',
  ovhBaseUrl: json['ovhBaseUrl'] as String? ?? AppConstants.defaultLlmBaseUrl,
  ovhApiKey: json['ovhApiKey'] as String? ?? '',
  ovhPrimaryModel:
      json['ovhPrimaryModel'] as String? ?? AppConstants.defaultLlmModel,
  ovhFallbackModel:
      json['ovhFallbackModel'] as String? ?? AppConstants.mistralModel,
  vertexAiBaseUrl:
      json['vertexAiBaseUrl'] as String? ?? AppConstants.vertexAiBaseUrl,
  vertexAiApiKey: json['vertexAiApiKey'] as String? ?? '',
  vertexAiPrimaryModel:
      json['vertexAiPrimaryModel'] as String? ?? AppConstants.geminiFlashModel,
  vertexAiFallbackModel:
      json['vertexAiFallbackModel'] as String? ??
      AppConstants.geminiFlashLiteModel,
  browserHeadless: json['browserHeadless'] as bool? ?? false,
  confidenceThreshold:
      (json['confidenceThreshold'] as num?)?.toDouble() ?? 0.5,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'activeProvider': instance.activeProvider,
      'ovhBaseUrl': instance.ovhBaseUrl,
      'ovhApiKey': instance.ovhApiKey,
      'ovhPrimaryModel': instance.ovhPrimaryModel,
      'ovhFallbackModel': instance.ovhFallbackModel,
      'vertexAiBaseUrl': instance.vertexAiBaseUrl,
      'vertexAiApiKey': instance.vertexAiApiKey,
      'vertexAiPrimaryModel': instance.vertexAiPrimaryModel,
      'vertexAiFallbackModel': instance.vertexAiFallbackModel,
      'browserHeadless': instance.browserHeadless,
      'confidenceThreshold': instance.confidenceThreshold,
    };
