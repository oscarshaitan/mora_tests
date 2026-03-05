import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../models/http_hook.dart';
import '../models/test_case.dart';
import '../models/test_step.dart';

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

/// A command that could not be translated to a Mora Tests step.
class TranslationError {
  final String file;
  final int line; // 1-based
  final String command;

  const TranslationError({
    required this.file,
    required this.line,
    required this.command,
  });

  @override
  String toString() => line > 0
      ? '${p.basename(file)}:$line — unknown command "$command"'
      : '${p.basename(file)} — $command';
}

/// The outcome of translating one Maestro file.
class TranslationResult {
  final TestCase testCase;
  final List<TranslationError> errors;

  const TranslationResult({required this.testCase, required this.errors});

  bool get hasErrors => errors.isNotEmpty;
}

// ---------------------------------------------------------------------------
// Translator
// ---------------------------------------------------------------------------

/// Converts a Maestro YAML test file into a Mora Tests [TestCase].
///
/// Unknown Maestro commands are collected as [TranslationError]s and the
/// corresponding step is omitted (no silent placeholder). The caller decides
/// how to surface the errors to the user.
class MaestroTranslator {
  static const _uuid = Uuid();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Translates Maestro YAML [content] (from [sourcePath]) into a
  /// [TranslationResult] containing the [TestCase] and any [TranslationError]s.
  static TranslationResult translate(String content, String sourcePath) {
    final (:appId, :seederScript, :teardownScript, :commands) =
        _parse(content);
    final errors = <TranslationError>[];
    final name = _formatName(p.basenameWithoutExtension(sourcePath));
    final steps = _translateCommands(commands, sourcePath, errors);

    HttpHook? seeder;
    if (seederScript != null) {
      final hook = _hookFromScriptFile(seederScript, sourcePath) ??
          const HttpHook(url: '', method: 'POST', timeoutSeconds: 10);
      seeder = hook;
      if (hook.url.isEmpty) {
        errors.add(TranslationError(
          file: sourcePath,
          line: 0,
          command:
              'onFlowStart: could not extract HTTP call from "$seederScript" — set the seeder URL manually',
        ));
      }
    }

    HttpHook? teardown;
    if (teardownScript != null) {
      final hook = _hookFromScriptFile(teardownScript, sourcePath) ??
          const HttpHook(url: '', method: 'POST', timeoutSeconds: 10);
      teardown = hook;
      if (hook.url.isEmpty) {
        errors.add(TranslationError(
          file: sourcePath,
          line: 0,
          command:
              'onFlowComplete: could not extract HTTP call from "$teardownScript" — set the teardown URL manually',
        ));
      }
    }

    final testCase = TestCase(
      id: _uuid.v4(),
      name: name,
      description: appId != null
          ? 'Imported from Maestro (app: $appId)'
          : 'Imported from Maestro',
      startUrl: '', // User must supply
      seeder: seeder,
      teardown: teardown,
      steps: steps,
    );

    return TranslationResult(testCase: testCase, errors: errors);
  }

  // ── Parsing ────────────────────────────────────────────────────────────────

