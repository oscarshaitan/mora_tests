import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mora_tests/models/app_settings.dart';
import 'package:mora_tests/models/http_hook.dart';
import 'package:mora_tests/models/llm_action.dart';
import 'package:mora_tests/models/step_result.dart';
import 'package:mora_tests/models/test_case.dart';
import 'package:mora_tests/models/test_step.dart';

void main() {
  // ── LlmAction ──────────────────────────────────────────────────────────────

  group('LlmAction', () {
    test('defaults: confidence=1.0, reasoning=""', () {
      const a = LlmAction(type: ActionType.click);
      expect(a.confidence, equals(1.0));
      expect(a.reasoning, equals(''));
    });

    test('all optional fields default to null', () {
      const a = LlmAction(type: ActionType.type);
      expect(a.cssSelector, isNull);
      expect(a.xpathSelector, isNull);
      expect(a.x, isNull);
      expect(a.y, isNull);
      expect(a.value, isNull);
      expect(a.url, isNull);
      expect(a.key, isNull);
      expect(a.scrollDeltaX, isNull);
      expect(a.scrollDeltaY, isNull);
      expect(a.waitMs, isNull);
      expect(a.expectedText, isNull);
      expect(a.expectedUrl, isNull);
    });

    test('copyWith replaces only specified fields', () {
      const a = LlmAction(
        type: ActionType.click,
        x: 100,
        y: 200,
        confidence: 0.9,
        reasoning: 'original',
      );
      final b = a.copyWith(x: 50, reasoning: 'updated');
      expect(b.type, equals(ActionType.click));
      expect(b.x, equals(50));
      expect(b.y, equals(200)); // unchanged
      expect(b.confidence, equals(0.9)); // unchanged
      expect(b.reasoning, equals('updated'));
    });

    test('ActionType enum contains all expected values', () {
      const expected = [
        'click',
        'doubleClick',
        'longPress',
        'type',
        'scroll',
        'navigate',
        'wait',
        'hover',
        'pressKey',
        'selectOption',
        'assert_text',
        'assert_url',
        'assert_visible',
        'done',
        'fail',
      ];
      final names = ActionType.values.map((e) => e.name).toList();
      for (final e in expected) {
        expect(names, contains(e), reason: 'Missing ActionType: $e');
      }
      expect(names.length, equals(expected.length));
    });

    test('fromJson round-trips basic click action', () {
      final json = {
        'type': 'click',
        'x': 150.0,
        'y': 250.0,
        'confidence': 0.85,
        'reasoning': 'Clicked submit button',
      };
      final a = LlmAction.fromJson(json);
      expect(a.type, equals(ActionType.click));
      expect(a.x, equals(150.0));
      expect(a.y, equals(250.0));
      expect(a.confidence, equals(0.85));
      expect(a.reasoning, equals('Clicked submit button'));
    });

    test('fromJson handles type action with value', () {
      // json_serializable generates camelCase keys by default (no snake_case)
      final json = {
        'type': 'type',
        'cssSelector': '#email',
        'value': 'user@example.com',
        'confidence': 0.95,
        'reasoning': '',
      };
      final a = LlmAction.fromJson(json);
      expect(a.type, equals(ActionType.type));
      expect(a.cssSelector, equals('#email'));
      expect(a.value, equals('user@example.com'));
    });

    test('fromJson handles scroll action', () {
      // json_serializable generates camelCase keys by default (no snake_case)
      final json = {
        'type': 'scroll',
        'scrollDeltaX': 0,
        'scrollDeltaY': 300,
        'confidence': 0.8,
        'reasoning': '',
      };
      final a = LlmAction.fromJson(json);
      expect(a.type, equals(ActionType.scroll));
      expect(a.scrollDeltaX, equals(0));
      expect(a.scrollDeltaY, equals(300));
    });

    test('equality: two identical actions are equal', () {
      const a = LlmAction(type: ActionType.click, x: 10, y: 20);
      const b = LlmAction(type: ActionType.click, x: 10, y: 20);
      expect(a, equals(b));
    });

    test('equality: different x/y are not equal', () {
      const a = LlmAction(type: ActionType.click, x: 10, y: 20);
      const b = LlmAction(type: ActionType.click, x: 10, y: 30);
      expect(a, isNot(equals(b)));
    });
  });

  // ── TestStep ───────────────────────────────────────────────────────────────

  group('TestStep', () {
    test('defaults: timeoutSeconds=30, call=null', () {
      const step = TestStep(id: 's1', instruction: 'Do thing');
      expect(step.timeoutSeconds, equals(30));
      expect(step.call, isNull);
      expect(step.withVars, isEmpty);
      expect(step.hint, isNull);
      expect(step.assertion, isNull);
    });

    test('call step has call path and withVars', () {
      const step = TestStep(
        id: 's3',
        call: 'shared/login.yaml',
        withVars: {'user': 'alice', 'pass': 'secret'},
      );
      expect(step.call, equals('shared/login.yaml'));
      expect(step.withVars['user'], equals('alice'));
      expect(step.withVars['pass'], equals('secret'));
    });

    test('equality based on content', () {
      const a = TestStep(id: 'x', instruction: 'Click OK', timeoutSeconds: 15);
      const b = TestStep(id: 'x', instruction: 'Click OK', timeoutSeconds: 15);
      expect(a, equals(b));
    });

    test('resolvedAction defaults to null', () {
      const step = TestStep(id: 's1', instruction: 'Do thing');
      expect(step.resolvedAction, isNull);
    });

    test('stores resolvedAction when set', () {
      const action = LlmAction(
        type: ActionType.click,
        x: 245,
        y: 312,
        confidence: 0.95,
        reasoning: 'Click login button',
      );
      const step = TestStep(
        id: 's4',
        instruction: 'Click login',
        resolvedAction: action,
      );
      expect(step.resolvedAction, isNotNull);
      expect(step.resolvedAction!.type, equals(ActionType.click));
      expect(step.resolvedAction!.x, equals(245));
    });

    test('copyWith can set and clear resolvedAction', () {
      const action = LlmAction(type: ActionType.type, value: 'hello');
      const step = TestStep(id: 's5', instruction: 'Type hello');
      final withAction = step.copyWith(resolvedAction: action);
      expect(withAction.resolvedAction, isNotNull);
      expect(withAction.resolvedAction!.value, equals('hello'));

      final cleared = withAction.copyWith(resolvedAction: null);
      expect(cleared.resolvedAction, isNull);
    });
  });

  // ── TestCase ───────────────────────────────────────────────────────────────

  group('TestCase', () {
    test('defaults: status=idle, steps=[], variables={}', () {
      const tc = TestCase(id: 'tc1', name: 'My Test');
      expect(tc.status, equals(TestStatus.idle));
      expect(tc.steps, isEmpty);
      expect(tc.variables, isEmpty);
      expect(tc.description, equals(''));
      expect(tc.startUrl, equals(''));
      expect(tc.seeder, isNull);
      expect(tc.teardown, isNull);
      expect(tc.filePath, isNull);
    });

    test('TestStatus enum contains expected values', () {
      expect(
        TestStatus.values.map((e) => e.name),
        containsAll(['idle', 'running', 'passed', 'failed', 'partial']),
      );
    });

    test('copyWith can update status', () {
      const tc = TestCase(id: 'tc2', name: 'Test');
      final running = tc.copyWith(status: TestStatus.running);
      expect(running.status, equals(TestStatus.running));
      expect(running.id, equals('tc2')); // unchanged
    });

    test('copyWith can add steps', () {
      const tc = TestCase(id: 'tc3', name: 'Test');
      const step = TestStep(id: 's1', instruction: 'Step one');
      final withSteps = tc.copyWith(steps: [step]);
      expect(withSteps.steps.length, equals(1));
    });

    test('fromJson round-trips id and name', () {
      // json_serializable generates camelCase keys by default (no snake_case)
      final json = {
        'id': 'rt-tc',
        'name': 'Roundtrip TC',
        'startUrl': 'https://example.com',
        'steps': <dynamic>[],
        'variables': <String, dynamic>{},
        'description': '',
        'status': 'idle',
      };
      final tc = TestCase.fromJson(json);
      expect(tc.id, equals('rt-tc'));
      expect(tc.name, equals('Roundtrip TC'));
      expect(tc.startUrl, equals('https://example.com'));
    });

    test('viewport defaults to 1280x720', () {
      const tc = TestCase(id: 'tc1', name: 'Test');
      expect(tc.viewportWidth, equals(1280));
      expect(tc.viewportHeight, equals(720));
    });

    test('llmFallbackOnFail defaults to false', () {
      const tc = TestCase(id: 'tc1', name: 'Test');
      expect(tc.llmFallbackOnFail, isFalse);
    });

    test('copyWith can update viewport and llmFallbackOnFail', () {
      const tc = TestCase(id: 'tc4', name: 'Test');
      final updated = tc.copyWith(
        viewportWidth: 1920,
        viewportHeight: 1080,
        llmFallbackOnFail: true,
      );
      expect(updated.viewportWidth, equals(1920));
      expect(updated.viewportHeight, equals(1080));
      expect(updated.llmFallbackOnFail, isTrue);
    });
  });

  // ── HttpHook ───────────────────────────────────────────────────────────────

  group('HttpHook', () {
    test('defaults: method=POST, headers={}, timeoutSeconds=10', () {
      const hook = HttpHook(url: 'https://api.example.com/seed');
      expect(hook.method, equals('POST'));
      expect(hook.headers, isEmpty);
      expect(hook.timeoutSeconds, equals(10));
      expect(hook.body, isNull);
    });

    test('stores all fields', () {
      const hook = HttpHook(
        url: 'https://api.example.com/cleanup',
        method: 'DELETE',
        headers: {'Authorization': 'Bearer token'},
        body: '{"key":"value"}',
        timeoutSeconds: 30,
      );
      expect(hook.url, equals('https://api.example.com/cleanup'));
      expect(hook.method, equals('DELETE'));
      expect(hook.headers['Authorization'], equals('Bearer token'));
      expect(hook.body, equals('{"key":"value"}'));
      expect(hook.timeoutSeconds, equals(30));
    });

    test('equality: identical hooks are equal', () {
      const a = HttpHook(url: 'https://example.com', method: 'GET');
      const b = HttpHook(url: 'https://example.com', method: 'GET');
      expect(a, equals(b));
    });
  });

  // ── StepResult ────────────────────────────────────────────────────────────

  group('StepResult', () {
    final dummyPng = Uint8List.fromList([0, 1, 2, 3]);
    final now = DateTime(2025, 1, 1, 12, 0, 0);

    test('success result with all fields', () {
      final result = StepResult(
        stepId: 'step-001',
        success: true,
        screenshotBefore: dummyPng,
        screenshotAfter: dummyPng,
        rawLlmResponse: 'Clicked the button',
        duration: const Duration(seconds: 3),
        executedAt: now,
      );
      expect(result.stepId, equals('step-001'));
      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.subStepResults, isEmpty);
    });

    test('failure result stores errorMessage', () {
      final result = StepResult(
        stepId: 'step-002',
        success: false,
        screenshotBefore: dummyPng,
        errorMessage: 'Element not found',
        duration: const Duration(seconds: 5),
        executedAt: now,
      );
      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Element not found'));
      expect(result.screenshotAfter, isNull);
    });

    test('sub-step results are empty by default', () {
      final result = StepResult(
        stepId: 'call-step',
        success: true,
        screenshotBefore: dummyPng,
        duration: Duration.zero,
        executedAt: now,
      );
      expect(result.subStepResults, isEmpty);
    });

    test('stores sub-step results for call steps', () {
      final sub = StepResult(
        stepId: 'sub-step-001',
        success: true,
        screenshotBefore: dummyPng,
        duration: const Duration(milliseconds: 500),
        executedAt: now,
      );
      final callResult = StepResult(
        stepId: 'call-step',
        success: true,
        screenshotBefore: dummyPng,
        duration: const Duration(seconds: 1),
        executedAt: now,
        subStepResults: [sub],
      );
      expect(callResult.subStepResults.length, equals(1));
      expect(callResult.subStepResults.first.stepId, equals('sub-step-001'));
    });

    test('stores action taken', () {
      const action = LlmAction(
        type: ActionType.click,
        x: 100,
        y: 200,
        confidence: 0.9,
        reasoning: 'Clicked the button',
      );
      final result = StepResult(
        stepId: 'step-003',
        success: true,
        actionTaken: action,
        screenshotBefore: dummyPng,
        duration: const Duration(seconds: 2),
        executedAt: now,
      );
      expect(result.actionTaken?.type, equals(ActionType.click));
      expect(result.actionTaken?.x, equals(100));
    });
  });

  // ── AppSettings ───────────────────────────────────────────────────────────

  group('AppSettings', () {
    test('default constructor populates OVH fields', () {
      const s = AppSettings();
      expect(s.ovhBaseUrl, isNotEmpty);
      expect(s.ovhPrimaryModel, isNotEmpty);
      expect(s.ovhApiKey, equals(''));
      expect(s.activeProvider, equals('ovh'));
    });

    test('default constructor populates Vertex AI fields', () {
      const s = AppSettings();
      expect(s.vertexAiBaseUrl, isNotEmpty);
      expect(s.vertexAiPrimaryModel, isNotEmpty);
      expect(s.vertexAiServiceAccountJson, equals(''));
    });

    test('copyWith updates a single field without affecting others', () {
      const s = AppSettings();
      final updated = s.copyWith(ovhApiKey: 'my-key');
      expect(updated.ovhApiKey, equals('my-key'));
      expect(updated.ovhPrimaryModel, equals(s.ovhPrimaryModel));
      expect(updated.activeProvider, equals(s.activeProvider));
    });

    test('copyWith can change active provider', () {
      const s = AppSettings();
      final updated = s.copyWith(activeProvider: 'vertexAi');
      expect(updated.activeProvider, equals('vertexAi'));
    });

    test('confidenceThreshold defaults to 0.5', () {
      const s = AppSettings();
      expect(s.confidenceThreshold, equals(0.5));
    });

    test('browserHeadless defaults to false', () {
      const s = AppSettings();
      expect(s.browserHeadless, isFalse);
    });
  });
}
