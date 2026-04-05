import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../core/exceptions.dart';
import '../models/http_hook.dart';
import '../models/llm_action.dart';
import '../models/step_result.dart';
import '../models/test_case.dart';
import '../models/test_run.dart';
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
      viewportWidth: (yaml['viewport_width'] as int?) ?? 1280,
      viewportHeight: (yaml['viewport_height'] as int?) ?? 720,
      llmFallbackOnFail: (yaml['llm_fallback_on_fail'] as bool?) ?? false,
      filePath: filePath,
    );
  }

  TestStep _parseStep(YamlMap yaml) {
    LlmAction? resolvedAction;
    if (yaml['resolved_action'] != null) {
      final raw = yaml['resolved_action'] as YamlMap;
      resolvedAction =
          LlmAction.fromJson(Map<String, Object?>.from(raw));
    }
    return TestStep(
      id: yaml['id']?.toString() ?? _uuid.v4(),
      instruction: yaml['instruction']?.toString() ?? '',
      hint: yaml['hint']?.toString(),
      assertion: yaml['assert']?.toString(),
      timeoutSeconds: (yaml['timeout'] as int?) ?? 30,
      maxSubSteps: yaml['max_sub_steps'] as int?,
      call: yaml['call']?.toString(),
      withVars: _parseStringMap(yaml['with']),
      resolvedAction: resolvedAction,
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
    map['viewport_width'] = tc.viewportWidth;
    map['viewport_height'] = tc.viewportHeight;
    if (tc.llmFallbackOnFail) map['llm_fallback_on_fail'] = true;

    map['steps'] = tc.steps.map(_stepToMap).toList();
    return map;
  }

  Map<String, dynamic> _stepToMap(TestStep step) {
    return {
      'id': step.id,
      if (step.call != null) 'call': step.call,
      if (step.withVars.isNotEmpty) 'with': step.withVars,
      if (step.instruction.isNotEmpty) 'instruction': step.instruction,
      if (step.hint != null && step.hint!.isNotEmpty) 'hint': step.hint,
      if (step.assertion != null && step.assertion!.isNotEmpty)
        'assert': step.assertion,
      'timeout': step.timeoutSeconds,
      if (step.maxSubSteps != null) 'max_sub_steps': step.maxSubSteps,
      if (step.resolvedAction != null)
        'resolved_action': step.resolvedAction!.toJson(),
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

  // ── Run persistence ─────────────────────────────────────────────────────────

  Future<Directory> _runsDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'mora_tests_runs'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Saves a completed [TestRun] (including screenshots as base64) to disk.
  Future<void> saveTestRun(TestRun run) async {
    try {
      final dir = await _runsDir();
      final file = File(p.join(dir.path, '${run.id}.json'));
      final json = const JsonEncoder.withIndent('  ').convert(_runToJson(run));
      await file.writeAsString(json);
    } catch (_) {
      // Non-fatal — persistence failure should never break a test run
    }
  }

  /// Loads all previously saved [TestRun]s, newest first.
  /// Corrupt or unreadable files are silently skipped.
  Future<List<TestRun>> loadSavedRuns() async {
    try {
      final dir = await _runsDir();
      final files = await dir
          .list()
          .where((e) => e is File && e.path.endsWith('.json'))
          .cast<File>()
          .toList();

      final runs = <TestRun>[];
      for (final file in files) {
        try {
          final content = await file.readAsString();
          final map = jsonDecode(content) as Map<String, dynamic>;
          runs.add(_runFromJson(map));
        } catch (_) {
          // Skip corrupt files
        }
      }
      // Newest first
      runs.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return runs;
    } catch (_) {
      return [];
    }
  }

  // ── Run serialization ───────────────────────────────────────────────────────

  Map<String, dynamic> _runToJson(TestRun run) => {
        'id': run.id,
        'testCaseId': run.testCaseId,
        'testCaseName': run.testCaseName,
        'startedAt': run.startedAt.toIso8601String(),
        'finishedAt': run.finishedAt?.toIso8601String(),
        'status': run.status.name,
        'results': run.results.map(_stepResultToJson).toList(),
      };

  Map<String, dynamic> _stepResultToJson(StepResult r) => {
        'stepId': r.stepId,
        'success': r.success,
        'actionTaken': r.actionTaken?.toJson(),
        'screenshotBefore': base64Encode(r.screenshotBefore),
        'screenshotAfter':
            r.screenshotAfter != null ? base64Encode(r.screenshotAfter!) : null,
        'errorMessage': r.errorMessage,
        'rawLlmResponse': r.rawLlmResponse,
        'durationMs': r.duration.inMilliseconds,
        'executedAt': r.executedAt.toIso8601String(),
      };

  TestRun _runFromJson(Map<String, dynamic> m) => TestRun(
        id: m['id'] as String,
        testCaseId: m['testCaseId'] as String,
        testCaseName: m['testCaseName'] as String,
        startedAt: DateTime.parse(m['startedAt'] as String),
        finishedAt: m['finishedAt'] != null
            ? DateTime.parse(m['finishedAt'] as String)
            : null,
        status: RunStatus.values.byName(m['status'] as String),
        results: (m['results'] as List<dynamic>)
            .map((e) => _stepResultFromJson(e as Map<String, dynamic>))
            .toList(),
      );

  StepResult _stepResultFromJson(Map<String, dynamic> m) => StepResult(
        stepId: m['stepId'] as String,
        success: m['success'] as bool,
        actionTaken: m['actionTaken'] != null
            ? LlmAction.fromJson(m['actionTaken'] as Map<String, dynamic>)
            : null,
        screenshotBefore: base64Decode(m['screenshotBefore'] as String),
        screenshotAfter: m['screenshotAfter'] != null
            ? base64Decode(m['screenshotAfter'] as String)
            : null,
        errorMessage: m['errorMessage'] as String?,
        rawLlmResponse: m['rawLlmResponse'] as String?,
        duration: Duration(milliseconds: m['durationMs'] as int),
        executedAt: DateTime.parse(m['executedAt'] as String),
      );
}
