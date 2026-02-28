import 'package:freezed_annotation/freezed_annotation.dart';

part 'http_hook.freezed.dart';
part 'http_hook.g.dart';

@freezed
abstract class HttpHook with _$HttpHook {
  const factory HttpHook({
    required String url,
    @Default('POST') String method,
    @Default({}) Map<String, String> headers,
    String? body,
    @Default(10) int timeoutSeconds,
  }) = _HttpHook;

  factory HttpHook.fromJson(Map<String, Object?> json) =>
      _$HttpHookFromJson(json);
}
