# Deferred Improvements

Items identified during the batch review of March 2026 but deferred to keep the
change set focused. Pick these up in a future session.

---

## UI / Results view

### Screenshot zoom / lightbox
**Context:** `lib/screens/runner/results_view.dart`
Clicking a `screenshotBefore` or `screenshotAfter` thumbnail opens it in a
full-screen overlay (lightbox). Allows inspectors to see exactly what the LLM
saw at the moment of each decision without squinting at the thumbnail.
**Suggested approach:** `showDialog` + `InteractiveViewer` wrapping the full
`Image.memory` widget.

### `_selectedRunIndex` persists across cubit reloads
**Context:** `lib/screens/runner/results_view.dart`
`_selectedRunIndex` is local widget state, so switching away from the Results
tab and back resets the selection to run 0. Store the selected index in the
cubit (or `RunnerFinished` state) so the user returns to the same run.

### Pass / fail colour accessibility
**Context:** `lib/screens/runner/results_view.dart`
Success/failure is currently conveyed by colour alone (green / red). Add a
distinct icon as well (e.g., `Icons.check_circle` / `Icons.cancel`) so the
result is perceivable by colour-blind users and in monochrome prints.

---

## Diagnostics / Logging

### DPR value logged on WebView attach
**Context:** `lib/services/webview_service.dart`, `attach()` method
Log the resolved `_dpr` value as part of the WebView-ready banner so it is easy
to confirm the correct device-pixel-ratio is in use during debugging, especially
on HiDPI displays where DPR ≠ 1.

---

## LLM / Confidence

### Confidence default 0.5 instead of 1.0
**Context:** `lib/services/llm_service.dart`, `_parseAction()`
When the LLM omits the `confidence` field the fallback is currently `1.0`
(maximum certainty). A neutral default of `0.5` is more honest and avoids
misleading "100% confident" entries in the results view for responses that
didn't include the field.

```dart
confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
```

---

## Notes

All items above are non-breaking quality-of-life improvements that do not
require model changes, `build_runner` regeneration, or new dependencies.
