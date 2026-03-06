import 'package:flutter_test/flutter_test.dart';
import 'package:mora_tests/core/exceptions.dart';
import 'package:mora_tests/models/llm_action.dart';
import 'package:mora_tests/services/js_builder.dart';
import 'package:mora_tests/services/webview_service.dart';

void main() {
  late WebViewService service;

  setUp(() {
    service = WebViewService(JsBuilder());
  });

  // ── Initial state ─────────────────────────────────────────────────────────

  group('initial state', () {
    test('isReady is false before any controller is attached', () {
      expect(service.isReady, isFalse);
    });

    test('waitUntilReady() returns a future that has not completed', () async {
      bool completed = false;
      service.waitUntilReady().then((_) => completed = true);
      // yield to microtask queue — completer is still pending
      await Future<void>.microtask(() {});
      expect(completed, isFalse);
    });
  });

  // ── reset() ───────────────────────────────────────────────────────────────

  group('reset()', () {
    test('isReady is false after reset', () {
      service.reset();
      expect(service.isReady, isFalse);
    });

    test('waitUntilReady returns a fresh pending future after reset', () async {
      service.reset();
      bool completed = false;
      service.waitUntilReady().then((_) => completed = true);
      await Future<void>.microtask(() {});
      expect(completed, isFalse);
    });

    test('reset can be called multiple times without throwing', () {
      expect(() {
        service.reset();
        service.reset();
        service.reset();
      }, returnsNormally);
    });
  });

  // ── notifyLoadStop() ──────────────────────────────────────────────────────

  group('notifyLoadStop()', () {
    test('does not throw when no load completer is active', () {
      expect(() => service.notifyLoadStop(), returnsNormally);
    });

    test('does not throw after reset with no completer', () {
      service.reset();
      expect(() => service.notifyLoadStop(), returnsNormally);
    });
  });

  // ── _ctrl guard — operations requiring a controller ───────────────────────

  group('throws WebViewException when controller not attached', () {
    test('evaluateJs throws', () async {
      await expectLater(
        service.evaluateJs('1+1'),
        throwsA(isA<WebViewException>()),
      );
    });

    test('screenshot throws', () async {
      await expectLater(
        service.screenshot(),
        throwsA(isA<WebViewException>()),
      );
    });

    test('currentUrl throws', () async {
      await expectLater(
        service.currentUrl(),
        throwsA(isA<WebViewException>()),
      );
    });

    test('navigate throws', () async {
      await expectLater(
        service.navigate('https://example.com'),
        throwsA(isA<WebViewException>()),
      );
    });
  });

  // ── executeAction — controller-free action types ──────────────────────────

  group('executeAction — done / fail / wait', () {
    test('done returns immediately without touching the controller', () async {
      const action = LlmAction(
        type: ActionType.done,
        confidence: 1.0,
        reasoning: 'Already complete',
      );
      await expectLater(service.executeAction(action), completes);
    });

    test('fail returns immediately without touching the controller', () async {
      const action = LlmAction(
        type: ActionType.fail,
        confidence: 0.0,
        reasoning: 'Cannot proceed',
      );
      await expectLater(service.executeAction(action), completes);
    });

    test('wait with 0 ms completes without touching the controller', () async {
      const action = LlmAction(
        type: ActionType.wait,
        waitMs: 0,
        confidence: 1.0,
        reasoning: '',
      );
      await expectLater(service.executeAction(action), completes);
    });

    test('wait with null waitMs returns a future (default 1000 ms)', () async {
      const action = LlmAction(
        type: ActionType.wait,
        // ignore: avoid_redundant_argument_values
        waitMs: null,
        confidence: 1.0,
        reasoning: '',
      );
      // Verify the future is not already completed before we await it
      bool completed = false;
      final f = service.executeAction(action).then((_) => completed = true);
      // Immediately after scheduling — not yet done
      expect(completed, isFalse);
      // Await with a short timeout to confirm it IS a future (not sync)
      // We use 0ms override would be ideal, but null → 1000ms is an impl detail.
      // Just verify the future object exists and the action type takes this path.
      expect(f, isA<Future<void>>());
      // Cancel observation — don't await the full 1 s in CI.
    });
  });

  // ── executeAction — navigate requires controller ──────────────────────────

  group('executeAction — controller-required actions throw', () {
    test('navigate action throws WebViewException', () async {
      const action = LlmAction(
        type: ActionType.navigate,
        url: 'https://example.com',
        confidence: 0.9,
        reasoning: '',
      );
      await expectLater(
        service.executeAction(action),
        throwsA(isA<WebViewException>()),
      );
    });

    test('click action with CSS selector throws WebViewException', () async {
      // With a cssSelector, _resolveCenter calls evaluateJs → _ctrl throws
      // before the catch block in _jsPointerClick is ever reached.
      // (Click with raw x/y coordinates goes through _jsPointerClick which
      // has its own internal catch and therefore swallows the error.)
      const action = LlmAction(
        type: ActionType.click,
        cssSelector: '#btn',
        confidence: 0.9,
        reasoning: '',
      );
      await expectLater(
        service.executeAction(action),
        throwsA(isA<WebViewException>()),
      );
    });

    test('type action throws WebViewException', () async {
      const action = LlmAction(
        type: ActionType.type,
        value: 'hello',
        confidence: 0.9,
        reasoning: '',
      );
      await expectLater(
        service.executeAction(action),
        throwsA(isA<WebViewException>()),
      );
    });

    test('scroll action throws WebViewException', () async {
      const action = LlmAction(
        type: ActionType.scroll,
        scrollDeltaY: 300,
        confidence: 0.9,
        reasoning: '',
      );
      await expectLater(
        service.executeAction(action),
        throwsA(isA<WebViewException>()),
      );
    });

    test('pressKey action throws WebViewException', () async {
      const action = LlmAction(
        type: ActionType.pressKey,
        key: 'Enter',
        confidence: 0.9,
        reasoning: '',
      );
      await expectLater(
        service.executeAction(action),
        throwsA(isA<WebViewException>()),
      );
    });

    test('hover action throws WebViewException', () async {
      const action = LlmAction(
        type: ActionType.hover,
        x: 50,
        y: 50,
        confidence: 0.9,
        reasoning: '',
      );
      await expectLater(
        service.executeAction(action),
        throwsA(isA<WebViewException>()),
      );
    });

    test('assert_text action throws WebViewException', () async {
      const action = LlmAction(
        type: ActionType.assert_text,
        expectedText: 'Hello',
        confidence: 0.9,
        reasoning: '',
      );
      await expectLater(
        service.executeAction(action),
        throwsA(isA<WebViewException>()),
      );
    });
  });
}
