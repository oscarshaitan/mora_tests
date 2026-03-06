import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mora_tests/models/llm_action.dart';
import 'package:mora_tests/models/step_result.dart';
import 'package:mora_tests/models/test_run.dart';
import 'package:mora_tests/services/report_service.dart';

void main() {
  final emptyPng = Uint8List(0);
  final now = DateTime(2025, 6, 15, 9, 5, 3);

  StepResult makeStep({
    bool success = true,
    String stepId = 's1',
    String? errorMessage,
    LlmAction? action,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return StepResult(
      stepId: stepId,
      success: success,
      screenshotBefore: emptyPng,
      errorMessage: errorMessage,
      actionTaken: action,
      duration: duration,
      executedAt: now,
    );
  }

  TestRun makeRun({
    String name = 'My Test',
    List<StepResult> results = const [],
    RunStatus status = RunStatus.completed,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return TestRun(
      id: 'run-1',
      testCaseId: 'tc-1',
      testCaseName: name,
      startedAt: startedAt ?? now,
      finishedAt: finishedAt ?? now.add(const Duration(seconds: 10)),
      status: status,
      results: results,
    );
  }

  // ── Basic HTML structure ───────────────────────────────────────────────────

  group('generateHtml structure', () {
    test('returns valid HTML document', () {
      final html = ReportService.generateHtml([]);
      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html, contains('<html'));
      expect(html, contains('</html>'));
      expect(html, contains('<head>'));
      expect(html, contains('</head>'));
      expect(html, contains('<body>'));
      expect(html, contains('</body>'));
    });

    test('includes page title with date', () {
      final html = ReportService.generateHtml([]);
      expect(html, contains('<title>'));
      expect(html, contains('MoraTests Report'));
    });

    test('embeds CSS styles', () {
      final html = ReportService.generateHtml([]);
      expect(html, contains('<style>'));
      expect(html, contains('</style>'));
    });
  });

  // ── Summary pills ──────────────────────────────────────────────────────────

  group('summary pills', () {
    test('empty run list shows 0 passed and 0 failed', () {
      final html = ReportService.generateHtml([]);
      expect(html, contains('0 passed'));
      expect(html, contains('0 failed'));
    });

    test('counts passed and failed runs correctly', () {
      final passedRun = makeRun(
        name: 'Pass',
        results: [makeStep(success: true)],
        status: RunStatus.completed,
      );
      final failedRun = makeRun(
        name: 'Fail',
        results: [makeStep(success: false)],
        status: RunStatus.completed,
      );

      final html = ReportService.generateHtml([passedRun, failedRun]);
      expect(html, contains('1 passed'));
      expect(html, contains('1 failed'));
    });

    test('total run count shown with plural', () {
      final runs = [makeRun(), makeRun()];
      final html = ReportService.generateHtml(runs);
      expect(html, contains('2 runs'));
    });

    test('single run shows singular', () {
      final html = ReportService.generateHtml([makeRun()]);
      expect(html, contains('1 run'));
      expect(html, isNot(contains('1 runs')));
    });
  });

  // ── Run section ────────────────────────────────────────────────────────────

  group('run section', () {
    test('test case name appears in HTML (escaped)', () {
      final run = makeRun(name: 'Login Flow Test');
      final html = ReportService.generateHtml([run]);
      expect(html, contains('Login Flow Test'));
    });

    test('test case name with special chars is HTML-escaped', () {
      final run = makeRun(name: 'A & B <Test>');
      final html = ReportService.generateHtml([run]);
      expect(html, contains('A &amp; B &lt;Test&gt;'));
      expect(html, isNot(contains('A & B <Test>')));
    });

    test('step count appears in run meta', () {
      final run = makeRun(
        results: [makeStep(stepId: 's1'), makeStep(stepId: 's2')],
      );
      final html = ReportService.generateHtml([run]);
      // passedCount/results.length: e.g. "2/2 steps"
      expect(html, contains('2/2 steps'));
    });

    test('passed run has pass CSS class', () {
      final run = makeRun(
        results: [makeStep(success: true)],
        status: RunStatus.completed,
      );
      final html = ReportService.generateHtml([run]);
      expect(html, contains('class="run pass"'));
    });

    test('failed run has fail CSS class', () {
      final run = makeRun(
        results: [makeStep(success: false)],
        status: RunStatus.completed,
      );
      final html = ReportService.generateHtml([run]);
      expect(html, contains('class="run fail"'));
    });
  });

  // ── Step section ───────────────────────────────────────────────────────────

  group('step section', () {
    test('step number is 1-based', () {
      final run = makeRun(results: [makeStep()]);
      final html = ReportService.generateHtml([run]);
      expect(html, contains('Step 1'));
    });

    test('error message is escaped and included', () {
      final run = makeRun(
        results: [makeStep(success: false, errorMessage: 'Element <x> not found')],
      );
      final html = ReportService.generateHtml([run]);
      expect(html, contains('Element &lt;x&gt; not found'));
    });

    test('action type badge is shown', () {
      const action = LlmAction(
        type: ActionType.click,
        x: 50,
        y: 100,
        confidence: 0.95,
        reasoning: 'Clicked submit',
      );
      final run = makeRun(results: [makeStep(action: action)]);
      final html = ReportService.generateHtml([run]);
      expect(html, contains('click'));
    });

    test('action reasoning is included', () {
      const action = LlmAction(
        type: ActionType.type,
        confidence: 0.8,
        reasoning: 'Typed into email field',
      );
      final run = makeRun(results: [makeStep(action: action)]);
      final html = ReportService.generateHtml([run]);
      expect(html, contains('Typed into email field'));
    });

    test('confidence percentage is shown', () {
      const action = LlmAction(
        type: ActionType.click,
        confidence: 0.75,
        reasoning: '',
      );
      final run = makeRun(results: [makeStep(action: action)]);
      final html = ReportService.generateHtml([run]);
      expect(html, contains('75%'));
    });
  });

  // ── Duration formatting ────────────────────────────────────────────────────

  group('duration formatting', () {
    test('duration under 60s shows seconds', () {
      final run = makeRun(
        startedAt: now,
        finishedAt: now.add(const Duration(seconds: 45)),
      );
      final html = ReportService.generateHtml([run]);
      expect(html, contains('45s'));
    });

    test('duration over 60s shows minutes and seconds', () {
      final run = makeRun(
        startedAt: now,
        finishedAt: now.add(const Duration(minutes: 2, seconds: 30)),
      );
      final html = ReportService.generateHtml([run]);
      expect(html, contains('2m'));
      expect(html, contains('30s'));
    });

    test('step duration under 1000ms shows milliseconds', () {
      final run = makeRun(
        results: [makeStep(duration: const Duration(milliseconds: 850))],
      );
      final html = ReportService.generateHtml([run]);
      expect(html, contains('850ms'));
    });

    test('step duration over 1000ms shows seconds with decimal', () {
      final run = makeRun(
        results: [makeStep(duration: const Duration(milliseconds: 2500))],
      );
      final html = ReportService.generateHtml([run]);
      expect(html, contains('2.5s'));
    });
  });

  // ── Multiple runs ──────────────────────────────────────────────────────────

  group('multiple runs', () {
    test('all run names appear in HTML', () {
      final runs = [
        makeRun(name: 'Test Alpha'),
        makeRun(name: 'Test Beta'),
        makeRun(name: 'Test Gamma'),
      ];
      final html = ReportService.generateHtml(runs);
      expect(html, contains('Test Alpha'));
      expect(html, contains('Test Beta'));
      expect(html, contains('Test Gamma'));
    });

    test('step indices are correct per run', () {
      final runs = [
        makeRun(
          name: 'Run A',
          results: [makeStep(stepId: 'a1'), makeStep(stepId: 'a2')],
        ),
      ];
      final html = ReportService.generateHtml(runs);
      expect(html, contains('Step 1'));
      expect(html, contains('Step 2'));
    });
  });
}
