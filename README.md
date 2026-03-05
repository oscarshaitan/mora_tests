<p align="center">
  <img src="Mora Tests-modified.png" width="120" alt="Mora Tests logo"/>
</p>

# Mora Tests

An AI-powered UI test runner built with Flutter Desktop (Windows + macOS).

Tests are described in natural language YAML files. For each step the app takes a screenshot of an embedded WebView, sends it to a vision-capable LLM (**OVH AI Endpoints** or **Vertex AI**), and executes the LLM's returned action via **CDP (Chrome DevTools Protocol)** events and JavaScript injection.

---

## Prerequisites

### Flutter

- Flutter SDK ≥ 3.2.0
- Dart SDK ≥ 3.2.0

### Windows — NuGet CLI (required)

`flutter_inappwebview` on Windows uses Microsoft WebView2, which is fetched as a NuGet package (`Microsoft.Web.WebView2`) during the build. You must have `nuget.exe` on your PATH before running `flutter run` or `flutter build`.

#### Step 1 — Download nuget.exe

Download the latest `nuget.exe` from the official Microsoft distribution:

```
https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
```

Place it in a permanent folder, for example:

```
C:\nuget\nuget.exe
```

#### Step 2 — Add to PATH

1. Press **Win + R**, type `sysdm.cpl`, press Enter
2. Go to **Advanced** → **Environment Variables**
3. Under **System variables**, select **Path** → **Edit** → **New**
4. Add: `C:\nuget`
5. Click OK on all dialogs
6. **Restart your terminal** (PowerShell / CMD)

#### Step 3 — Verify

```powershell
nuget help
```

You should see NuGet CLI help output. If you see `'nuget' is not recognized`, the PATH was not applied — close and reopen the terminal.

#### Step 4 — Configure nuget.org package source

A fresh `nuget.exe` download has no package sources configured. Add the official nuget.org feed:

```powershell
nuget sources add -name "nuget.org" -source "https://api.nuget.org/v3/index.json"
```

Verify it was added:

```powershell
nuget sources list
```

You should see `nuget.org` listed as `[Enabled]`.

This configuration is stored permanently at `%APPDATA%\NuGet\NuGet.Config` and only needs to be done once per machine.

#### Step 5 — Pre-download WebView2 NuGet packages (optional but recommended)

To avoid network issues during the Flutter build, you can pre-download the required NuGet packages into the build directory:

```powershell
# Run from the project root (mora_tests\)
$pkgdir = "build\windows\x64\packages"
New-Item -ItemType Directory -Force -Path $pkgdir | Out-Null

nuget install Microsoft.Web.WebView2 -Version 1.0.2903.40 -OutputDirectory $pkgdir -Source "https://api.nuget.org/v3/index.json"
nuget install Microsoft.Windows.ImplementationLibrary -Version 1.0.240803.1 -OutputDirectory $pkgdir -Source "https://api.nuget.org/v3/index.json"
nuget install Microsoft.Windows.CppWinRT -Version 2.0.240405.15 -OutputDirectory $pkgdir -Source "https://api.nuget.org/v3/index.json"
nuget install Microsoft.Web.WebView2.DevToolsProtocolExtension -Version 1.0.1774 -OutputDirectory $pkgdir -Source "https://api.nuget.org/v3/index.json"
```

#### Full NuGet setup reference

- Official guide: https://learn.microsoft.com/en-us/nuget/install-nuget-client-tools
- flutter_inappwebview Windows setup: https://inappwebview.dev/docs/intro#setup-windows

---

### macOS — No extra tooling needed

`flutter_inappwebview` uses native `WKWebView` on macOS. No NuGet or extra setup is required beyond Xcode 15+.

---

## Getting Started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Generate freezed / json_serializable files

All models use `freezed`. You must run the code generator before building:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Re-run this any time you modify a `@freezed` model.

### 3. Run on Windows

```bash
flutter run -d windows
```

### 4. Run on macOS

```bash
flutter run -d macos
```

---

## Configuration

On first launch, go to the **Settings** tab to configure your LLM provider.

> For step-by-step instructions on obtaining credentials for each provider, see **[docs/providers.md](docs/providers.md)**.

### Providers

Two providers are supported. Each has its own URL, API key, primary model, and fallback model. Use the radio button on each card to select the active provider. Settings auto-save on every change.

#### OVH AI Endpoints (default)

| Field | Default value |
|-------|---------------|
| Base URL | `https://oai.endpoints.kepler.ai.cloud.ovh.net/v1` |
| API Key | Your OVH AI Endpoints access token |
| Primary model | `Qwen2.5-VL-72B-Instruct` |
| Fallback model | `Mistral-Small-3.2-24B-Instruct-2506` (optional) |

#### Vertex AI

| Field | Default value |
|-------|---------------|
| Base URL | `https://us-central1-aiplatform.googleapis.com/v1beta1/projects/YOUR_PROJECT_ID/locations/us-central1/endpoints/openapi` |
| API Key | A valid Google OAuth 2.0 access token (`gcloud auth print-access-token`) |
| Primary model | `google/gemini-2.5-flash` |
| Fallback model | `google/gemini-3.1-flash-lite` (optional) |

