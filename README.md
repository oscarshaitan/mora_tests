# SymUITest

An AI-powered UI test runner built with Flutter Desktop (Windows + macOS).

Tests are described in natural language YAML files. For each step, the app takes a screenshot of an embedded WebView, sends it to **Qwen 2.5 VL 72B** (OVH AI Endpoints), and executes the LLM's returned action via JavaScript injection.

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
# Run from the project root (sym_ui_test\)
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

On first launch, go to the **Settings** tab and enter:

| Field | Value |
|-------|-------|
| LLM Base URL | `https://oai.endpoints.kepler.ai.cloud.ovh.net/v1` |
| API Key | Your OVH AI Endpoints access token |
| Model | `Qwen2.5-VL-72B-Instruct` |

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
  - id: "step-001"
    instruction: "Type the username into the email input field"
    hint: "The field has placeholder 'Email address' and is the first input on the page"
    timeout: 15

  - id: "step-002"
    instruction: "Type the password into the password field"
    timeout: 15

  - id: "step-003"
    instruction: "Click the login button to submit the form"
    hint: "Look for a blue button at the bottom of the form that says 'Sign In' or 'Login'"
    timeout: 20

  - id: "step-004"
    instruction: "Verify the dashboard loaded successfully"
    assert: "URL should contain /dashboard and a welcome banner should be visible"
    timeout: 30
```

### Fields

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier (UUID recommended) |
| `name` | Yes | Display name for the test |
| `start_url` | Yes | URL the WebView navigates to before step 1 |
| `seeder` | No | HTTP call made before the test runs |
| `teardown` | No | HTTP call made after the test finishes |
| `variables` | No | Key-value pairs; use `{{key}}` in instructions |
| `steps[].instruction` | Yes | Natural language description of what to do |
| `steps[].hint` | No | Extra guidance for the LLM (e.g. CSS selector hints, visual description) |
| `steps[].assert` | No | Assertion the LLM should verify |
| `steps[].timeout` | No | Seconds to wait (default: 30) |

---

## Project Structure

```
lib/
├── main.dart
├── injection.dart              # get_it service registration
├── core/
│   ├── constants.dart
│   └── exceptions.dart
├── models/                     # freezed data models
│   ├── test_case.dart
│   ├── test_step.dart
│   ├── http_hook.dart
│   ├── llm_action.dart
│   ├── step_result.dart
│   ├── test_run.dart
│   └── app_settings.dart
├── services/
│   ├── webview_service.dart    # screenshot + JS injection
│   ├── js_builder.dart         # generates JS per action type
│   ├── llm_service.dart        # OVH Qwen vision API
│   ├── http_hook_service.dart  # seeder / teardown HTTP calls
│   ├── test_runner.dart        # orchestration loop
│   └── storage_service.dart    # YAML load/save
├── cubits/
│   ├── builder/
│   ├── runner/
│   └── settings/
├── screens/
│   ├── main_shell.dart
│   ├── builder/
│   │   ├── builder_screen.dart
│   │   ├── test_form.dart
│   │   └── step_list_editor.dart
│   ├── runner/
│   │   ├── runner_screen.dart
│   │   ├── run_view.dart
│   │   └── results_view.dart
│   └── settings_screen.dart
└── widgets/
    ├── step_card.dart
    ├── screenshot_panel.dart
    ├── test_case_tile.dart
    └── folder_picker_bar.dart
```

---

## How It Works

```
For each test step:
  1. Take WebView screenshot (PNG)
  2. Send screenshot + instruction + hint → Qwen 2.5 VL 72B (OVH)
  3. LLM returns JSON: { "type": "click", "cssSelector": "button.submit", ... }
  4. Flutter executes action via JavaScript injection into WebView
  5. Wait for page to settle, take "after" screenshot
  6. On failure: retry up to 2× with error context
```

**Supported actions:** `click`, `doubleClick`, `type`, `scroll`, `navigate`, `wait`, `hover`, `pressKey`, `selectOption`, `assert_text`, `assert_url`, `assert_visible`, `done`, `fail`

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

WebView2 may need a moment to render. The app retries `takeScreenshot()` once after 500ms automatically. If screenshots remain blank, ensure `domStorageEnabled: true` and `javaScriptEnabled: true` are set in `InAppWebViewSettings`.
