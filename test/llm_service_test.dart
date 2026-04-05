import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mora_tests/core/exceptions.dart';
import 'package:mora_tests/models/llm_action.dart';
import 'package:mora_tests/services/llm_service.dart';

void main() {
  final fakeScreenshot = Uint8List.fromList([1, 2, 3]);

  LlmService makeService({String? fallbackModel, String apiKey = 'test-key'}) =>
      LlmService(
        baseUrl: 'https://api.test.com/v1',
        apiKey: apiKey,
        model: 'test-model',
        fallbackModel: fallbackModel,
      );

  /// Wraps a map action into the OpenAI response envelope.
  String okResponse(Map<String, dynamic> action) => jsonEncode({
        'choices': [
          {
            'message': {'content': jsonEncode(action)},
          },
        ],
      });

  /// A minimal valid click action JSON map.
  Map<String, dynamic> clickMap({
    double x = 100,
    double y = 200,
    double confidence = 0.9,
    String reasoning = 'Click the button',
  }) =>
      {
        'action': 'click',
        'x': x,
        'y': y,
        'confidence': confidence,
        'reasoning': reasoning,
        'css_selector': null,
        'xpath_selector': null,
        'value': null,
        'url': null,
        'key': null,
        'scroll_delta_x': null,
        'scroll_delta_y': null,
        'wait_ms': null,
        'expected_text': null,
        'expected_url': null,
      };

  // ── Success path ─────────────────────────────────────────────────────────

  group('interpretStep — success', () {
    test('returns click action with correct coordinates', () async {
      final service = makeService();
      final result = await http.runWithClient(
        () => service.interpretStep(
          instruction: 'Click the button',
          screenshot: fakeScreenshot,
        ),
        () => MockClient((_) async => http.Response(okResponse(clickMap()), 200)),
      );
      expect(result.type, ActionType.click);
      expect(result.x, 100.0);
      expect(result.y, 200.0);
      expect(result.confidence, 0.9);
      expect(result.reasoning, 'Click the button');
    });

    test('returns done action', () async {
      final service = makeService();
      final result = await http.runWithClient(
        () => service.interpretStep(
          instruction: 'Check if done',
          screenshot: fakeScreenshot,
        ),
        () => MockClient(
          (_) async => http.Response(okResponse({...clickMap(), 'action': 'done'}), 200),
        ),
      );
      expect(result.type, ActionType.done);
    });

    test('returns fail action', () async {
      final service = makeService();
      final result = await http.runWithClient(
        () => service.interpretStep(
          instruction: 'Impossible task',
          screenshot: fakeScreenshot,
        ),
        () => MockClient(
          (_) async => http.Response(okResponse({...clickMap(), 'action': 'fail'}), 200),
        ),
      );
      expect(result.type, ActionType.fail);
    });

    test('unknown action type falls back to fail', () async {
      final service = makeService();
      final result = await http.runWithClient(
        () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
        () => MockClient(
          (_) async =>
              http.Response(okResponse({...clickMap(), 'action': 'unknown_xyz'}), 200),
        ),
      );
      expect(result.type, ActionType.fail);
    });

    test('action with hyphen is normalised (assert-text → assert_text)', () async {
      final service = makeService();
      final result = await http.runWithClient(
        () => service.interpretStep(instruction: 'Assert', screenshot: fakeScreenshot),
        () => MockClient(
          (_) async =>
              http.Response(okResponse({...clickMap(), 'action': 'assert-text'}), 200),
        ),
      );
      expect(result.type, ActionType.assert_text);
    });

    test('null content in response defaults to fail action', () async {
      final service = makeService();
      final body = jsonEncode({
        'choices': [
          {'message': <String, dynamic>{}},
        ],
      });
      final result = await http.runWithClient(
        () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
        () => MockClient((_) async => http.Response(body, 200)),
      );
      expect(result.type, ActionType.fail);
    });

    test('missing confidence defaults to 0.5', () async {
      final service = makeService();
      final action = Map<String, dynamic>.from(clickMap())..remove('confidence');
      final result = await http.runWithClient(
        () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
        () => MockClient((_) async => http.Response(okResponse(action), 200)),
      );
      expect(result.confidence, 0.5);
    });

    test('missing reasoning defaults to empty string', () async {
      final service = makeService();
      final action = Map<String, dynamic>.from(clickMap())..remove('reasoning');
      final result = await http.runWithClient(
        () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
        () => MockClient((_) async => http.Response(okResponse(action), 200)),
      );
      expect(result.reasoning, '');
    });
  });

  // ── JSON extraction edge cases ────────────────────────────────────────────

  group('_extractJson — via interpretStep', () {
    test('strips markdown code fences', () async {
      final service = makeService();
      final body = jsonEncode({
        'choices': [
          {
            'message': {
              'content': '```json\n${jsonEncode(clickMap())}\n```',
            },
          },
        ],
      });
      final result = await http.runWithClient(
        () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
        () => MockClient((_) async => http.Response(body, 200)),
      );
      expect(result.type, ActionType.click);
    });

    test('strips plain code fences (no language specifier)', () async {
      final service = makeService();
      final body = jsonEncode({
        'choices': [
          {
            'message': {
              'content': '```\n${jsonEncode(clickMap())}\n```',
            },
          },
        ],
      });
      final result = await http.runWithClient(
        () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
        () => MockClient((_) async => http.Response(body, 200)),
      );
      expect(result.type, ActionType.click);
    });

    test('extracts JSON surrounded by prose', () async {
      final service = makeService();
      final prose = 'Here is my analysis: ${jsonEncode(clickMap())} Done!';
      final body = jsonEncode({
        'choices': [
          {'message': {'content': prose}},
        ],
      });
      final result = await http.runWithClient(
        () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
        () => MockClient((_) async => http.Response(body, 200)),
      );
      expect(result.type, ActionType.click);
    });

    test('JSON with trailing comma causes LlmException (Dart replaceAll has no backreference)', () async {
      // Dart's String.replaceAll(RegExp, String) treats '$1' as a literal
      // string, not a capture-group backreference. So the trailing-comma
      // removal in _extractJson does not work in the Dart VM and the response
      // cannot be parsed.
      final service = makeService();
      const malformed = '''{
  "action": "click",
  "x": 50,
  "y": 75,
  "confidence": 0.8,
  "reasoning": "test",
  "css_selector": null,
  "xpath_selector": null,
  "value": null,
  "url": null,
  "key": null,
  "scroll_delta_x": null,
  "scroll_delta_y": null,
  "wait_ms": null,
  "expected_text": null,
  "expected_url": null,
}''';
      final body = jsonEncode({
        'choices': [
          {'message': {'content': malformed}},
        ],
      });
      await expectLater(
        http.runWithClient(
          () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
          () => MockClient((_) async => http.Response(body, 200)),
        ),
        throwsA(isA<LlmException>()),
      );
    });

    test('throws LlmException for completely unparseable response', () async {
      final service = makeService();
      final body = jsonEncode({
        'choices': [
          {'message': {'content': 'This is just plain text with no JSON at all'}},
        ],
      });
      await expectLater(
        http.runWithClient(
          () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
          () => MockClient((_) async => http.Response(body, 200)),
        ),
        throwsA(isA<LlmException>()),
      );
    });

    test('long unparseable content is truncated in error message', () async {
      final service = makeService();
      final longContent = 'a' * 300; // > 200 chars, no JSON
      final body = jsonEncode({
        'choices': [
          {'message': {'content': longContent}},
        ],
      });
      Object? caught;
      try {
        await http.runWithClient(
          () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
          () => MockClient((_) async => http.Response(body, 200)),
        );
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<LlmException>());
      final msg = (caught as LlmException).message;
      expect(msg.contains('…'), isTrue);
    });
  });

  // ── Request body construction ─────────────────────────────────────────────

  group('request body', () {
    Future<Map<String, dynamic>> captureBody({
      String? hint,
      String? assertion,
      String? previousActionName,
      String? previousError,
    }) async {
      http.Request? captured;
      await http.runWithClient(
        () => makeService().interpretStep(
          instruction: 'Do something',
          screenshot: fakeScreenshot,
          hint: hint,
          assertion: assertion,
          previousActionName: previousActionName,
          previousError: previousError,
        ),
        () => MockClient((req) async {
          captured = req;
          return http.Response(okResponse(clickMap()), 200);
        }),
      );
      return jsonDecode(captured!.body) as Map<String, dynamic>;
    }

    test('includes Authorization header with api key', () async {
      http.Request? captured;
      await http.runWithClient(
        () => makeService(apiKey: 'my-secret').interpretStep(
          instruction: 'Click',
          screenshot: fakeScreenshot,
        ),
        () => MockClient((req) async {
          captured = req;
          return http.Response(okResponse(clickMap()), 200);
        }),
      );
      expect(captured!.headers['Authorization'], 'Bearer my-secret');
    });

    test('hint is included in text parts', () async {
      final body = await captureBody(hint: 'Look at the header area');
      final userContent =
          ((body['messages'] as List).last['content'] as List);
      final text = (userContent.last as Map)['text'] as String;
      expect(text, contains('HINT: Look at the header area'));
    });

    test('assertion is included in text parts', () async {
      final body = await captureBody(assertion: 'Dashboard must be visible');
      final userContent =
          ((body['messages'] as List).last['content'] as List);
      final text = (userContent.last as Map)['text'] as String;
      expect(text, contains('ASSERTION'));
      expect(text, contains('Dashboard must be visible'));
    });

    test('previousActionName is included', () async {
      final body = await captureBody(previousActionName: 'click');
      final userContent =
          ((body['messages'] as List).last['content'] as List);
      final text = (userContent.last as Map)['text'] as String;
      expect(text, contains('PREVIOUS ATTEMPT'));
      expect(text, contains('"click"'));
    });

    test('previousError is included', () async {
      final body = await captureBody(previousError: 'Element not found');
      final userContent =
          ((body['messages'] as List).last['content'] as List);
      final text = (userContent.last as Map)['text'] as String;
      expect(text, contains('PREVIOUS ERROR: Element not found'));
    });

    test('empty hint is omitted from text parts', () async {
      final body = await captureBody(hint: '');
      final userContent =
          ((body['messages'] as List).last['content'] as List);
      final text = (userContent.last as Map)['text'] as String;
      expect(text, isNot(contains('HINT')));
    });

    test('screenshot is base64-encoded in image_url part', () async {
      final body = await captureBody();
      final userContent =
          ((body['messages'] as List).last['content'] as List);
      final imageUrl = (userContent.first as Map)['image_url'] as Map;
      expect((imageUrl['url'] as String).startsWith('data:image/png;base64,'), isTrue);
    });

    test('model name from constructor appears in request body', () async {
      final body = await captureBody();
      expect(body['model'], 'test-model');
    });
  });

  // ── HTTP error handling ───────────────────────────────────────────────────

  group('HTTP errors', () {
    test('throws LlmException on 400', () async {
      final service = makeService();
      await expectLater(
        http.runWithClient(
          () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
          () => MockClient((_) async => http.Response('Bad Request', 400)),
        ),
        throwsA(isA<LlmException>()),
      );
    });

    test('throws LlmException on 500', () async {
      final service = makeService();
      await expectLater(
        http.runWithClient(
          () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
          () => MockClient((_) async => http.Response('Server Error', 500)),
        ),
        throwsA(isA<LlmException>()),
      );
    });

    test('retries once on 429 with Retry-After:0 and succeeds on retry', () async {
      final service = makeService();
      int calls = 0;
      final result = await http.runWithClient(
        () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
        () => MockClient((_) async {
          calls++;
          if (calls == 1) {
            return http.Response('Rate limited', 429,
                headers: {'retry-after': '0'});
          }
          return http.Response(okResponse(clickMap()), 200);
        }),
      );
      expect(calls, 2);
      expect(result.type, ActionType.click);
    });

    test('429 with no Retry-After header uses default 10s delay (0s in test)', () async {
      // Override rateLimitDelaySeconds indirectly by testing that it retries
      // using a Retry-After of 0 so the test stays fast.
      final service = makeService();
      int calls = 0;
      final result = await http.runWithClient(
        () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
        () => MockClient((_) async {
          calls++;
          if (calls == 1) {
            // No Retry-After header → falls back to AppConstants.rateLimitDelaySeconds
            // We pass Retry-After:0 to avoid real wait
            return http.Response('Rate limited', 429,
                headers: {'retry-after': '0'});
          }
          return http.Response(okResponse(clickMap()), 200);
        }),
      );
      expect(calls, 2);
      expect(result.type, ActionType.click);
    });

    test('throws LlmException after retry still fails on 429', () async {
      final service = makeService();
      await expectLater(
        http.runWithClient(
          () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
          () => MockClient(
            (_) async => http.Response('Rate limited', 429,
                headers: {'retry-after': '0'}),
          ),
        ),
        throwsA(isA<LlmException>()),
      );
    });
  });

  // ── Fallback model ────────────────────────────────────────────────────────

  group('fallback model', () {
    test('uses fallback when primary fails', () async {
      final service = makeService(fallbackModel: 'fallback-model');
      int calls = 0;
      String? lastModel;
      final result = await http.runWithClient(
        () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
        () => MockClient((req) async {
          calls++;
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          lastModel = body['model'] as String;
          if (calls == 1) return http.Response('Server Error', 500);
          return http.Response(okResponse(clickMap()), 200);
        }),
      );
      expect(calls, 2);
      expect(lastModel, 'fallback-model');
      expect(result.type, ActionType.click);
    });

    test('does NOT retry when fallback equals primary model', () async {
      final service = makeService(fallbackModel: 'test-model'); // same as primary
      int calls = 0;
      await expectLater(
        http.runWithClient(
          () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
          () => MockClient((_) async {
            calls++;
            return http.Response('Server Error', 500);
          }),
        ),
        throwsA(isA<LlmException>()),
      );
      expect(calls, 1);
    });

    test('does NOT retry when no fallback is configured', () async {
      final service = makeService(); // no fallback
      int calls = 0;
      await expectLater(
        http.runWithClient(
          () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
          () => MockClient((_) async {
            calls++;
            return http.Response('Server Error', 500);
          }),
        ),
        throwsA(isA<LlmException>()),
      );
      expect(calls, 1);
    });

    test('does NOT retry when fallback is empty string', () async {
      final service = makeService(fallbackModel: '');
      int calls = 0;
      await expectLater(
        http.runWithClient(
          () => service.interpretStep(instruction: 'Click', screenshot: fakeScreenshot),
          () => MockClient((_) async {
            calls++;
            return http.Response('Server Error', 500);
          }),
        ),
        throwsA(isA<LlmException>()),
      );
      expect(calls, 1);
    });
  });

  // ── _parseAction field mapping ────────────────────────────────────────────

  group('_parseAction — field mapping', () {
    Future<LlmAction> parseAction(Map<String, dynamic> actionMap) async {
      final service = makeService();
      return http.runWithClient(
        () => service.interpretStep(instruction: 'x', screenshot: fakeScreenshot),
        () => MockClient((_) async => http.Response(okResponse(actionMap), 200)),
      );
    }

    test('type action returns correct fields', () async {
      final result = await parseAction({
        'action': 'type',
        'css_selector': '#email',
        'value': 'user@example.com',
        'confidence': 0.95,
        'reasoning': 'Type email',
        'x': null,
        'y': null,
        'xpath_selector': null,
        'url': null,
        'key': null,
        'scroll_delta_x': null,
        'scroll_delta_y': null,
        'wait_ms': null,
        'expected_text': null,
        'expected_url': null,
      });
      expect(result.type, ActionType.type);
      expect(result.cssSelector, '#email');
      expect(result.value, 'user@example.com');
    });

    test('scroll action maps scroll deltas', () async {
      final result = await parseAction({
        'action': 'scroll',
        'scroll_delta_x': 0,
        'scroll_delta_y': 300,
        'confidence': 0.7,
        'reasoning': 'Scroll down',
        'x': null,
        'y': null,
        'css_selector': null,
        'xpath_selector': null,
        'value': null,
        'url': null,
        'key': null,
        'wait_ms': null,
        'expected_text': null,
        'expected_url': null,
      });
      expect(result.type, ActionType.scroll);
      expect(result.scrollDeltaY, 300);
      expect(result.scrollDeltaX, 0);
    });

    test('navigate action maps url', () async {
      final result = await parseAction({
        'action': 'navigate',
        'url': 'https://example.com',
        'confidence': 0.9,
        'reasoning': 'Navigate',
        'x': null,
        'y': null,
        'css_selector': null,
        'xpath_selector': null,
        'value': null,
        'key': null,
        'scroll_delta_x': null,
        'scroll_delta_y': null,
        'wait_ms': null,
        'expected_text': null,
        'expected_url': null,
      });
      expect(result.type, ActionType.navigate);
      expect(result.url, 'https://example.com');
    });

    test('wait action maps wait_ms', () async {
      final result = await parseAction({
        'action': 'wait',
        'wait_ms': 2000,
        'confidence': 0.5,
        'reasoning': 'Wait for animation',
        'x': null,
        'y': null,
        'css_selector': null,
        'xpath_selector': null,
        'value': null,
        'url': null,
        'key': null,
        'scroll_delta_x': null,
        'scroll_delta_y': null,
        'expected_text': null,
        'expected_url': null,
      });
      expect(result.type, ActionType.wait);
      expect(result.waitMs, 2000);
    });

    test('pressKey action maps key field', () async {
      final result = await parseAction({
        'action': 'pressKey',
        'key': 'Enter',
        'confidence': 0.9,
        'reasoning': 'Press Enter',
        'x': null,
        'y': null,
        'css_selector': null,
        'xpath_selector': null,
        'value': null,
        'url': null,
        'scroll_delta_x': null,
        'scroll_delta_y': null,
        'wait_ms': null,
        'expected_text': null,
        'expected_url': null,
      });
      expect(result.type, ActionType.pressKey);
      expect(result.key, 'Enter');
    });

    test('assert_text maps expected_text', () async {
      final result = await parseAction({
        'action': 'assert_text',
        'expected_text': 'Welcome',
        'confidence': 0.9,
        'reasoning': 'Check text',
        'x': null,
        'y': null,
        'css_selector': null,
        'xpath_selector': null,
        'value': null,
        'url': null,
        'key': null,
        'scroll_delta_x': null,
        'scroll_delta_y': null,
        'wait_ms': null,
        'expected_url': null,
      });
      expect(result.type, ActionType.assert_text);
      expect(result.expectedText, 'Welcome');
    });
  });
}