Replace `YOUR_PROJECT_ID` in the Vertex AI URL with your Google Cloud project ID.

> **Fallback model:** if the primary model returns an error (e.g. rate-limit or quota), the runner automatically retries the same step with the fallback model before marking the step as failed.

Settings are persisted in `shared_preferences` and survive app restarts.

---

## YAML Test Format

```yaml
id: "uuid"
name: "Login Flow Test"
description: "Verifies login and dashboard access"
start_url: "https://myapp.com/login"

# Optional: called before the test runs
seeder:
  url: "https://api.myapp.com/test/seed-user"
  method: "POST"
  headers:
    Authorization: "Bearer test-token"
  body: '{"username": "testuser", "role": "admin"}'

# Optional: called after the test completes (always, even on failure)
teardown:
  url: "https://api.myapp.com/test/cleanup"
  method: "DELETE"
  headers:
    Authorization: "Bearer test-token"

# Variables can be referenced in instructions as {{varName}}
variables:
  username: "testuser@example.com"
  password: "testpass123"

steps:
  # Standard step — one LLM call, one action
  - id: "step-001"
    instruction: "Type {{username}} into the email input field"
    hint: "The field has placeholder 'Email address' and is the first input on the page"
    timeout: 15

  - id: "step-002"
    instruction: "Type {{password}} into the password field"
    timeout: 15

  - id: "step-003"
    instruction: "Click the login button to submit the form"
    hint: "Look for a blue button at the bottom of the form that says 'Sign In' or 'Login'"
    timeout: 20

  # Explore step — LLM loops up to max_sub_steps times until it returns "done"
  - id: "step-004"
    instruction: "Navigate to the Companies section and open the Symterra account"
    max_sub_steps: 8
    timeout: 60

  # Standard step with assertion
  - id: "step-005"
    instruction: "Verify the dashboard loaded successfully"
    assert: "URL should contain /dashboard and a welcome banner should be visible"
    timeout: 30

  # Call step — run another YAML file inline as a sub-test
  - id: "step-006"
    call: "shared/login.yaml"
    with:
      username: "admin@example.com"
      password: "adminpass"
```

### Top-level fields

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier (UUID recommended) |
| `name` | Yes | Display name for the test |
| `start_url` | Yes | URL the WebView navigates to before step 1 |
| `seeder` | No | HTTP call made before the test runs |
| `teardown` | No | HTTP call made after the test finishes (always, even on failure) |
| `variables` | No | Key-value pairs; use `{{key}}` in instructions |

### Step fields

| Field | Required | Description |
|-------|----------|-------------|
| `instruction` | Yes (unless `call` is set) | Natural language description of what to do |
| `hint` | No | Extra guidance for the LLM (e.g. visual description, CSS selector hints) |
| `assert` | No | Assertion the LLM should verify after acting |
| `timeout` | No | Seconds to wait per LLM call (default: 30) |
| `max_sub_steps` | No | Enables **Explore mode** — LLM loops up to this many times to reach the goal |
| `call` | No | Path to another YAML file to run inline as a sub-test (relative to this file) |
| `with` | No | Variable overrides passed into the sub-test (used with `call`) |

---

## Explore Mode

When a step has `max_sub_steps` set, the runner enters a multi-turn loop:

1. Take a screenshot of the current state
2. Call the LLM with the instruction **plus the full history** of actions already taken
3. Execute the returned action and record it as a factual, past-tense history entry
4. Repeat until the LLM returns `done` (success), `fail` (failure), or the sub-step budget is exhausted

Use explore mode for multi-step flows where the exact number of actions is not known in advance — navigating through menus, filling multi-page forms, or completing any workflow that requires the LLM to reason about intermediate state.

**Repeat-type guard:** if the LLM proposes typing the same value that already appears in history, the step immediately succeeds. This handles password fields (which show only dots after typing) and other inputs where visual confirmation is unavailable.

---

## Sub-test Calls

The `call` field lets a step run another YAML file inline, avoiding duplicated steps across tests (e.g. a shared login sequence).

```yaml
# tests/checkout.yaml
steps:
  - call: shared/login.yaml
    with:
      username: "{{testUser}}"
      password: "secret123"
  - instruction: "Add the first product to the cart"
```

```yaml
# tests/shared/login.yaml
variables:
  username: ""   # default — caller should override
  password: ""

steps:
  - instruction: "Type {{username}} into the email field"
  - instruction: "Type {{password}} into the password field"
  - instruction: "Click Sign In"
```

**Variable merge order** (most specific wins):

1. Caller's own variables
2. Sub-test's `variables` block
3. `with` overrides from the `call` step

Sub-tests can themselves contain `call` steps — paths are always resolved relative to the file that declares them, so nesting works regardless of directory depth.

The call step counts as a single step in the results view: it passes if all sub-steps pass, or fails with the first sub-step error message.

---

## How It Works

