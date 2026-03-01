import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/constants.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(AppConstants.defaultLlmBaseUrl) String llmBaseUrl,
    @Default('') String llmApiKey,
    @Default(AppConstants.defaultLlmModel) String llmModel,
    @Default(AppConstants.mistralModel) String llmFallbackModel,
    @Default(false) bool browserHeadless,
    @Default(0.5) double confidenceThreshold,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, Object?> json) =>
      _$AppSettingsFromJson(json);
}
