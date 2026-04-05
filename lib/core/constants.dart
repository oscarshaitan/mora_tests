enum LlmProvider { ovh, vertexAi }

class AppConstants {
  AppConstants._();

  // OVH
  static const String defaultLlmBaseUrl =
      'https://oai.endpoints.kepler.ai.cloud.ovh.net/v1';
  static const String defaultLlmModel = 'Qwen2.5-VL-72B-Instruct';
  static const String mistralModel = 'Mistral-Small-3.2-24B-Instruct-2506';

  // Vertex AI (OpenAI-compatible endpoint)
  static const String vertexAiBaseUrl =
      'https://us-central1-aiplatform.googleapis.com/v1beta1/projects/YOUR_PROJECT_ID/locations/us-central1/endpoints/openapi';
  static const String geminiFlashModel = 'google/gemini-2.5-flash';
  static const String geminiFlashLiteModel = 'google/gemini-3.1-flash-lite';

  static const double defaultTemperature = 0.1;
  static const int defaultMaxTokens = 512;
  static const int defaultStepTimeoutSeconds = 30;
  static const int maxRetries = 2;
  static const int rateLimitDelaySeconds = 10;
  static const int settleDelayMs = 1500;
  static const int postActionDelayMs = 1200;
  static const String testFileExtension = '.yaml';
}
