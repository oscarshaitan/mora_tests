import 'package:http/http.dart' as http;

import '../core/exceptions.dart';
import '../models/http_hook.dart';

class HttpHookService {
  Future<int> call(HttpHook hook) async {
    try {
      final uri = Uri.parse(hook.url);
      final request = http.Request(hook.method, uri);

      hook.headers.forEach((k, v) => request.headers[k] = v);

      if (hook.body != null && hook.body!.isNotEmpty) {
        request.body = hook.body!;
        request.headers.putIfAbsent(
          'Content-Type',
          () => 'application/json',
        );
      }

      final streamed = await request.send().timeout(
        Duration(seconds: hook.timeoutSeconds),
      );

      if (streamed.statusCode >= 400) {
        throw HookException(
          '${hook.method} ${hook.url} returned ${streamed.statusCode}',
        );
      }

      return streamed.statusCode;
    } on HookException {
      rethrow;
    } catch (e) {
      throw HookException('Hook call failed: $e');
    }
  }
}
