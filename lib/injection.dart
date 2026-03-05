import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/app_settings.dart';
import 'services/http_hook_service.dart';
import 'services/js_builder.dart';
import 'services/llm_service.dart';
import 'services/storage_service.dart';
import 'services/webview_service.dart';

final sl = GetIt.instance;

Future<void> setupInjection() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Load persisted settings or use defaults
  final settingsJson = prefs.getString('app_settings');
  AppSettings settings;
  if (settingsJson != null) {
    try {
      settings = AppSettings.fromJson(
        Map<String, Object?>.from(
          jsonDecode(settingsJson) as Map,
        ),
      );
    } catch (_) {
      settings = const AppSettings();
    }
  } else {
    settings = const AppSettings();
  }

  sl.registerSingleton<AppSettings>(settings);

  // Stateless services (singletons)
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<HttpHookService>(() => HttpHookService());
  sl.registerLazySingleton<JsBuilder>(() => JsBuilder());

  // LlmService reads from AppSettings singleton
  sl.registerLazySingleton<LlmService>(() => _buildLlmService(sl<AppSettings>()));

  // WebViewService: factory (each Runner screen gets its own instance)
  sl.registerFactory<WebViewService>(() => WebViewService(sl<JsBuilder>()));
}

LlmService _buildLlmService(AppSettings s) {
  final isVertex = s.activeProvider == 'vertexAi';
  return LlmService(
    baseUrl: isVertex ? s.vertexAiBaseUrl : s.ovhBaseUrl,
    apiKey: isVertex ? '' : s.ovhApiKey,
    serviceAccountJson: isVertex ? s.vertexAiServiceAccountJson : null,
    model: isVertex ? s.vertexAiPrimaryModel : s.ovhPrimaryModel,
    fallbackModel: isVertex ? s.vertexAiFallbackModel : s.ovhFallbackModel,
  );
}

/// Re-registers [LlmService] after settings change (call from SettingsCubit).
void refreshLlmService(AppSettings settings) {
  if (sl.isRegistered<LlmService>()) sl.unregister<LlmService>();
  sl.registerLazySingleton<LlmService>(() => _buildLlmService(settings));
}
