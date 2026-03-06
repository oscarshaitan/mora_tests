import 'package:flutter_test/flutter_test.dart';
import 'package:mora_tests/services/maestro_translator.dart';

void main() {
  // ── TranslationError ────────────────────────────────────────────────────────

  group('TranslationError', () {
    test('toString with line number includes file basename and command', () {
      const err = TranslationError(
        file: '/path/to/my_test.yaml',
        line: 5,
        command: 'unknownCmd',
      );
      final s = err.toString();
      expect(s, contains('my_test.yaml'));
      expect(s, contains('5'));
      expect(s, contains('unknownCmd'));
    });

    test('toString with line=0 omits line number', () {
      const err = TranslationError(
        file: '/path/to/my_test.yaml',
        line: 0,
        command: 'some error message',
      );
      final s = err.toString();
      expect(s, contains('my_test.yaml'));
      expect(s, contains('some error message'));
      expect(s, isNot(contains(':0')));
    });
  });

  // ── TranslationResult ──────────────────────────────────────────────────────

  group('TranslationResult.hasErrors', () {
    test('hasErrors is false when errors list is empty', () {
      final result = MaestroTranslator.translate('- tapOn: Login', '/f.yaml');
      expect(result.hasErrors, isFalse);
    });

    test('hasErrors is true when unknown commands are present', () {
      final result =
          MaestroTranslator.translate('- unknownCommand: value', '/f.yaml');
      expect(result.hasErrors, isTrue);
      expect(result.errors, hasLength(1));
    });
  });

  // ── _formatName (via result.testCase.name) ─────────────────────────────────

  group('_formatName', () {
    test('converts hyphens and underscores to title case', () {
      final result =
          MaestroTranslator.translate('- tapOn: Login', '/login-flow_test.yaml');
      expect(result.testCase.name, equals('Login Flow Test'));
    });

    test('single word capitalised', () {
      final result =
          MaestroTranslator.translate('- tapOn: Ok', '/checkout.yaml');
      expect(result.testCase.name, equals('Checkout'));
    });
  });

  // ── Header parsing ─────────────────────────────────────────────────────────

  group('header parsing', () {
    test('extracts appId into description', () {
      const yaml = '''
appId: com.example.app
---
- tapOn: Login
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.description, contains('com.example.app'));
    });

    test('no appId → generic description', () {
      const yaml = '- tapOn: Login';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.description, equals('Imported from Maestro'));
    });

    test('file with leading --- marker is parsed correctly', () {
      const yaml = '''---
- tapOn: Submit
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.instruction, contains('Submit'));
    });

    test('header with leading --- marker is parsed correctly', () {
      const yaml = '''---
appId: com.example
---
- tapOn: Submit
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.description, contains('com.example'));
      expect(result.testCase.steps, hasLength(1));
    });
  });

  // ── Skippable commands ─────────────────────────────────────────────────────

  group('skippable commands', () {
    for (final cmd in [
      'launchApp',
      'hideKeyboard',
      'waitForAnimationToEnd',
      'takeScreenshot',
      'stopApp',
      'clearState',
      'evalScript',
      'runScript',
      'setLocation',
      'setAirplaneMode',
    ]) {
      test('$cmd is silently skipped', () {
        final result =
            MaestroTranslator.translate('- $cmd: anything', '/f.yaml');
        expect(result.testCase.steps, isEmpty);
        expect(result.errors, isEmpty);
      });
    }
  });

  // ── tapOn / tap ────────────────────────────────────────────────────────────

  group('tapOn / tap', () {
    test('tapOn with string value', () {
      final result =
          MaestroTranslator.translate('- tapOn: Login Button', '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.instruction,
          equals('Tap "Login Button"'));
    });

    test('tap alias works the same as tapOn', () {
      final result =
          MaestroTranslator.translate('- tap: OK', '/f.yaml');
      expect(result.testCase.steps.first.instruction, equals('Tap "OK"'));
    });

    test('tapOn with id selector', () {
      const yaml = '''
- tapOn:
    id: submit_btn
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          contains('submit_btn'));
    });

    test('tapOn with text + index uses ordinal', () {
      const yaml = '''
- tapOn:
    text: Item
    index: 1
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps.first.instruction, contains('second'));
      expect(result.testCase.steps.first.instruction, contains('Item'));
    });

    test('tapOn with point coordinate', () {
      const yaml = '''
- tapOn:
    point: "50%,80%"
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps.first.instruction, contains('50%,80%'));
    });

    test('tapOn with x/y coordinate', () {
      const yaml = '''
- tapOn:
    x: 100
    y: 200
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          equals('Tap coordinate (100, 200)'));
    });

    test('tapOn cleans leading/trailing .* regex anchors', () {
      final result =
          MaestroTranslator.translate('- tapOn: ".*Login.*"', '/f.yaml');
      expect(result.testCase.steps.first.instruction, equals('Tap "Login"'));
    });
  });

  // ── tapOn + inputText merge ────────────────────────────────────────────────

  group('tapOn + inputText merge', () {
    test('tapOn followed by inputText merges into single step', () {
      const yaml = '''
- tapOn: Email
- inputText: user@example.com
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.instruction,
          equals('Tap "Email" and type "user@example.com"'));
    });

    test('tapOn + inputText + assertVisible absorbs assertion', () {
      const yaml = '''
- tapOn: Username
- inputText: alice
- assertVisible: alice
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.assertion, isNotNull);
      expect(result.testCase.steps.first.assertion, contains('alice'));
    });

    test('multiple tapOn + inputText pairs each merge independently', () {
      const yaml = '''
- tapOn: Email
- inputText: user@test.com
- tapOn: Password
- inputText: secret
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(2));
      expect(result.testCase.steps[0].instruction, contains('Email'));
      expect(result.testCase.steps[1].instruction, contains('Password'));
    });
  });

  // ── inputText (standalone) ─────────────────────────────────────────────────

  group('inputText (standalone)', () {
    test('not preceded by tapOn creates a type step', () {
      // launchApp skipped, so inputText is first real command
      const yaml = '''
- launchApp
- inputText: hello
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.instruction, equals('Type "hello"'));
    });
  });

  // ── longPressOn / doubleTapOn ──────────────────────────────────────────────

  group('longPressOn / doubleTapOn', () {
    test('longPressOn creates long press step', () {
      final result =
          MaestroTranslator.translate('- longPressOn: Item', '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          equals('Long press "Item"'));
    });

    test('doubleTapOn creates double tap step', () {
      final result =
          MaestroTranslator.translate('- doubleTapOn: Card', '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          equals('Double tap "Card"'));
    });
  });

  // ── clearTextField / eraseText ─────────────────────────────────────────────

  group('clearTextField / eraseText', () {
    test('clearTextField without value', () {
      final result =
          MaestroTranslator.translate('- clearTextField', '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          equals('Clear the text field'));
    });

    test('clearTextField with string target', () {
      final result = MaestroTranslator.translate(
          '- clearTextField: Search', '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          contains('Clear the text field'));
      expect(result.testCase.steps.first.instruction,
          contains('Search'));
    });

    test('eraseText works same as clearTextField', () {
      final result =
          MaestroTranslator.translate('- eraseText', '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          equals('Clear the text field'));
    });
  });

  // ── scroll ─────────────────────────────────────────────────────────────────

  group('scroll', () {
    test('scroll without direction defaults to scroll down', () {
      final result = MaestroTranslator.translate('- scroll', '/f.yaml');
      expect(result.testCase.steps.first.instruction, equals('Scroll down'));
    });

    test('scroll with direction', () {
      const yaml = '''
- scroll:
    direction: UP
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps.first.instruction, equals('Scroll up'));
    });
  });

  // ── swipe ──────────────────────────────────────────────────────────────────

  group('swipe', () {
    test('swipe without direction', () {
      final result = MaestroTranslator.translate('- swipe', '/f.yaml');
      expect(result.testCase.steps.first.instruction, equals('Swipe'));
    });

    test('swipe with direction', () {
      const yaml = '''
- swipe:
    direction: left
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps.first.instruction, equals('Swipe left'));
    });
  });

  // ── scrollUntilVisible ─────────────────────────────────────────────────────

  group('scrollUntilVisible', () {
    test('without element uses generic label', () {
      final result =
          MaestroTranslator.translate('- scrollUntilVisible', '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          equals('Scroll until the element is visible'));
    });

    test('with element uses its label', () {
      const yaml = '''
- scrollUntilVisible:
    element: Load More
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          contains('Load More'));
    });
  });

  // ── back / pressKey / openLink / wait ─────────────────────────────────────

  group('simple commands', () {
    test('back creates go back step', () {
      final result = MaestroTranslator.translate('- back', '/f.yaml');
      expect(result.testCase.steps.first.instruction, equals('Go back'));
    });

    test('pressKey creates press step', () {
      final result =
          MaestroTranslator.translate('- pressKey: Enter', '/f.yaml');
      expect(result.testCase.steps.first.instruction, equals('Press Enter'));
    });

    test('openLink creates navigate step', () {
      final result =
          MaestroTranslator.translate('- openLink: https://example.com', '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          equals('Navigate to "https://example.com"'));
    });

    test('wait creates settle step', () {
      final result = MaestroTranslator.translate('- wait', '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          equals('Wait for the page to settle'));
    });
  });

  // ── extendedWaitUntil ─────────────────────────────────────────────────────

  group('extendedWaitUntil', () {
    test('with visible uses correct instruction and assertion', () {
      const yaml = '''
- extendedWaitUntil:
    visible: Dashboard
    timeout: 5000
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      final step = result.testCase.steps.first;
      expect(step.instruction, contains('Dashboard'));
      expect(step.instruction, contains('visible'));
      expect(step.assertion, contains('Dashboard'));
      expect(step.timeoutSeconds, equals(5));
    });

    test('with notVisible uses not visible assertion', () {
      const yaml = '''
- extendedWaitUntil:
    notVisible: Spinner
    timeout: 10000
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      final step = result.testCase.steps.first;
      expect(step.instruction, contains('not visible'));
      expect(step.assertion, contains('not be visible'));
      expect(step.timeoutSeconds, equals(10));
    });

    test('no visibility key falls back to generic wait', () {
      const yaml = '''
- extendedWaitUntil:
    timeout: 3000
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          equals('Wait for condition'));
    });

    test('without value is generic wait', () {
      final result =
          MaestroTranslator.translate('- extendedWaitUntil', '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          equals('Wait for condition'));
    });
  });

  // ── assertVisible / assertNotVisible ──────────────────────────────────────

  group('assert commands', () {
    test('assertVisible absorbed into previous step', () {
      const yaml = '''
- tapOn: Submit
- assertVisible: Success
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.assertion, contains('Success'));
      expect(result.testCase.steps.first.assertion,
          isNot(contains('not visible')));
    });

    test('assertNotVisible absorbed with correct polarity', () {
      const yaml = '''
- tapOn: Delete
- assertNotVisible: Confirm Dialog
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.assertion, contains('not be visible'));
    });

    test('assert as first command creates stub verify step', () {
      const yaml = '''
- assertVisible: Welcome
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.instruction,
          equals('Verify the page state'));
      expect(result.testCase.steps.first.assertion, contains('Welcome'));
    });

    test('multiple asserts chain with semicolon', () {
      const yaml = '''
- tapOn: Submit
- assertVisible: Done
- assertNotVisible: Error
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      final assertion = result.testCase.steps.first.assertion!;
      expect(assertion, contains('Done'));
      expect(assertion, contains('Error'));
      expect(assertion, contains(';'));
    });

    test('regular step after assert starts fresh step', () {
      const yaml = '''
- tapOn: Submit
- assertVisible: Result
- tapOn: Back
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(2));
    });
  });

  // ── repeat block ───────────────────────────────────────────────────────────

  group('repeat block', () {
    test('creates a single descriptive step', () {
      const yaml = '''
- repeat:
    times: 3
    commands:
      - tapOn: Next
      - scroll
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      final instr = result.testCase.steps.first.instruction;
      expect(instr, contains('3'));
      expect(instr, startsWith('Repeat'));
    });

    test('repeat without commands still creates step', () {
      const yaml = '''
- repeat:
    times: 5
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.instruction, contains('5'));
    });
  });

  // ── runFlow ────────────────────────────────────────────────────────────────

  group('runFlow', () {
    test('string path creates a call step', () {
      final result = MaestroTranslator.translate(
          '- runFlow: shared/login.yaml', '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.call,
          equals('shared/login.yaml'));
    });

    test('map with path creates call step', () {
      const yaml = '''
- runFlow:
    path: shared/login.yaml
    env:
      USERNAME: alice
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.call, equals('shared/login.yaml'));
      expect(result.testCase.steps.first.withVars['USERNAME'], equals('alice'));
    });

    test('runFlow with when+visible creates condition step + inner steps', () {
      const yaml = '''
- runFlow:
    when:
      visible: Modal
    commands:
      - tapOn: Close
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps.length, greaterThanOrEqualTo(2));
      expect(result.testCase.steps.first.assertion, contains('Modal'));
      final tapStep = result.testCase.steps.last;
      expect(tapStep.instruction, contains('Close'));
    });

    test('runFlow with when+notVisible creates notVisible condition step', () {
      const yaml = '''
- runFlow:
    when:
      notVisible: Spinner
    commands:
      - tapOn: Continue
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps.first.assertion, contains('not be visible'));
    });
  });

  // ── copyTextFrom ───────────────────────────────────────────────────────────

  group('copyTextFrom', () {
    test('map form uses label and element', () {
      const yaml = '''
- copyTextFrom:
    label: orderId
    text: Order #
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          contains('orderId'));
    });

    test('non-map form creates generic copy step', () {
      final result =
          MaestroTranslator.translate('- copyTextFrom: someElement', '/f.yaml');
      expect(result.testCase.steps.first.instruction,
          contains('Copy text'));
    });
  });

  // ── unknown command → error ────────────────────────────────────────────────

  group('unknown commands', () {
    test('unknown command is reported as error with line number', () {
      const yaml = '''
- tapOn: Login
- someWeirdCommand: value
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.errors, hasLength(1));
      expect(result.errors.first.command, equals('someWeirdCommand'));
      expect(result.errors.first.line, greaterThan(0));
    });

    test('multiple unknown commands all reported', () {
      const yaml = '''
- unknownA: 1
- unknownB: 2
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.errors, hasLength(2));
    });

    test('unknown command step is omitted from steps', () {
      const yaml = '''
- tapOn: Login
- unknownCmd
- back
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      // tapOn + back = 2 steps; unknownCmd omitted
      expect(result.testCase.steps, hasLength(2));
    });
  });

  // ── Regular step + inline assert absorption ────────────────────────────────

  group('regular step + inline assert', () {
    test('single step followed by assert absorbs assertion', () {
      const yaml = '''
- back
- assertVisible: Home
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
      expect(result.testCase.steps.first.instruction, equals('Go back'));
      expect(result.testCase.steps.first.assertion, contains('Home'));
    });
  });

  // ── _parseHttpFromJs (via translate with inline seeder workaround) ─────────
  // The seeder is read from a JS file on disk; we test the error path instead.

  group('seeder/teardown error when file not found', () {
    test('missing seeder script adds error but still creates testCase', () {
      const yaml = '''
onFlowStart:
  - runScript: ./nonexistent_seeder.js
---
- tapOn: Login
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      // seeder URL will be empty — error added, but testCase still created
      expect(result.testCase, isNotNull);
      expect(result.errors.any((e) => e.command.contains('onFlowStart')),
          isTrue);
    });

    test('missing teardown script adds error', () {
      const yaml = '''
onFlowComplete:
  - runScript: ./missing_teardown.js
---
- back
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(
          result.errors.any((e) => e.command.contains('onFlowComplete')), isTrue);
    });
  });

  // ── edge cases ─────────────────────────────────────────────────────────────

  group('edge cases', () {
    test('empty content produces empty steps', () {
      final result = MaestroTranslator.translate('', '/f.yaml');
      expect(result.testCase.steps, isEmpty);
      expect(result.errors, isEmpty);
    });

    test('null-valued list entries are skipped', () {
      const yaml = '''
-
- tapOn: OK
''';
      final result = MaestroTranslator.translate(yaml, '/f.yaml');
      expect(result.testCase.steps, hasLength(1));
    });

    test('testCase has a non-empty uuid id', () {
      final result = MaestroTranslator.translate('- back', '/f.yaml');
      expect(result.testCase.id, isNotEmpty);
      expect(result.testCase.id.length, greaterThan(10));
    });

    test('startUrl is empty (user must supply)', () {
      final result = MaestroTranslator.translate('- back', '/f.yaml');
      expect(result.testCase.startUrl, equals(''));
    });
  });
}
