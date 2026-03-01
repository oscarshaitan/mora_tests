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
  sl.registerLazySingleton<LlmService>(() {
    final s = sl<AppSettings>();
    return LlmService(
      baseUrl: s.llmBaseUrl,
      apiKey: s.llmApiKey,
      model: s.llmModel,
      fallbackModel: s.llmFallbackModel,
    );
  });

  // WebViewService: factory (each Runner screen gets its own instance)
  sl.registerFactory<WebViewService>(() => WebViewService(sl<JsBuilder>()));
}

/// Re-registers [LlmService] after settings change (call from SettingsCubit).
void refreshLlmService(AppSettings settings) {
  if (sl.isRegistered<LlmService>()) sl.unregister<LlmService>();
  sl.registerLazySingleton<LlmService>(() => LlmService(
        baseUrl: settings.llmBaseUrl,
        apiKey: settings.llmApiKey,
        model: settings.llmModel,
        fallbackModel: settings.llmFallbackModel,
      ));
}
