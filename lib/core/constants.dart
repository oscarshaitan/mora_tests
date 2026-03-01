class AppConstants {
  AppConstants._();

  static const String defaultLlmBaseUrl =
      'https://oai.endpoints.kepler.ai.cloud.ovh.net/v1';
  static const String defaultLlmModel = 'Qwen2.5-VL-72B-Instruct';
  static const String mistralModel = 'Mistral-Small-3.2-24B-Instruct-2506';
  static const double defaultTemperature = 0.1;
  static const int defaultMaxTokens = 512;
  static const int defaultStepTimeoutSeconds = 30;
  static const int maxRetries = 2;
  static const int rateLimitDelaySeconds = 10;
  static const int settleDelayMs = 1500;
  static const int postActionDelayMs = 1200;
  static const int exploreHistorySize = 6;
  static const String testFileExtension = '.yaml';
}
