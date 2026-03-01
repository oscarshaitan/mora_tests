import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../models/step_result.dart';
import '../models/test_run.dart';

/// Generates a self-contained single-file HTML report from a list of [TestRun]s.
///
/// All screenshots are:
///   1. Downscaled to at most [_maxImgWidth] pixels wide (preserving aspect ratio).
///   2. Re-encoded as JPEG at [_jpegQuality]% quality.
///   3. Embedded as base64 data-URIs — no external resources needed.
///
/// A typical 10-step run with 1280 × 800 before/after screenshots produces an
/// HTML file of roughly 2–4 MB instead of 15–25 MB for raw PNG embeds.
class ReportService {
  ReportService._();

  static const _htmlEscape = HtmlEscape();

  /// Maximum width (px) for embedded screenshots after downscaling.
  static const _maxImgWidth = 1100;

  /// JPEG quality (1–100) used when re-encoding screenshots.
  static const _jpegQuality = 75;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns a complete, self-contained HTML document as a [String].
  static String generateHtml(List<TestRun> runs) {
    final now = DateTime.now();
    final passedRuns = runs.where((r) => r.passed).length;
    final failedRuns = runs.length - passedRuns;

    final sb = StringBuffer()
      ..writeln('<!DOCTYPE html>')
      ..writeln('<html lang="en">')
      ..writeln('<head>')
      ..writeln('<meta charset="utf-8">')
      ..writeln(
          '<meta name="viewport" content="width=device-width,initial-scale=1">')
      ..writeln(
          '<title>MoraTests Report \u2014 ${_esc(_fmtDate(now))}</title>')
      ..writeln('<style>$_css</style>')
      ..writeln('</head>')
      ..writeln('<body>');

    _writeHeader(sb, runs.length, passedRuns, failedRuns, now);
    sb.writeln('<main>');
    for (final run in runs) {
      _writeRun(sb, run);
    }
    sb.writeln('</main>');
    sb.writeln('</body>');
    sb.writeln('</html>');
    return sb.toString();
  }

  // ── HTML builders ─────────────────────────────────────────────────────────

  static void _writeHeader(
    StringBuffer sb,
    int total,
    int passed,
    int failed,
    DateTime now,
  ) {
    sb
      ..writeln('<header>')
      ..writeln('<div class="header-inner">')
      ..writeln('<h1>MoraTests Report</h1>')
      ..writeln(
          '<p class="meta">Generated ${_esc(_fmtDateTime(now))}</p>')
      ..writeln('<div class="pills">')
      ..writeln(
          '<span class="pill pass">&#10003; $passed passed</span>')
      ..writeln(
          '<span class="pill fail">&#10007; $failed failed</span>')
      ..writeln(
          '<span class="pill neutral">$total run${total == 1 ? "" : "s"}</span>')
      ..writeln('</div>')
      ..writeln('</div>')
      ..writeln('</header>');
  }

  static void _writeRun(StringBuffer sb, TestRun run) {
    final cls = run.passed ? 'pass' : 'fail';
    final icon = run.passed ? '&#10003;' : '&#10007;';
    sb
      ..writeln('<section class="run $cls">')
      ..writeln('<details open>')
      ..writeln('<summary>')
      ..writeln('<span class="run-icon">$icon</span>')
      ..writeln('<span class="run-name">${_esc(run.testCaseName)}</span>')
      ..writeln('<span class="run-meta">'
          '${run.passedCount}/${run.results.length} steps'
          ' &middot; ${_fmtDuration(run.totalDuration)}</span>')
      ..writeln(
          '<span class="run-date">${_esc(_fmtDateTime(run.startedAt))}</span>')
      ..writeln('</summary>')
      ..writeln('<div class="steps">');

    for (var i = 0; i < run.results.length; i++) {
      _writeStep(sb, i, run.results[i]);
    }

    sb
      ..writeln('</div>')
      ..writeln('</details>')
      ..writeln('</section>');
  }