```
For each test step:
  1. Take WebView screenshot (PNG)
  2. Send screenshot + instruction + hint → active LLM provider (OVH or Vertex AI)
  3. LLM returns JSON: { "action": "click", "x": 378, "y": 400, ... }
  4. Execute action:
       - click / doubleClick / longPress → JS PointerEvent sequence (synchronous,
         avoids OS-focus issues with embedded WebView2)
       - type  → CDP Input.insertText (after click-to-focus + field clear)
       - pressKey → CDP Input.dispatchKeyEvent
       - scroll → CDP mouseWheel + JS window.scrollBy (belt-and-suspenders)
       - assert_* → JavaScript (returns true/false)
       - call  → load sub-test YAML, merge variables, run steps inline
  5. Wait for page to settle, take "after" screenshot
  6. On failure: retry up to 2× with error context fed back to the LLM
     If primary model fails, retry once with the fallback model
```

**Supported actions:** `click`, `doubleClick`, `longPress`, `type`, `scroll`, `navigate`, `wait`, `hover`, `pressKey`, `selectOption`, `assert_text`, `assert_url`, `assert_visible`, `done`, `fail`

### Session cleanup

After every test run (pass, fail, or abort) the browser state is fully wiped before the next test:

1. Cookies and HTTP cache cleared globally via `CookieManager` and `clearAllCache`
2. Navigate to the start URL so JS runs on the correct origin
3. `localStorage`, `sessionStorage`, JS-accessible cookies, all **IndexedDB** databases (where Firebase Auth stores tokens), and all **service worker** registrations are deleted via `callAsyncJavaScript`
4. Page reloaded so the app boots with completely empty storage

This guarantees every test starts from a logged-out baseline regardless of what the previous test did.

---

## Branding & Icons

The app icon (`assets/app_icon.png`) is used as the source for all platform icons (Windows `.ico`, macOS `.icns` sizes). Icons are generated with [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons).

To regenerate icons after changing the source image:

```bash
dart run flutter_launcher_icons
```

The theme palette is derived from the logo's neon-pink-on-deep-purple colour scheme using Material 3 `ColorScheme.fromSeed`.

---

## Project Structure

```
assets/
└── app_icon.png                # source image used to generate all platform icons

lib/
├── main.dart
├── injection.dart              # get_it service registration + provider switching
├── core/
│   ├── constants.dart          # LlmProvider enum, default URLs and model names
│   └── exceptions.dart
├── models/                     # freezed data models
│   ├── test_case.dart
│   ├── test_step.dart          # supports call + withVars for sub-test steps
│   ├── http_hook.dart
│   ├── llm_action.dart
│   ├── step_result.dart
│   ├── test_run.dart
│   └── app_settings.dart       # per-provider URL, API key, and model config
├── services/
│   ├── webview_service.dart    # CDP + JS action execution, screenshot, session cleanup
│   ├── js_builder.dart         # generates JS for assert_* actions
│   ├── llm_service.dart        # OpenAI-compatible vision API (OVH and Vertex AI)
│   ├── http_hook_service.dart  # seeder / teardown HTTP calls
│   ├── test_runner.dart        # orchestration (standard, explore, and call-step modes)
│   └── storage_service.dart    # YAML load/save, run persistence
├── cubits/
│   ├── builder/
│   ├── runner/
│   └── settings/
├── screens/
│   ├── main_shell.dart
│   ├── builder/
│   │   ├── builder_screen.dart
│   │   ├── test_form.dart
│   │   └── step_list_editor.dart  # Normal / Explore / Call sub-test step modes
│   ├── runner/
│   │   ├── runner_screen.dart
│   │   ├── run_view.dart
│   │   └── results_view.dart
│   └── settings_screen.dart        # provider cards with per-provider config dialogs
└── widgets/
    ├── step_card.dart
    ├── screenshot_panel.dart
    ├── test_case_tile.dart
    └── folder_picker_bar.dart
```

---

## Troubleshooting

### `nuget` is not recognized

The PATH change requires a terminal restart. Close all PowerShell/CMD windows and open a new one.

### `Argument cannot be null or empty — Parameter name: primarySources`

No package sources are configured. Run:

```powershell
nuget sources add -name "nuget.org" -source "https://api.nuget.org/v3/index.json"
```

### `MSB3073` / NuGet restore fails during `flutter run`

1. Confirm `nuget help` works in your terminal
2. Confirm `nuget sources list` shows `nuget.org` as `[Enabled]`
3. Try pre-downloading the packages manually (see Step 5 above)
4. Check `build\windows\x64\` exists — create it if not: `New-Item -ItemType Directory -Force -Path build\windows\x64\packages`

### `Part file not found` / Missing `.freezed.dart` files

Run code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Screenshots are black or empty

WebView2 may need a moment to render. The app retries `takeScreenshot()` once after 500 ms automatically. If screenshots remain blank, ensure `domStorageEnabled: true` and `javaScriptEnabled: true` are set in `InAppWebViewSettings`.

### Test starts already logged in

The session cleanup runs in the `finally` block so it always executes, but it has an 8-second internal timeout and a 40-second outer timeout. If you see a test start in a logged-in state, check the logs for `Browser clean failed` — a slow IndexedDB or service-worker teardown may have timed out. Re-running the suite should resolve it on the next cycle.