  /// Parses the Maestro file into its header fields and command list.
  ///
  /// Returns a named record with [appId], [seederScript], [teardownScript],
  /// and [commands] (each command is `(rawValue, 1-based lineNumber)`).
  static ({
    String? appId,
    String? seederScript,
    String? teardownScript,
    List<(dynamic, int)> commands,
  }) _parse(String content) {
    final trimmed = content.trimLeft();
    final withoutLeadingMarker =
        trimmed.startsWith('---') ? trimmed.substring(3).trimLeft() : trimmed;

    final separatorMatch =
        RegExp(r'\n---\s*\n').firstMatch(withoutLeadingMarker);

    if (separatorMatch != null) {
      final headerSrc =
          withoutLeadingMarker.substring(0, separatorMatch.start);
      final cmdSrc = withoutLeadingMarker.substring(separatorMatch.end);

      String? appId;
      String? seederScript;
      String? teardownScript;
      try {
        final header = loadYaml(headerSrc);
        if (header is YamlMap) {
          appId = header['appId']?.toString();
          seederScript = _extractRunScript(header['onFlowStart']);
          teardownScript = _extractRunScript(header['onFlowComplete']);
        }
      } catch (_) {}

      // Line offset: lines in header + the leading-marker lines + 1 for ---
      final headerLineCount = '\n'.allMatches(headerSrc).length + 1;
      final markerLineCount =
          trimmed.startsWith('---') ? 1 : 0; // the stripped leading ---
      final lineOffset = markerLineCount + headerLineCount + 1; // +1 for ---

      return (
        appId: appId,
        seederScript: seederScript,
        teardownScript: teardownScript,
        commands: _loadListWithLines(cmdSrc, lineOffset),
      );
    }

    final markerLineCount = trimmed.startsWith('---') ? 1 : 0;
    return (
      appId: null,
      seederScript: null,
      teardownScript: null,
      commands: _loadListWithLines(withoutLeadingMarker, markerLineCount),
    );
  }

  /// Returns the path from the first `runScript` entry in a flow hook list,
  /// or `null` if there is none.
  static String? _extractRunScript(dynamic hookList) {
    if (hookList is! YamlList) return null;
    for (final item in hookList) {
      final (name, value) = _parseCommand(item);
      if (name == 'runScript') return _str(value);
    }
    return null;
  }

  /// Resolves [scriptPath] relative to [sourcePath], reads the JS file, and
  /// extracts the first HTTP call it finds. Returns `null` if the file cannot
  /// be read or no recognisable HTTP call is found.
  static HttpHook? _hookFromScriptFile(String scriptPath, String sourcePath) {
    try {
      final absPath =
          p.normalize(p.join(p.dirname(sourcePath), scriptPath));
      final js = File(absPath).readAsStringSync();
      return _parseHttpFromJs(js);
    } catch (_) {
      return null;
    }
  }

  /// Extracts a URL + HTTP method from a JS snippet using simple regex.
  /// Supports `fetch`, `axios.method(url)`, and generic `url:`/`method:` patterns.
  static HttpHook? _parseHttpFromJs(String js) {
    String? url;
    String method = 'POST';

    // fetch('url') or fetch("url")
    final fetchMatch =
        RegExp(r'''fetch\s*\(\s*['"`]([^'"`]+)['"`]''').firstMatch(js);
    if (fetchMatch != null) {
      url = fetchMatch.group(1);
      final m = RegExp(r'''method\s*:\s*['"`](\w+)['"`]''',
              caseSensitive: false)
          .firstMatch(js);
      if (m != null) method = m.group(1)!.toUpperCase();
    }

    // axios.post/get/put/delete/patch('url')  or  http.post('url')
    if (url == null) {
      final methodCallMatch = RegExp(
              r'''(?:axios|http)\.(get|post|put|delete|patch)\s*\(\s*['"`]([^'"`]+)['"`]''',
              caseSensitive: false)
          .firstMatch(js);
      if (methodCallMatch != null) {
        method = methodCallMatch.group(1)!.toUpperCase();
        url = methodCallMatch.group(2);
      }
    }

    // Generic: url: 'value'  +  optional method: 'value'
    if (url == null) {
      final urlMatch =
          RegExp(r'''url\s*:\s*['"`]([^'"`]+)['"`]''').firstMatch(js);
      if (urlMatch != null) {
        url = urlMatch.group(1);
        final m = RegExp(r'''method\s*:\s*['"`](\w+)['"`]''',
                caseSensitive: false)
            .firstMatch(js);
        if (m != null) method = m.group(1)!.toUpperCase();
      }
    }

    if (url == null || url.isEmpty) return null;
    return HttpHook(url: url, method: method, timeoutSeconds: 10);
  }

