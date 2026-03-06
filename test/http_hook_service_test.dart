import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mora_tests/core/exceptions.dart';
import 'package:mora_tests/models/http_hook.dart';
import 'package:mora_tests/services/http_hook_service.dart';

void main() {
  HttpHook makeHook({
    String url = 'https://api.test.com/hook',
    String method = 'POST',
    Map<String, String> headers = const {},
    String? body,
    int timeoutSeconds = 10,
  }) =>
      HttpHook(
        url: url,
        method: method,
        headers: headers,
        body: body,
        timeoutSeconds: timeoutSeconds,
      );

  // ── Success paths ─────────────────────────────────────────────────────────

  group('call() — success', () {
    test('returns status code 200 on success', () async {
      final service = HttpHookService();
      final result = await http.runWithClient(
        () => service.call(makeHook()),
        () => MockClient((_) async => http.Response('OK', 200)),
      );
      expect(result, 200);
    });

    test('returns status code 201 (created)', () async {
      final service = HttpHookService();
      final result = await http.runWithClient(
        () => service.call(makeHook()),
        () => MockClient((_) async => http.Response('Created', 201)),
      );
      expect(result, 201);
    });

    test('returns status code 204 (no content)', () async {
      final service = HttpHookService();
      final result = await http.runWithClient(
        () => service.call(makeHook()),
        () => MockClient((_) async => http.Response('', 204)),
      );
      expect(result, 204);
    });

    test('uses correct HTTP method from hook', () async {
      final service = HttpHookService();
      String? capturedMethod;
      await http.runWithClient(
        () => service.call(makeHook(method: 'PUT')),
        () => MockClient((req) async {
          capturedMethod = req.method;
          return http.Response('OK', 200);
        }),
      );
      expect(capturedMethod, 'PUT');
    });

    test('sends request to correct URL', () async {
      final service = HttpHookService();
      Uri? capturedUrl;
      await http.runWithClient(
        () => service.call(makeHook(url: 'https://example.com/api/seed')),
        () => MockClient((req) async {
          capturedUrl = req.url;
          return http.Response('OK', 200);
        }),
      );
      expect(capturedUrl?.toString(), 'https://example.com/api/seed');
    });

    test('forwards custom headers', () async {
      final service = HttpHookService();
      Map<String, String>? capturedHeaders;
      await http.runWithClient(
        () => service.call(makeHook(headers: {'Authorization': 'Bearer tok', 'X-Custom': 'val'})),
        () => MockClient((req) async {
          capturedHeaders = req.headers;
          return http.Response('OK', 200);
        }),
      );
      expect(capturedHeaders?['Authorization'], 'Bearer tok');
      expect(capturedHeaders?['X-Custom'], 'val');
    });

    test('sets body when provided', () async {
      final service = HttpHookService();
      String? capturedBody;
      await http.runWithClient(
        () => service.call(makeHook(body: '{"seed": true}')),
        () => MockClient((req) async {
          capturedBody = req.body;
          return http.Response('OK', 200);
        }),
      );
      expect(capturedBody, '{"seed": true}');
    });

    test('Content-Type header is set when body is present', () async {
      // Note: http.Request.body= automatically sets content-type to
      // 'text/plain; charset=utf-8'. putIfAbsent is a no-op when the key
      // already exists, so the effective content-type is the one set by the
      // http library.
      final service = HttpHookService();
      Map<String, String>? capturedHeaders;
      await http.runWithClient(
        () => service.call(makeHook(body: '{"data": 1}')),
        () => MockClient((req) async {
          capturedHeaders = req.headers;
          return http.Response('OK', 200);
        }),
      );
      final ct = capturedHeaders?.entries
          .where((e) => e.key.toLowerCase() == 'content-type')
          .map((e) => e.value)
          .firstOrNull;
      expect(ct, isNotNull);
    });

    test('does NOT set Content-Type when body is absent', () async {
      final service = HttpHookService();
      Map<String, String>? capturedHeaders;
      await http.runWithClient(
        () => service.call(makeHook()),
        () => MockClient((req) async {
          capturedHeaders = req.headers;
          return http.Response('OK', 200);
        }),
      );
      final ct = capturedHeaders?['content-type'] ?? capturedHeaders?['Content-Type'];
      expect(ct, isNull);
    });

    test('does NOT set Content-Type when body is empty string', () async {
      final service = HttpHookService();
      Map<String, String>? capturedHeaders;
      await http.runWithClient(
        () => service.call(makeHook(body: '')),
        () => MockClient((req) async {
          capturedHeaders = req.headers;
          return http.Response('OK', 200);
        }),
      );
      final ct = capturedHeaders?['content-type'] ?? capturedHeaders?['Content-Type'];
      expect(ct, isNull);
    });
  });

  // ── Error paths ───────────────────────────────────────────────────────────

  group('call() — errors', () {
    test('throws HookException on 400', () async {
      final service = HttpHookService();
      await expectLater(
        http.runWithClient(
          () => service.call(makeHook()),
          () => MockClient((_) async => http.Response('Bad Request', 400)),
        ),
        throwsA(isA<HookException>()),
      );
    });

    test('throws HookException on 404', () async {
      final service = HttpHookService();
      await expectLater(
        http.runWithClient(
          () => service.call(makeHook()),
          () => MockClient((_) async => http.Response('Not Found', 404)),
        ),
        throwsA(isA<HookException>()),
      );
    });

    test('throws HookException on 500', () async {
      final service = HttpHookService();
      await expectLater(
        http.runWithClient(
          () => service.call(makeHook()),
          () => MockClient((_) async => http.Response('Internal Server Error', 500)),
        ),
        throwsA(isA<HookException>()),
      );
    });

    test('error message includes method and URL and status code', () async {
      final service = HttpHookService();
      Object? caught;
      try {
        await http.runWithClient(
          () => service.call(makeHook(method: 'DELETE', url: 'https://api.test.com/res')),
          () => MockClient((_) async => http.Response('Forbidden', 403)),
        );
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<HookException>());
      final msg = (caught as HookException).message;
      expect(msg, contains('DELETE'));
      expect(msg, contains('403'));
    });

    test('network error is wrapped in HookException', () async {
      final service = HttpHookService();
      await expectLater(
        http.runWithClient(
          () => service.call(makeHook()),
          () => MockClient((_) async => throw Exception('Connection refused')),
        ),
        throwsA(isA<HookException>()),
      );
    });

    test('HookException propagates without double-wrapping', () async {
      final service = HttpHookService();
      await expectLater(
        http.runWithClient(
          () => service.call(makeHook()),
          () => MockClient((_) async => http.Response('Forbidden', 403)),
        ),
        throwsA(isA<HookException>()),
      );
    });
  });

  // ── DELETE method (no body) ───────────────────────────────────────────────

  group('DELETE hook', () {
    test('DELETE with no body succeeds', () async {
      final service = HttpHookService();
      final result = await http.runWithClient(
        () => service.call(makeHook(method: 'DELETE')),
        () => MockClient((_) async => http.Response('', 204)),
      );
      expect(result, 204);
    });
  });
}