  static void _writeStep(StringBuffer sb, int index, StepResult result) {
    final cls = result.success ? 'pass' : 'fail';
    final icon = result.success ? '&#10003;' : '&#10007;';
    final action = result.actionTaken;

    sb
      ..writeln('<div class="step $cls">')
      ..writeln('<div class="step-header">')
      ..writeln('<span class="step-icon $cls">$icon</span>')
      ..writeln('<span class="step-num">Step ${index + 1}</span>');

    if (action != null) {
      sb.writeln(
          '<span class="badge action">${_esc(action.type.name)}</span>');
      final pct = (action.confidence * 100).round();
      sb.writeln('<span class="conf">$pct%</span>');
    }

    sb
      ..writeln(
          '<span class="dur">${_fmtMs(result.duration.inMilliseconds)}</span>')
      ..writeln('</div>');

    if (result.errorMessage != null) {
      sb.writeln('<p class="error">${_esc(result.errorMessage!)}</p>');
    }

    if (action != null && action.reasoning.isNotEmpty) {
      sb.writeln('<p class="reasoning">'
          '<strong>Reasoning:</strong> ${_esc(action.reasoning)}</p>');
    }

    // Screenshots
    final hasBefore = result.screenshotBefore.isNotEmpty;
    final hasAfter = result.screenshotAfter != null;
    if (hasBefore || hasAfter) {
      sb.writeln('<div class="screenshots">');
      if (hasBefore) _writeImg(sb, result.screenshotBefore, 'Before');
      if (hasAfter) _writeImg(sb, result.screenshotAfter!, 'After');
      sb.writeln('</div>');
    }

    sb.writeln('</div>');
  }

  static void _writeImg(
      StringBuffer sb, Uint8List pngBytes, String caption) {
    final (bytes, mime) = _compressImage(pngBytes);
    sb
      ..writeln('<figure>')
      ..writeln('<figcaption>$caption</figcaption>')
      ..writeln('<img src="data:$mime;base64,${base64Encode(bytes)}"'
          ' alt="$caption">')
      ..writeln('</figure>');
  }

  // ── Image compression ─────────────────────────────────────────────────────

  /// Decodes [pngBytes], downscales to [_maxImgWidth] if wider, then
  /// re-encodes as JPEG at [_jpegQuality].
  ///
  /// Falls back to the original PNG bytes on any decode error.
  static (Uint8List bytes, String mime) _compressImage(Uint8List pngBytes) {
    try {
      var image = img.decodeImage(pngBytes);
      if (image == null) return (pngBytes, 'image/png');

      if (image.width > _maxImgWidth) {
        image = img.copyResize(
          image,
          width: _maxImgWidth,
          interpolation: img.Interpolation.linear,
        );
      }

      final jpeg = Uint8List.fromList(
        img.encodeJpg(image, quality: _jpegQuality),
      );
      return (jpeg, 'image/jpeg');
    } catch (_) {
      // Fallback: embed raw PNG rather than crashing the export
      return (pngBytes, 'image/png');
    }
  }

  // ── Formatting helpers ─────────────────────────────────────────────────────

  static String _esc(String s) => _htmlEscape.convert(s);

  static String _fmtDate(DateTime dt) =>
      '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';

  static String _fmtDateTime(DateTime dt) =>
      '${_fmtDate(dt)} ${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';

  static String _fmtDuration(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  }

