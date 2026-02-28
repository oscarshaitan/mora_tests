import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/exceptions.dart';
import '../models/llm_action.dart';

const _systemPrompt = '''
You are a UI automation agent. You receive a screenshot of an application \
running inside a browser and a natural language instruction describing what \
to do next. The application may be a Flutter web app, a React SPA, or any \
other web app — its UI elements are rendered visually on screen.

Your job is to analyze the screenshot and return a SINGLE JSON action.

CRITICAL RULES:
1. Always respond with ONLY a valid JSON object. No markdown fences, no \
explanation outside the JSON.
2. For click, doubleClick, and longPress actions you MUST use pixel \
coordinates (x, y). Set css_selector and xpath_selector to null. Identify \
the element visually from the screenshot and return the center pixel \
coordinates of that element. The screenshot dimensions match the browser \
viewport exactly.
3. For type actions use css_selector only if the page has standard HTML \
inputs. If the app is a Flutter or canvas-based app, first click the field \
(using coordinates) then type the value using action "type" with the value \
field set and css_selector null — the value will be injected via clipboard.
4. For scroll actions use scroll_delta_y (positive = down, negative = up). \
css_selector is optional.
5. If the instruction is already complete (page already shows the expected \
result), return action "done".
6. If you cannot determine what to do, return action "fail" with reasoning.
7. confidence must be a float between 0.0 and 1.0.
8. Use "longPress" only when the instruction explicitly says "long press", \
"press and hold", or "long tap". Optionally set wait_ms to control the hold \
duration (default 800 ms). For a regular tap always use "click".

AVAILABLE ACTIONS:
click, doubleClick, longPress, type, scroll, navigate, wait, hover, pressKey,
selectOption, assert_text, assert_url, assert_visible, done, fail

JSON SCHEMA (respond with EXACTLY this shape):
{
  "action": "<action_name>",
  "css_selector": null,
  "xpath_selector": null,
  "x": <center x pixel of target element, or null>,
  "y": <center y pixel of target element, or null>,
  "value": "<text to type or null>",
  "url": "<URL or null>",
  "key": "<key name e.g. Enter, Tab, Escape or null>",
  "scroll_delta_x": <number or null>,
  "scroll_delta_y": <number or null>,
  "wait_ms": <number or null>,
  "expected_text": "<text to assert or null>",
  "expected_url": "<URL pattern to assert or null>",
  "confidence": 0.95,
  "reasoning": "Brief explanation of what you see and what you are doing"
}
''';

class LlmService {
  final String baseUrl;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;

  LlmService({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.temperature = 0.1,
    this.maxTokens = 512,
  });

  Future<LlmAction> interpretStep({
    required String instruction,
    required Uint8List screenshot,
    String? hint,
    String? assertion,
    String? previousActionName,
    String? previousError,
  }) async {
    final screenshotB64 = base64Encode(screenshot);

    final textParts = <String>[
      'INSTRUCTION: $instruction',
      if (hint != null && hint.isNotEmpty) 'HINT: $hint',
      if (assertion != null && assertion.isNotEmpty)
        'ASSERTION (must be true after the action): $assertion',
      if (previousActionName != null)
        'PREVIOUS ATTEMPT: tried action "$previousActionName"',
      if (previousError != null) 'PREVIOUS ERROR: $previousError',
    ];

    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      {
        'role': 'user',
        'content': [
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/png;base64,$screenshotB64',
              'detail': 'high',
            },
          },
          {'type': 'text', 'text': textParts.join('\n')},
        ],
      },
    ];

    final body = {
      'model': model,
      'messages': messages,
      'max_tokens': maxTokens,
      'temperature': temperature,
    };

    final response = await http
        .post(
          Uri.parse('$baseUrl/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode != 200) {
      throw LlmException(
        'API returned ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        data['choices'][0]['message']['content'] as String? ?? '{}';

    // Strip markdown fences if model includes them despite instructions
    final cleaned = content
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    try {
      final actionJson = jsonDecode(cleaned) as Map<String, dynamic>;
      return _parseAction(actionJson, content);
    } catch (e) {
      throw LlmException('Failed to parse LLM response: $cleaned');
    }
  }

  LlmAction _parseAction(Map<String, dynamic> json, String rawResponse) {
    ActionType type;
    try {
      final actionStr = (json['action'] as String? ?? 'fail')
          .replaceAll('-', '_');
      type = ActionType.values.firstWhere(
        (e) => e.name == actionStr,
        orElse: () => ActionType.fail,
      );
    } catch (_) {
      type = ActionType.fail;
    }

    return LlmAction(
      type: type,
      cssSelector: json['css_selector'] as String?,
      xpathSelector: json['xpath_selector'] as String?,
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
      value: json['value'] as String?,
      url: json['url'] as String?,
      key: json['key'] as String?,
      scrollDeltaX: (json['scroll_delta_x'] as num?)?.toInt(),
      scrollDeltaY: (json['scroll_delta_y'] as num?)?.toInt(),
      waitMs: (json['wait_ms'] as num?)?.toInt(),
      expectedText: json['expected_text'] as String?,
      expectedUrl: json['expected_url'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      reasoning: json['reasoning'] as String? ?? '',
    );
  }
}