  static List<(dynamic, int)> _loadListWithLines(String src, int lineOffset) {
    try {
      final doc = loadYaml(src);
      if (doc is! YamlList) return [];
      final result = <(dynamic, int)>[];
      for (int i = 0; i < doc.length; i++) {
        final line = doc.nodes[i].span.start.line + 1 + lineOffset;
        result.add((doc[i], line));
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  // ── Translation ────────────────────────────────────────────────────────────

  static List<TestStep> _translateCommands(
    List<(dynamic, int)> commands,
    String sourceFile,
    List<TranslationError> errors,
  ) {
    final steps = <TestStep>[];
    int i = 0;

    while (i < commands.length) {
      final (raw, line) = commands[i];
      if (raw == null) {
        i++;
        continue;
      }

      final (name, value) = _parseCommand(raw);

      // Silently skip known housekeeping commands.
      if (_isSkippable(name)) {
        i++;
        continue;
      }

      // Assert-only: absorb into the previous step (or create a stub).
      if (_isAssertCommand(name)) {
        final assertStr = _assertText(name, value);
        if (steps.isNotEmpty) {
          final last = steps.last;
          steps[steps.length - 1] = last.copyWith(
            assertion: last.assertion != null
                ? '${last.assertion}; $assertStr'
                : assertStr,
          );
        } else {
          steps.add(TestStep(
            id: _uuid.v4(),
            instruction: 'Verify the page state',
            assertion: assertStr,
            timeoutSeconds: 15,
          ));
        }
        i++;
        continue;
      }

      // repeat block → single descriptive step.
      if (name == 'repeat' && value is YamlMap) {
        final times = value['times']?.toString() ?? '?';
        final cmds = value['commands'];
        String actionsDesc = '';
        if (cmds is YamlList) {
          final descs = <String>[];
          for (final cmd in cmds) {
            final (n, v) = _parseCommand(cmd);
            final s = _commandToStep(n, v);
            if (s != null && s.instruction.isNotEmpty) {
              descs.add(s.instruction.toLowerCase());
            }
          }
          actionsDesc = descs.join(', then ');
        }
        steps.add(TestStep(
          id: _uuid.v4(),
          instruction: actionsDesc.isNotEmpty
              ? 'Repeat $times times: $actionsDesc'
              : 'Repeat $times times',
          timeoutSeconds: 60,
        ));
        i++;
        continue;
      }

      // runFlow with when + commands → conditional block:
      //   step 1: explore step that waits for the condition
      //   step 2+: the commands inside the block
      if (name == 'runFlow' && value is YamlMap &&
          value.containsKey('when') && value.containsKey('commands')) {
        final when = value['when'];
        final cmds = value['commands'];

        if (when is YamlMap) {
          final visible = when['visible']?.toString();
          final notVisible = when['notVisible']?.toString();

          if (visible != null) {
            final label = _cleanRegex(visible);
            steps.add(TestStep(
              id: _uuid.v4(),
              instruction: 'Wait until "$label" is visible',
              assertion: '"$label" should be visible',
              maxSubSteps: 5,
              timeoutSeconds: 30,
            ));
          } else if (notVisible != null) {
            final label = _cleanRegex(notVisible);
            steps.add(TestStep(
              id: _uuid.v4(),
              instruction: 'Wait until "$label" is not visible',
              assertion: '"$label" should not be visible',
              maxSubSteps: 5,
              timeoutSeconds: 30,
            ));
          }
        }

        if (cmds is YamlList) {
          for (final cmd in cmds) {
            final (n, v) = _parseCommand(cmd);
            if (_isSkippable(n)) continue;
            final s = _commandToStep(n, v);
            if (s != null) steps.add(s);
          }
        }

        i++;
        continue;
      }

      // tapOn + inputText → merged step.
      if (_isTapCommand(name) && i + 1 < commands.length) {
        final (nextRaw, _) = commands[i + 1];
        final (nextName, nextValue) = _parseCommand(nextRaw);
        if (nextName == 'inputText') {
          final tapLabel = _tapLabel(value);
          final text = _str(nextValue);
          int advance = 2;
          String? assertion;

          if (i + advance < commands.length) {
            final (ar, _) = commands[i + advance];
            final (an, av) = _parseCommand(ar);
            if (_isAssertCommand(an)) {
              assertion = _assertText(an, av);
              advance++;
            }
          }

          steps.add(TestStep(
            id: _uuid.v4(),
            instruction: 'Tap $tapLabel and type "$text"',
            assertion: assertion,
            timeoutSeconds: 30,
          ));
          i += advance;
          continue;
        }
      }

      // Regular single command.
      final step = _commandToStep(name, value);
      if (step != null) {
        // Absorb a following assert.
        if (i + 1 < commands.length) {
          final (nextRaw, _) = commands[i + 1];
          final (nextName, nextValue) = _parseCommand(nextRaw);
          if (_isAssertCommand(nextName)) {
            steps.add(step.copyWith(assertion: _assertText(nextName, nextValue)));
            i += 2;
            continue;
          }
        }
        steps.add(step);
      } else {
        // Unknown command — record an error, skip the step.
        errors.add(TranslationError(
          file: sourceFile,
          line: line,
          command: name,
        ));
      }

      i++;
    }

    return steps;
  }

  // ── Command helpers ────────────────────────────────────────────────────────

  static (String, dynamic) _parseCommand(dynamic raw) {
    if (raw is String) return (raw, null);
    if (raw is YamlMap && raw.isNotEmpty) {
      final key = raw.keys.first.toString();
      return (key, raw[key]);
    }
    return ('', null);
  }

  static bool _isSkippable(String name) => const {
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
        '',
      }.contains(name);

  static bool _isTapCommand(String name) => name == 'tapOn' || name == 'tap';

  static bool _isAssertCommand(String name) =>
      name == 'assertVisible' || name == 'assertNotVisible';

  // ── Value helpers ──────────────────────────────────────────────────────────

  static String _tapLabel(dynamic value) {
    if (value == null) return 'the element';
    if (value is String) return '"${_cleanRegex(value)}"';
    if (value is YamlMap) {
      if (value['text'] != null) {
        final idx = value['index'];
        final text = _cleanRegex(value['text'].toString());
        return idx != null
            ? 'the ${_ordinal(idx as int)} "$text"'
            : '"$text"';
      }
      if (value['id'] != null) return 'the element with id "${value['id']}"';
      if (value['label'] != null) {
        return '"${_cleanRegex(value['label'].toString())}"';
      }
      if (value['accessibilityLabel'] != null) {
        return '"${_cleanRegex(value['accessibilityLabel'].toString())}"';
      }
      if (value['point'] != null) return 'coordinate ${value['point']}';
      if (value['x'] != null && value['y'] != null) {
        return 'coordinate (${value['x']}, ${value['y']})';
      }
    }
    return '"$value"';
  }

  /// Strips leading/trailing Maestro regex anchors (`.*`) from [text].
  static String _cleanRegex(String text) {
    return text
        .replaceAll(RegExp(r'^\.\*'), '')
        .replaceAll(RegExp(r'\.\*$'), '')
        .trim();
  }

  static String _str(dynamic value) => value?.toString() ?? '';

  static String _assertText(String command, dynamic value) {
    final label = _tapLabel(value);
    return command == 'assertNotVisible'
        ? '$label should not be visible'
        : '$label should be visible';
  }

  static String _ordinal(int n) {
    if (n == 0) return 'first';
    if (n == 1) return 'second';
    if (n == 2) return 'third';
    return '${n + 1}th';
  }

  // ── Command → TestStep ────────────────────────────────────────────────────

  /// Returns a [TestStep] for known commands, or `null` for unknown ones.
  /// Callers are responsible for recording an error when `null` is returned.
  static TestStep? _commandToStep(String name, dynamic value) {
    switch (name) {
      case 'tapOn':
      case 'tap':
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Tap ${_tapLabel(value)}',
          timeoutSeconds: 20,
        );

      case 'longPressOn':
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Long press ${_tapLabel(value)}',
          timeoutSeconds: 20,
        );

      case 'doubleTapOn':
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Double tap ${_tapLabel(value)}',
          timeoutSeconds: 20,
        );

      case 'inputText':
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Type "${_str(value)}"',
          timeoutSeconds: 15,
        );

      case 'copyTextFrom':
        if (value is YamlMap) {
          final label = value['label']?.toString() ?? 'variable';
          final element = _tapLabel(value);
          return TestStep(
            id: _uuid.v4(),
            instruction: 'Copy the text from $element and store it as "\${$label}"',
            timeoutSeconds: 15,
          );
        }
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Copy text and store it as a variable',
          timeoutSeconds: 15,
        );

