import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/llm_action.dart';

const _systemPrompt = '''
You are a UI automation agent. You receive a screenshot of an application \
running inside a browser and a natural language instruction describing what \
to do next. The application may be a Flutter web app, a React SPA, or any \
other web app — its UI elements are rendered visually on screen.

Your job is to analyze the screenshot and return a SINGLE JSON action.

CRITICAL RULES:
1. Your ENTIRE response must be a single raw JSON object. Start with { and \
end with }. No markdown fences (no ```), no prose before or after the JSON, \
no explanation outside the object.
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
  "confidence": <float 0.0–1.0 reflecting how certain you are>,
  "reasoning": "Brief explanation of what you see and what you are doing"
}
''';

class LlmService {
  final String baseUrl;
  final String apiKey;
  final String model;
  final String? fallbackModel;
  final double temperature;
  final int maxTokens;

  LlmService({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.fallbackModel,
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
    /// For explore/multi-turn steps: a log of sub-steps already executed,
    /// newest last. E.g. ["sub-step 1: click (245,312) — Clicked Companies menu",
    /// "sub-step 2: click (180,445) — Clicked Symterra row"].
    /// When present the LLM understands it is mid-way through a goal and must
    /// continue from the current screenshot state.
    List<String>? subHistory,
  }) async {
    final screenshotB64 = base64Encode(screenshot);

    final textParts = <String>[
      'INSTRUCTION: $instruction',
      if (hint != null && hint.isNotEmpty) 'HINT: $hint',
      if (assertion != null && assertion.isNotEmpty)
        'ASSERTION (must be true after the action): $assertion',
      // Explore-mode history: show what has already been done so the LLM
      // knows where to continue from.
      if (subHistory != null && subHistory.isNotEmpty) ...[
        'EXPLORE MODE — sub-steps already SUCCESSFULLY executed (most recent last):',
        ...subHistory.map((h) => '  • $h'),
        'IMPORTANT: Every sub-step listed above was fully executed and succeeded. '
            'Trust the history even when the screenshot looks unchanged '
            '(e.g. password fields show only dots after typing, canvas apps '
            'may not visually update immediately). '
            'Do NOT repeat any action already listed above. '
            'If the overall goal is now achieved, return action "done".',
      ],
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
      // Force the vLLM / OVH backend to emit valid JSON via guided decoding.
      // This is the primary defence against garbled or fence-wrapped output.
      'response_format': {'type': 'json_object'},
    };

    final response = await _tryWithFallback(body);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        data['choices'][0]['message']['content'] as String? ?? '{}';

    final cleaned = _extractJson(content);

    try {
      final actionJson = jsonDecode(cleaned) as Map<String, dynamic>;
      return _parseAction(actionJson, content);
    } catch (e) {
      // Include a snippet of the raw output so the RETRY log is diagnostic.
      final snippet = content.length > 200
          ? '${content.substring(0, 200)}…'
          : content;
      throw LlmException('Failed to parse LLM response: $snippet');
    }
  }

  /// Tries the primary model first. If it throws [LlmException] and a
  /// [fallbackModel] is configured (and different from [model]), retries
  /// the exact same request with the fallback model substituted.
  Future<http.Response> _tryWithFallback(Map<String, dynamic> body) async {
    try {
      return await _doRequest(body);
    } on LlmException {
      final fb = fallbackModel;
      if (fb == null || fb.isEmpty || fb == model) rethrow;
      dev.log(
        'Primary model "$model" failed — retrying with fallback "$fb"',
        name: 'LlmService',
      );
      final fallbackBody = Map<String, dynamic>.from(body);
      fallbackBody['model'] = fb;
      return await _doRequest(fallbackBody);
    }
  }

  /// Makes the HTTP request to the LLM API.
  ///
  /// Handles HTTP 429 (rate limit) transparently: waits for the duration
  /// specified in the `Retry-After` response header (or
  /// [AppConstants.rateLimitDelaySeconds] if the header is absent) then
  /// retries the request once. Any other non-200 status throws [LlmException].
  Future<http.Response> _doRequest(Map<String, dynamic> body) async {
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final uri = Uri.parse('$baseUrl/chat/completions');
    final encoded = jsonEncode(body);

    http.Response response;
    try {
      response = await http
          .post(uri, headers: headers, body: encoded)
          .timeout(const Duration(seconds: 90));
    } on TimeoutException {
      throw LlmException('Request timed out after 90 s (model: ${body['model']})');
    }

    if (response.statusCode == 429) {
      final retryAfter = int.tryParse(
            response.headers['retry-after'] ?? '',
          ) ??
          AppConstants.rateLimitDelaySeconds;
      dev.log(
        'Rate limited (429) — waiting ${retryAfter}s before retry',
        name: 'LlmService',
      );
      await Future.delayed(Duration(seconds: retryAfter));
      try {
        response = await http
            .post(uri, headers: headers, body: encoded)
            .timeout(const Duration(seconds: 90));
      } on TimeoutException {
        throw LlmException('Request timed out after 90 s on 429-retry (model: ${body['model']})');
      }
    }

    if (response.statusCode != 200) {
      throw LlmException(
        'API returned ${response.statusCode}: ${response.body}',
      );
    }
    return response;
  }

  /// Extracts a clean JSON object string from raw LLM output.
  ///
  /// Handles the most common model misbehaviours in order:
  ///  1. Markdown code fences  (``` or ```json)
  ///  2. Prose before / after the JSON braces
  ///  3. Trailing commas before `}` or `]`  (invalid JSON but common output)
  String _extractJson(String raw) {
    // 1. Strip markdown fences.
    var s = raw
        .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    // 2. Isolate the outermost JSON object.
    //    Find the first '{' and the last '}' — any prose the model placed
    //    before or after is discarded.
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start >= 0 && end > start) {
      s = s.substring(start, end + 1);
    }

    // 3. Remove trailing commas before } or ] (models do this occasionally).
    s = s.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');

    return s;
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
