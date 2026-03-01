# Improvements Log

Tracked during the batch review of March 2026.

---

## ✅ Completed (March 2026 session)

| # | Item | File(s) |
|---|------|---------|
| 1 | **Screenshot zoom / lightbox** — click any thumbnail to open a full-screen `InteractiveViewer` overlay (zoom 0.3×–5×, close button, black backdrop) | `lib/widgets/screenshot_panel.dart` |
| 2 | **`selectedRunIndex` persists across tab switches** — moved from local widget state to `RunnerFinished.selectedRunIndex` (Freezed `@Default(0)`); driven by new `cubit.selectRun(int)` method | `lib/cubits/runner/runner_state.dart`, `runner_cubit.dart`, `results_view.dart` |
| 3 | **Pass / fail colour accessibility** — success/failure shown via icon + colour everywhere (results list, step cards, summary bar) | `lib/screens/runner/results_view.dart` |
| 4 | **DPR value logged on WebView attach** — `dev.log('DPR = $_dpr', name: 'MoraTests')` emitted in `_readDpr()` | `lib/services/webview_service.dart` |
| 5 | **Confidence default 0.5 instead of 1.0** — neutral fallback when LLM omits the `confidence` field | `lib/services/llm_service.dart` |

---

## 🔲 Deferred

### Lightbox keyboard navigation
**Context:** `lib/widgets/screenshot_panel.dart`
Add `RawKeyboardListener` (or `Focus` + `onKeyEvent`) inside the lightbox dialog
to close on Escape and step between screenshots (← / →) when a test has multiple
steps open. Currently only pointer/tap dismiss is supported.

### `selectedRunIndex` survives `loadHistory()`
**Context:** `lib/cubits/runner/runner_cubit.dart`
When the user presses History, the new `RunnerFinished` state is created with
`selectedRunIndex: 0`, discarding any previously highlighted run. Consider
passing the current index through if the previous state was also `RunnerFinished`.

### Per-run notes / tagging
Allow the user to annotate a saved run with a short text note (stored in the
JSON alongside the run data). Useful for marking regressions or tracking root
causes in the history list.

---

## Notes

- Items in **✅ Completed** were all implemented without `build_runner` regeneration
  *except* `selectedRunIndex`, which required one `build_runner build` run after the
  new Freezed field was added.
- The `image: ^4.3.0` package was added for screenshot compression in the HTML
  report export (`lib/services/report_service.dart`).