  static String _fmtMs(int ms) {
    if (ms < 1000) return '${ms}ms';
    return '${(ms / 1000).toStringAsFixed(1)}s';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  // ── Embedded CSS ──────────────────────────────────────────────────────────

  static const String _css = r'''
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  background: #f4f6fb; color: #1a1a2e; line-height: 1.5;
}

/* ── Header ── */
header { background: #1e1e2e; color: white; padding: 24px 32px; }
.header-inner { max-width: 1100px; margin: 0 auto; }
header h1 { font-size: 1.5rem; font-weight: 700; letter-spacing: -0.4px; }
.meta { color: #9090b0; font-size: 0.78rem; margin-top: 4px; }
.pills { display: flex; gap: 8px; margin-top: 14px; flex-wrap: wrap; }
.pill { padding: 4px 14px; border-radius: 20px; font-size: 0.78rem; font-weight: 600; }
.pill.pass    { background: rgba(34,197,94,0.15);  color: #16a34a; border: 1px solid rgba(34,197,94,0.3); }
.pill.fail    { background: rgba(239,68,68,0.15);  color: #dc2626; border: 1px solid rgba(239,68,68,0.3); }
.pill.neutral { background: rgba(99,102,241,0.15); color: #4f46e5; border: 1px solid rgba(99,102,241,0.3); }

/* ── Layout ── */
main {
  max-width: 1100px; margin: 24px auto;
  padding: 0 24px 48px; display: flex; flex-direction: column; gap: 14px;
}

/* ── Run section ── */
.run {
  background: white; border-radius: 10px; overflow: hidden;
  box-shadow: 0 1px 3px rgba(0,0,0,0.07), 0 1px 8px rgba(0,0,0,0.04);
}
.run.pass { border-left: 4px solid #22c55e; }
.run.fail { border-left: 4px solid #ef4444; }

details > summary {
  display: flex; align-items: center; gap: 10px;
  padding: 13px 18px; cursor: pointer; user-select: none;
  list-style: none; font-size: 0.9rem;
}
details > summary::-webkit-details-marker { display: none; }
details > summary::marker { display: none; }
details > summary:hover { background: #f8f9ff; }

.run-icon { font-size: 1rem; font-weight: 700; width: 22px; text-align: center; }
.run.pass .run-icon { color: #16a34a; }
.run.fail .run-icon { color: #dc2626; }
.run-name {
  font-weight: 600; flex: 1; min-width: 0;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.run-meta { color: #666;  font-size: 0.78rem; white-space: nowrap; }
.run-date { color: #999;  font-size: 0.73rem; white-space: nowrap; }

/* ── Steps container ── */
.steps {
  border-top: 1px solid #eef0f8;
  padding: 12px 16px; display: flex; flex-direction: column; gap: 8px;
}

/* ── Step card ── */
.step { border: 1px solid #e8eaf2; border-radius: 8px; padding: 10px 12px; }
.step.pass { border-color: rgba(34,197,94,0.3); }
.step.fail { border-color: rgba(239,68,68,0.3); background: #fff8f8; }

.step-header { display: flex; align-items: center; gap: 8px; }
.step-icon {
  width: 18px; height: 18px; border-radius: 50%; flex-shrink: 0;
  display: inline-flex; align-items: center; justify-content: center;
  font-size: 0.65rem; font-weight: 800; color: white;
}
.step-icon.pass { background: #22c55e; }
.step-icon.fail { background: #ef4444; }
.step-num { font-weight: 600; font-size: 0.82rem; }
.badge { padding: 2px 7px; border-radius: 4px; font-size: 0.7rem; font-weight: 600; }
.badge.action { background: #e0e7ff; color: #4338ca; }
.conf { font-size: 0.72rem; color: #888; }
.dur  { font-size: 0.72rem; color: #999; margin-left: auto; }

.reasoning { font-size: 0.8rem; color: #444; margin-top: 8px; }
.error {
  font-size: 0.8rem; color: #b91c1c;
  background: #fff0f0; border: 1px solid #fecaca;
  padding: 6px 10px; border-radius: 5px; margin-top: 8px;
}

/* ── Screenshots ── */
.screenshots { display: flex; gap: 10px; margin-top: 10px; }
figure { flex: 1; min-width: 0; }
figcaption {
  font-size: 0.72rem; color: #888; text-align: center; margin-bottom: 4px;
  font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px;
}
figure img {
  width: 100%; border-radius: 6px; border: 1px solid #e8eaf2;
  display: block; max-height: 420px; object-fit: contain; background: #f4f6fb;
}

/* ── Print ── */
@media print {
  body { background: white; font-size: 0.85rem; }
  header { print-color-adjust: exact; -webkit-print-color-adjust: exact; }
  main { padding: 0; margin: 12px auto; }
  .run  { box-shadow: none; break-inside: avoid-page; }
  .step { break-inside: avoid; }
  .screenshots { page-break-inside: avoid; }
  figure img { max-height: 280px; }
}''';
}
