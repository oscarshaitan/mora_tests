class LlmException implements Exception {
  final String message;
  const LlmException(this.message);

  @override
  String toString() => 'LlmException: $message';
}

class HookException implements Exception {
  final String message;
  const HookException(this.message);

  @override
  String toString() => 'HookException: $message';
}

class WebViewException implements Exception {
  final String message;
  const WebViewException(this.message);

  @override
  String toString() => 'WebViewException: $message';
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