      case 'clearTextField':
      case 'eraseText':
        final label = value != null ? ' ${_tapLabel(value)}' : '';
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Clear the text field$label',
          timeoutSeconds: 15,
        );

      case 'scroll':
        final dir = value is YamlMap
            ? value['direction']?.toString().toLowerCase()
            : null;
        return TestStep(
          id: _uuid.v4(),
          instruction: dir != null ? 'Scroll $dir' : 'Scroll down',
          timeoutSeconds: 15,
        );

      case 'swipe':
        final dir = value is YamlMap
            ? value['direction']?.toString().toLowerCase()
            : null;
        return TestStep(
          id: _uuid.v4(),
          instruction: dir != null ? 'Swipe $dir' : 'Swipe',
          timeoutSeconds: 15,
        );

      case 'scrollUntilVisible':
        String label = 'the element';
        if (value is YamlMap) {
          final elem = value['element'];
          if (elem != null) label = _tapLabel(elem);
        }
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Scroll until $label is visible',
          timeoutSeconds: 30,
        );

      case 'back':
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Go back',
          timeoutSeconds: 15,
        );

      case 'pressKey':
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Press ${_str(value)}',
          timeoutSeconds: 10,
        );

      case 'openLink':
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Navigate to "${_str(value)}"',
          timeoutSeconds: 30,
        );

      case 'wait':
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Wait for the page to settle',
          timeoutSeconds: 30,
        );

      case 'extendedWaitUntil':
        if (value is YamlMap) {
          final visible = value['visible']?.toString();
          final notVisible = value['notVisible']?.toString();
          final timeoutMs = value['timeout'];
          final timeoutSec = timeoutMs != null
              ? ((timeoutMs as num) / 1000).ceil()
              : 60;
          if (visible != null) {
            return TestStep(
              id: _uuid.v4(),
              instruction: 'Wait until "$visible" is visible',
              assertion: '"$visible" should be visible',
              timeoutSeconds: timeoutSec,
            );
          }
          if (notVisible != null) {
            return TestStep(
              id: _uuid.v4(),
              instruction: 'Wait until "$notVisible" is not visible',
              assertion: '"$notVisible" should not be visible',
              timeoutSeconds: timeoutSec,
            );
          }
        }
        return TestStep(
          id: _uuid.v4(),
          instruction: 'Wait for condition',
          timeoutSeconds: 60,
        );

      case 'runFlow':
        String callPath;
        Map<String, String> withVars = {};
        if (value is String) {
          callPath = value;
        } else if (value is YamlMap) {
          callPath = (value['path'] ?? value['file'])?.toString() ?? '';
          final env = value['env'];
          if (env is YamlMap) {
            withVars = {
              for (final e in env.entries)
                e.key.toString(): e.value.toString(),
            };
          }
        } else {
          callPath = _str(value);
        }
        return TestStep(
          id: _uuid.v4(),
          instruction: '',
          call: callPath,
          withVars: withVars,
          timeoutSeconds: 60,
        );

      default:
        return null; // Unknown — caller records a TranslationError.
    }
  }

  // ── Utilities ──────────────────────────────────────────────────────────────

  static String _formatName(String baseName) {
    return baseName
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
