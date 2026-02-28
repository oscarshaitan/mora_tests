import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../core/exceptions.dart';
import '../models/http_hook.dart';
import '../models/test_case.dart';
import '../models/test_step.dart';

class StorageService {
  static const _uuid = Uuid();

  /// Load a single YAML file as a [TestCase].
  Future<TestCase> loadTestCase(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final yaml = loadYaml(content) as YamlMap;
      return _parseTestCase(yaml, filePath);
    } catch (e) {
      throw StorageException('Failed to load $filePath: $e');
    }
  }

  /// Load all YAML files from a directory.
  Future<List<TestCase>> loadTestCasesFromDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      throw StorageException('Directory not found: $dirPath');
    }

    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith('.yaml'))
        .cast<File>()
        .toList();

    final results = <TestCase>[];
    for (final file in files) {
      try {
        results.add(await loadTestCase(file.path));
      } catch (_) {
        // Skip invalid files
      }
    }
    return results;
  }

  /// Save a [TestCase] to [filePath] (overwrites if exists).
  Future<void> saveTestCase(TestCase testCase, String filePath) async {
    try {
      final map = _testCaseToMap(testCase);
      final writer = YamlWriter();
      final yaml = writer.write(map);
      await File(filePath).writeAsString(yaml);
    } catch (e) {
      throw StorageException('Failed to save $filePath: $e');
    }
  }

  // ── Parsing ────────────────────────────────────────────────────────────────

  TestCase _parseTestCase(YamlMap yaml, String filePath) {
    final steps = (yaml['steps'] as YamlList? ?? YamlList())
        .map((s) => _parseStep(s as YamlMap))
        .toList();

    return TestCase(
      id: yaml['id']?.toString() ?? _uuid.v4(),
      name: yaml['name']?.toString() ?? p.basenameWithoutExtension(filePath),
      description: yaml['description']?.toString() ?? '',
      startUrl: yaml['start_url']?.toString() ?? '',
      seeder: yaml['seeder'] != null
          ? _parseHook(yaml['seeder'] as YamlMap)
          : null,
      teardown: yaml['teardown'] != null
          ? _parseHook(yaml['teardown'] as YamlMap)
          : null,
      steps: steps,
      variables: _parseStringMap(yaml['variables']),
      filePath: filePath,
    );
  }

  TestStep _parseStep(YamlMap yaml) {
    return TestStep(
      id: yaml['id']?.toString() ?? _uuid.v4(),
      instruction: yaml['instruction']?.toString() ?? '',
      hint: yaml['hint']?.toString(),
      assertion: yaml['assert']?.toString(),
      timeoutSeconds: (yaml['timeout'] as int?) ?? 30,
    );
  }

  HttpHook _parseHook(YamlMap yaml) {
    return HttpHook(
      url: yaml['url']?.toString() ?? '',
      method: yaml['method']?.toString() ?? 'POST',
      headers: _parseStringMap(yaml['headers']),
      body: yaml['body']?.toString(),
      timeoutSeconds: (yaml['timeout'] as int?) ?? 10,
    );
  }

  Map<String, String> _parseStringMap(dynamic value) {
    if (value == null) return {};
    if (value is YamlMap) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): entry.value.toString(),
      };
    }
    return {};
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  Map<String, dynamic> _testCaseToMap(TestCase tc) {
    final map = <String, dynamic>{
      'id': tc.id,
      'name': tc.name,
      if (tc.description.isNotEmpty) 'description': tc.description,
      'start_url': tc.startUrl,
    };

    if (tc.seeder != null) map['seeder'] = _hookToMap(tc.seeder!);
    if (tc.teardown != null) map['teardown'] = _hookToMap(tc.teardown!);
    if (tc.variables.isNotEmpty) map['variables'] = tc.variables;

    map['steps'] = tc.steps.map(_stepToMap).toList();
    return map;
  }

  Map<String, dynamic> _stepToMap(TestStep step) {
    return {
      'id': step.id,
      'instruction': step.instruction,
      if (step.hint != null && step.hint!.isNotEmpty) 'hint': step.hint,
      if (step.assertion != null && step.assertion!.isNotEmpty)
        'assert': step.assertion,
      'timeout': step.timeoutSeconds,
    };
  }

  Map<String, dynamic> _hookToMap(HttpHook hook) {
    return {
      'url': hook.url,
      'method': hook.method,
      if (hook.headers.isNotEmpty) 'headers': hook.headers,
      if (hook.body != null) 'body': hook.body,
      'timeout': hook.timeoutSeconds,
    };
  }

  /// Export a list of run results as JSON to [filePath].
  Future<void> exportResults(
    List<Map<String, dynamic>> results,
    String filePath,
  ) async {
    final json = const JsonEncoder.withIndent('  ').convert(results);
    await File(filePath).writeAsString(json);
  }
}
