import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/constants.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    // Which provider the test runner uses
    @Default('ovh') String activeProvider,

    // OVH AI
    @Default(AppConstants.defaultLlmBaseUrl) String ovhBaseUrl,
    @Default('') String ovhApiKey,
    @Default(AppConstants.defaultLlmModel) String ovhPrimaryModel,
    @Default(AppConstants.mistralModel) String ovhFallbackModel,

    // Vertex AI
    @Default(AppConstants.vertexAiBaseUrl) String vertexAiBaseUrl,
    @Default('') String vertexAiApiKey,
    @Default(AppConstants.geminiFlashModel) String vertexAiPrimaryModel,
    @Default(AppConstants.geminiFlashLiteModel) String vertexAiFallbackModel,

    @Default(false) bool browserHeadless,
    @Default(0.5) double confidenceThreshold,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, Object?> json) =>
      _$AppSettingsFromJson(json);
}
