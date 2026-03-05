import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mora_tests/core/exceptions.dart';
import 'package:mora_tests/models/test_case.dart';
import 'package:mora_tests/services/storage_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late StorageService storage;
  late Directory tempDir;

  setUp(() async {
    storage = StorageService();
    tempDir = await Directory.systemTemp.createTemp('mora_tests_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<File> writeYaml(String name, String content) async {
    final file = File(p.join(tempDir.path, name));
    await file.writeAsString(content);
    return file;
  }

  // ── loadTestCase ─────────────────────────────────────────────────────────

  group('loadTestCase', () {
    test('parses minimal required fields', () async {
      final file = await writeYaml('minimal.yaml', '''
id: "test-001"
name: "Minimal Test"
start_url: "https://example.com"
steps: []
''');
      final tc = await storage.loadTestCase(file.path);

      expect(tc.id, equals('test-001'));
      expect(tc.name, equals('Minimal Test'));
      expect(tc.startUrl, equals('https://example.com'));
      expect(tc.steps, isEmpty);
      expect(tc.filePath, equals(file.path));
    });

    test('parses description field', () async {
      final file = await writeYaml('desc.yaml', '''
id: "test-002"
name: "With Description"
start_url: "https://example.com"
description: "This test verifies the login flow"
steps: []
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.description, equals('This test verifies the login flow'));
    });

    test('generates UUID when id is absent', () async {
      final file = await writeYaml('no_id.yaml', '''
name: "No ID Test"
start_url: "https://example.com"
steps: []
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.id, isNotEmpty);
      expect(tc.id.length, greaterThan(10));
    });

    test('uses filename as name when name is absent', () async {
      final file = await writeYaml('my_feature.yaml', '''
start_url: "https://example.com"
steps: []
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.name, equals('my_feature'));
    });

    test('parses variables block', () async {
      final file = await writeYaml('vars.yaml', '''
id: "test-003"
name: "Variables Test"
start_url: "https://example.com"
variables:
  username: "admin@test.com"
  password: "secret123"
steps: []
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.variables['username'], equals('admin@test.com'));
      expect(tc.variables['password'], equals('secret123'));
    });

    test('empty variables block produces empty map', () async {
      final file = await writeYaml('no_vars.yaml', '''
id: "test-004"
name: "No Vars"
start_url: "https://example.com"
steps: []
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.variables, isEmpty);
    });

    test('parses standard step fields', () async {
      final file = await writeYaml('steps.yaml', '''
id: "test-005"
name: "Steps Test"
start_url: "https://example.com"
steps:
  - id: "step-001"
    instruction: "Click the login button"
    hint: "Blue button at the bottom"
    assert: "Dashboard should load"
    timeout: 25
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.steps.length, equals(1));

      final step = tc.steps.first;
      expect(step.id, equals('step-001'));
      expect(step.instruction, equals('Click the login button'));
      expect(step.hint, equals('Blue button at the bottom'));
      expect(step.assertion, equals('Dashboard should load'));
      expect(step.timeoutSeconds, equals(25));
    });

    test('step defaults timeout to 30 when absent', () async {
      final file = await writeYaml('default_timeout.yaml', '''
id: "test-006"
name: "Default Timeout"
start_url: "https://example.com"
steps:
  - id: "s1"
    instruction: "Do something"
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.steps.first.timeoutSeconds, equals(30));
    });

    test('parses explore step with max_sub_steps', () async {
      final file = await writeYaml('explore.yaml', '''
id: "test-007"
name: "Explore Test"
start_url: "https://example.com"
steps:
  - id: "s1"
    instruction: "Navigate to companies"
    max_sub_steps: 8
    timeout: 60
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.steps.first.maxSubSteps, equals(8));
    });

    test('maxSubSteps is null for standard steps', () async {
      final file = await writeYaml('no_max.yaml', '''
id: "test-008"
name: "Standard Step"
start_url: "https://example.com"
steps:
  - id: "s1"
    instruction: "Click button"
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.steps.first.maxSubSteps, isNull);
    });

    test('parses call step with with-vars', () async {
      final file = await writeYaml('call_step.yaml', '''
id: "test-009"
name: "Call Step Test"
start_url: "https://example.com"
steps:
  - id: "s1"
    call: "shared/login.yaml"
    with:
      username: "admin@test.com"
      password: "pass123"
''');
      final tc = await storage.loadTestCase(file.path);
      final step = tc.steps.first;
      expect(step.call, equals('shared/login.yaml'));
      expect(step.withVars['username'], equals('admin@test.com'));
      expect(step.withVars['password'], equals('pass123'));
    });

    test('parses seeder hook', () async {
      final file = await writeYaml('seeder.yaml', '''
id: "test-010"
name: "Seeder Test"
start_url: "https://example.com"
seeder:
  url: "https://api.example.com/seed"
  method: "POST"
  headers:
    Authorization: "Bearer token123"
  body: '{"role": "admin"}'
  timeout: 15
steps: []
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.seeder, isNotNull);
      expect(tc.seeder!.url, equals('https://api.example.com/seed'));
      expect(tc.seeder!.method, equals('POST'));
      expect(tc.seeder!.headers['Authorization'], equals('Bearer token123'));
      expect(tc.seeder!.body, equals('{"role": "admin"}'));
      expect(tc.seeder!.timeoutSeconds, equals(15));
    });

    test('parses teardown hook', () async {
      final file = await writeYaml('teardown.yaml', '''
id: "test-011"
name: "Teardown Test"
start_url: "https://example.com"
teardown:
  url: "https://api.example.com/cleanup"
  method: "DELETE"
steps: []
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.teardown, isNotNull);
      expect(tc.teardown!.url, equals('https://api.example.com/cleanup'));
      expect(tc.teardown!.method, equals('DELETE'));
    });

    test('seeder defaults method to POST', () async {
      final file = await writeYaml('seeder_default.yaml', '''
id: "test-012"
name: "Seeder Default"
start_url: "https://example.com"
seeder:
  url: "https://api.example.com/seed"
steps: []
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.seeder!.method, equals('POST'));
    });

    test('seeder with no headers produces empty map', () async {
      final file = await writeYaml('seeder_no_headers.yaml', '''
id: "test-013"
name: "No Headers"
start_url: "https://example.com"
seeder:
  url: "https://api.example.com/seed"
steps: []
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.seeder!.headers, isEmpty);
    });

    test('seeder and teardown are null when not present', () async {
      final file = await writeYaml('no_hooks.yaml', '''
id: "test-014"
name: "No Hooks"
start_url: "https://example.com"
steps: []
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.seeder, isNull);
      expect(tc.teardown, isNull);
    });

    test('throws StorageException for non-existent file', () async {
      expect(
        () => storage.loadTestCase('/non/existent/path.yaml'),
        throwsA(isA<StorageException>()),
      );
    });

    test('throws StorageException for malformed YAML', () async {
      final file = await writeYaml('bad.yaml', '''
this: is: not: valid: yaml: at all:
  - broken
    indentation:
''');
      // The YAML library may or may not throw — StorageException should be
      // wrapped regardless of the underlying error type.
      expect(
        () => storage.loadTestCase(file.path),
        throwsA(isA<StorageException>()),
      );
    });

    test('parses multiple steps in order', () async {
      final file = await writeYaml('multi_steps.yaml', '''
id: "test-015"
name: "Multi Steps"
start_url: "https://example.com"
steps:
  - id: "s1"
    instruction: "First step"
  - id: "s2"
    instruction: "Second step"
  - id: "s3"
    instruction: "Third step"
''');
      final tc = await storage.loadTestCase(file.path);
      expect(tc.steps.length, equals(3));
      expect(tc.steps[0].instruction, equals('First step'));
      expect(tc.steps[1].instruction, equals('Second step'));
      expect(tc.steps[2].instruction, equals('Third step'));
    });
  });

  // ── loadTestCasesFromDirectory ────────────────────────────────────────────

  group('loadTestCasesFromDirectory', () {
    test('loads all yaml files from a directory', () async {
      await writeYaml('test1.yaml', '''
id: "t1"
name: "Test 1"
start_url: "https://example.com"
steps: []
''');
      await writeYaml('test2.yaml', '''
id: "t2"
name: "Test 2"
start_url: "https://example.com"
steps: []
''');
      // Non-yaml file should be ignored
      await File(p.join(tempDir.path, 'notes.txt')).writeAsString('ignored');

      final cases = await storage.loadTestCasesFromDirectory(tempDir.path);
      expect(cases.length, equals(2));
      expect(cases.map((c) => c.name), containsAll(['Test 1', 'Test 2']));
    });

    test('returns empty list for empty directory', () async {
      final cases = await storage.loadTestCasesFromDirectory(tempDir.path);
      expect(cases, isEmpty);
    });

    test('throws StorageException for non-existent directory', () async {
      expect(
        () => storage.loadTestCasesFromDirectory('/non/existent/dir'),
        throwsA(isA<StorageException>()),
      );
    });

    test('skips invalid yaml files silently', () async {
      await writeYaml('valid.yaml', '''
id: "v1"
name: "Valid"
start_url: "https://example.com"
steps: []
''');
      await writeYaml('invalid.yaml', 'not: valid: yaml:\n  broken::\n');

      final cases = await storage.loadTestCasesFromDirectory(tempDir.path);
      // At least the valid file should be loaded; invalid silently skipped
      expect(cases.where((c) => c.id == 'v1'), isNotEmpty);
    });
  });

  // ── saveTestCase / roundtrip ───────────────────────────────────────────────

  group('saveTestCase', () {
    test('saves and reloads a TestCase (roundtrip)', () async {
      final original = TestCase(
        id: 'rt-001',
        name: 'Roundtrip Test',
        description: 'A test for roundtrip',
        startUrl: 'https://example.com',
        variables: {'user': 'alice', 'role': 'admin'},
        steps: [],
      );

      final filePath = p.join(tempDir.path, 'roundtrip.yaml');
      await storage.saveTestCase(original, filePath);

      final reloaded = await storage.loadTestCase(filePath);

      expect(reloaded.id, equals(original.id));
      expect(reloaded.name, equals(original.name));
      expect(reloaded.description, equals(original.description));
      expect(reloaded.startUrl, equals(original.startUrl));
      expect(reloaded.variables['user'], equals('alice'));
      expect(reloaded.variables['role'], equals('admin'));
    });

    test('throws StorageException when path is not writable', () async {
      final tc = TestCase(
        id: 'x',
        name: 'X',
        startUrl: 'https://example.com',
      );
      expect(
        () => storage.saveTestCase(tc, '/root/no_permission.yaml'),
        throwsA(isA<StorageException>()),
      );
    });
  });
}
