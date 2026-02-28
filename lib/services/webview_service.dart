import 'dart:async';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/exceptions.dart';
import '../models/llm_action.dart';
import 'js_builder.dart';

class WebViewService {
  InAppWebViewController? _controller;
  final JsBuilder _jsBuilder;

  /// Completes when the current WebView controller attaches.
  /// Re-created by reset() so the second run waits for the new WebView.
  Completer<void> _readyCompleter = Completer<void>();

  /// Replaced each time navigate() is called; completed by notifyLoadStop().
  Completer<void>? _loadStopCompleter;

  /// Cached devicePixelRatio of the loaded page.
  /// Screenshots are in physical pixels; JS clientX/Y must be CSS pixels.
  /// Divide action.x/y by _dpr before using them in JS/CDP events.
  /// Coordinates from _resolveCenter (getBoundingClientRect) are already CSS px — no division needed.
  double _dpr = 1.0;

  WebViewService(this._jsBuilder);

  bool get isReady => _controller != null;

  /// Called by the InAppWebView widget's onWebViewCreated callback.
  void attach(InAppWebViewController controller) {
    _controller = controller;
    if (!_readyCompleter.isCompleted) _readyCompleter.complete();
  }

  /// Called by the InAppWebView widget's onLoadStop callback.
  void notifyLoadStop() {
    if (_loadStopCompleter != null && !_loadStopCompleter!.isCompleted) {
      _loadStopCompleter!.complete();
    }
  }

  /// Clears the stale controller and re-arms the ready completer.
  ///
  /// Must be called before re-mounting a RunView so that waitUntilReady()
  /// blocks until the NEW InAppWebView fires onWebViewCreated, instead of
  /// returning immediately with the dead controller from the previous run.
  void reset() {
    _controller = null;
    _loadStopCompleter = null;
    _readyCompleter = Completer<void>();
    _dpr = 1.0;
  }

  Future<void> waitUntilReady() => _readyCompleter.future;

  InAppWebViewController get _ctrl {
    if (_controller == null) {
      throw WebViewException('WebView controller not attached');
    }
    return _controller!;
  }

  // ── CDP helper ─────────────────────────────────────────────────────────────

  /// Sends a Chrome DevTools Protocol command directly to the browser engine.
  Future<dynamic> _cdp(String method, Map<String, dynamic> params) async {
    try {
      final result = await _ctrl.callDevToolsProtocolMethod(
        methodName: method,
        parameters: params,
      );
      return result;
    } catch (e) {
      dev.log('CDP $method failed: $e', name: 'SymUITest');
      rethrow;
    }
  }

  /// Focuses the WebView by executing a tiny JS snippet, then waits briefly.
  /// This ensures the browser renderer has focus before CDP input events are
  /// processed — without focus, CDP mouse/key events are silently dropped.
  Future<void> _ensureFocus() async {
    try {
      // window.focus() asks the browser to take focus.
      // This reliably moves renderer focus even in composition mode.
      await _ctrl.evaluateJavascript(source: 'window.focus();');
      await Future.delayed(const Duration(milliseconds: 80));
    } catch (_) {}
  }

  /// Reads and caches the page's devicePixelRatio.
  /// Called after every navigate() so _dpr is always fresh.
  Future<void> _readDpr() async {
    try {
      final v = await _ctrl.evaluateJavascript(source: 'window.devicePixelRatio');
      if (v is num && v > 0) {
        _dpr = v.toDouble();
      }
    } catch (_) {}
  }

  /// Quick tap at (x, y) via a single synchronous JS pointer+mouse event sequence.
  ///
  /// Why JS instead of CDP for clicks:
  /// - CDP `Input.dispatchMouseEvent` requires the WebView2 renderer to hold
  ///   native OS focus. In embedded mode on Windows this is unreliable —
  ///   events are silently dropped when focus isn't properly handed over.
  /// - JS `dispatchEvent` bypasses the OS focus requirement; it goes straight
  ///   into the JS engine and always fires.
  /// - Crucially, the entire press+release sequence runs in ONE evaluateJavascript
  ///   call, so there is zero async gap between pointerdown and pointerup.
  ///   The old approach (CDP down/up → then JS down/up) had async gaps between
  ///   the two cycles (~60 ms) which many frameworks interpreted as a sustained
  ///   hold, causing unintended long-press behaviour.
  Future<void> _cdpClick(double x, double y, {int clickCount = 1}) async {
    // JS pointer events don't need OS focus — do NOT call _ensureFocus() here.
    // window.focus() can silently restore a previously blurred input element,
    // which defeats the blur-after-type step and re-introduces the
    // "gesture arena disrupted by rebuild" problem on the subsequent click.
    await _jsPointerClick(x, y, isDouble: clickCount == 2);
  }

  /// Holds the pointer down for [durationMs] before releasing — a long press.
  /// Uses CDP so the browser sees a real sustained pointer contact.
  Future<void> _cdpLongPress(double x, double y, {int durationMs = 800}) async {
    dev.log('LongPress → ($x, $y) for ${durationMs}ms', name: 'SymUITest');
    await _ensureFocus();

    final params = {
      'x': x,
      'y': y,
      'button': 'left',
      'modifiers': 0,
      'clickCount': 1,
      'pointerType': 'mouse',
    };
    try {
      await _cdp('Input.dispatchMouseEvent', {...params, 'type': 'mouseMoved'});
      await _cdp('Input.dispatchMouseEvent', {...params, 'type': 'mousePressed'});
      await Future.delayed(Duration(milliseconds: durationMs));
      await _cdp('Input.dispatchMouseEvent', {...params, 'type': 'mouseReleased'});
    } catch (e) {
      dev.log('CDP longPress failed: $e', name: 'SymUITest');
    }
  }

  /// Fires JS PointerEvent sequence at the given coordinates.
  /// pointerdown + pointerup are dispatched SYNCHRONOUSLY in a single
  /// evaluateJavascript call. Flutter's setState/rebuild is deferred to the
  /// next animation frame, so the gesture arena cannot be disrupted between
  /// the two events — the recogniser that caught pointerdown is still alive
  /// when pointerup arrives and the tap fires correctly.
  Future<void> _jsPointerClick(double x, double y,
      {bool isDouble = false}) async {
    final ix = x.round();
    final iy = y.round();

    final js = '''
(function() {
  var ix = $ix, iy = $iy;
  var base = {
    bubbles: true, cancelable: true, composed: true, view: window,
    clientX: ix, clientY: iy, screenX: ix, screenY: iy,
    buttons: 0, button: 0, detail: 0,
    pointerId: 1, pointerType: 'mouse', isPrimary: true, pressure: 0.0
  };

  var el = document.elementFromPoint(ix, iy) || document.documentElement;
  var cs  = window.getComputedStyle(el);
  var rect = el.getBoundingClientRect();
  var active = document.activeElement ? document.activeElement.tagName : 'none';

  function fire(type, extra) {
    var init = Object.assign({}, base, extra || {});
    return el.dispatchEvent(new PointerEvent(type, init)); // returns false if preventDefault
  }

  fire('pointermove');
  var pdOk = fire('pointerdown', { detail: 1, buttons: 1, pressure: 0.5 });
  var puOk = fire('pointerup',   { detail: 1, buttons: 0, pressure: 0.0 });
  fire('pointermove', { buttons: 0, pressure: 0.0 });

  ${isDouble ? '''
  fire('pointerdown', { detail: 2, buttons: 1, pressure: 0.5 });
  fire('pointerup',   { detail: 2, buttons: 0, pressure: 0.0 });
  ''' : ''}

  setTimeout(function() {
    if (el !== document.documentElement && typeof el.click === 'function') el.click();
  }, 0);

  // Diagnostic payload — logged by Dart so we can diagnose click failures
  return JSON.stringify({
    tag:     el.tagName,
    id:      el.id || null,
    rect:    { x: Math.round(rect.x), y: Math.round(rect.y), w: Math.round(rect.width), h: Math.round(rect.height) },
    pe:      cs.pointerEvents,
    vis:     cs.visibility,
    zIndex:  cs.zIndex,
    pdOk:    pdOk,
    puOk:    puOk,
    active:  active,
    dpr:     window.devicePixelRatio
  });
})()''';

    try {
      await _ctrl.evaluateJavascript(source: js);
    } catch (e) {
      dev.log('JS click failed: $e', name: 'SymUITest');
    }
  }

  /// Types a string via CDP Input.insertText.
  /// The browser must already have focus on the target text field.
  Future<void> _cdpType(String text) async {
    dev.log('Type → "$text"', name: 'SymUITest');
    await _ensureFocus();
    try {
      await _cdp('Input.insertText', {'text': text});
    } catch (e) {
      dev.log('CDP insertText failed: $e — trying JS fallback', name: 'SymUITest');
      // JS fallback: type into the currently focused element
      final escaped = text.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
      await _ctrl.evaluateJavascript(source: '''
(function(){
  var el = document.activeElement;
  if (!el || el === document.body) return;
  var native = Object.getOwnPropertyDescriptor(
    window.HTMLInputElement.prototype, 'value')?.set ||
    Object.getOwnPropertyDescriptor(
    window.HTMLTextAreaElement.prototype, 'value')?.set;
  if (native) { native.call(el, '$escaped'); }
  else if (el.isContentEditable) { el.textContent = '$escaped'; }
  else if ('value' in el) { el.value = '$escaped'; }
  el.dispatchEvent(new Event('input', {bubbles: true}));
  el.dispatchEvent(new Event('change', {bubbles: true}));
})()''');
    }
  }

  /// Sends a key press via CDP (e.g. Enter, Tab, Escape).
  Future<void> _cdpKey(String key) async {
    dev.log('Key → $key', name: 'SymUITest');
    await _ensureFocus();
    final text = _keyText(key);
    final code = _keyCode(key);
    final windowsVk = _windowsVk(key);

    final params = {
      'key': key,
      'code': code,
      'text': text,
      'unmodifiedText': text,
      'modifiers': 0,
      'windowsVirtualKeyCode': windowsVk,
      'nativeVirtualKeyCode': windowsVk,
      'autoRepeat': false,
      'isKeypad': false,
      'isSystemKey': false,
    };
    await _cdp('Input.dispatchKeyEvent', {...params, 'type': 'rawKeyDown'});
    if (text.isNotEmpty) {
      await _cdp('Input.dispatchKeyEvent', {...params, 'type': 'char'});
    }
    await _cdp('Input.dispatchKeyEvent', {...params, 'type': 'keyUp'});
  }

  // ── Element resolution helpers ─────────────────────────────────────────────

  /// Resolves an element's center coordinates using multiple strategies:
  /// 1. Standard querySelector (with behavior:'instant' scroll to avoid stale rects)
  /// 2. Shadow DOM piercing (one level deep)
  /// 3. XPath selector
  ///
  /// Returns null if the element cannot be found by any strategy.
  Future<List<double>?> _resolveCenter(
      String? cssSelector, String? xpathSelector) async {
    if (cssSelector != null && cssSelector.isNotEmpty) {
      final sel = cssSelector.replaceAll("'", r"\'");
      final rect = await evaluateJs("""
(function(){
  var el = document.querySelector('$sel');
  // Shadow DOM piercing — one level deep
  if (!el) {
    var all = document.querySelectorAll('*');
    for (var i = 0; i < all.length; i++) {
      if (all[i].shadowRoot) {
        var f = all[i].shadowRoot.querySelector('$sel');
        if (f) { el = f; break; }
      }
    }
  }
  if (!el) return null;
  // behavior:'instant' avoids smooth-scroll race where getBoundingClientRect
  // is called before the element has reached its final scroll position.
  el.scrollIntoView({block:'nearest', inline:'nearest', behavior:'instant'});
  var r = el.getBoundingClientRect();
  if (r.width === 0 && r.height === 0) return null;
  return [r.left + r.width/2, r.top + r.height/2];
})()""");
      if (rect is List && rect.length == 2) {
        return [(rect[0] as num).toDouble(), (rect[1] as num).toDouble()];
      }
    }

    if (xpathSelector != null && xpathSelector.isNotEmpty) {
      final xp = xpathSelector.replaceAll("'", r"\'");
      final rect = await evaluateJs("""
(function(){
  var el = document.evaluate('$xp', document, null,
    XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
  if (!el) return null;
  el.scrollIntoView({block:'nearest', inline:'nearest', behavior:'instant'});
  var r = el.getBoundingClientRect();
  if (r.width === 0 && r.height === 0) return null;
  return [r.left + r.width/2, r.top + r.height/2];
})()""");
      if (rect is List && rect.length == 2) {
        return [(rect[0] as num).toDouble(), (rect[1] as num).toDouble()];
      }
    }

    return null;
  }

  /// Pure-JS click fallback for when coordinate resolution fails.
  /// Uses el.click() (trusted in the DOM sense) and a pointer event sequence.
  /// Covers elements that don't respond to CDP synthetic mouse events.
  Future<void> _jsFallbackClick(String cssSelector, {bool isDouble = false}) async {
    final sel = cssSelector.replaceAll("'", r"\'");
    await evaluateJs("""
(function(){
  var el = document.querySelector('$sel');
  if (!el) {
    var all = document.querySelectorAll('*');
    for (var i = 0; i < all.length; i++) {
      if (all[i].shadowRoot) {
        var f = all[i].shadowRoot.querySelector('$sel');
        if (f) { el = f; break; }
      }
    }
  }
  if (!el) return 'NOT_FOUND';
  el.scrollIntoView({block:'nearest', behavior:'instant'});
  el.focus && el.focus();
  var r = el.getBoundingClientRect();
  var cx = r.left + r.width/2, cy = r.top + r.height/2;
  var opts = {bubbles:true, cancelable:true, composed:true, view:window,
    clientX:cx, clientY:cy, pointerId:1, pointerType:'mouse', isPrimary:true};
  el.dispatchEvent(new PointerEvent('pointerdown', opts));
  el.dispatchEvent(new MouseEvent('mousedown', opts));
  el.dispatchEvent(new PointerEvent('pointerup', opts));
  el.dispatchEvent(new MouseEvent('mouseup', opts));
  el.dispatchEvent(new MouseEvent('click', opts));
  el.click && el.click();
  return 'OK';
})()""");
  }

  /// Clears an input element's existing value using the native property setter.
  /// This is necessary because Input.insertText appends to existing content.
  /// Using the native setter triggers React/Vue/Angular controlled-input sync.
  Future<void> _clearElement(String? cssSelector) async {
    final findEl = (cssSelector != null && cssSelector.isNotEmpty)
        ? "document.querySelector('${cssSelector.replaceAll("'", r"\'")}') || document.activeElement"
        : "document.activeElement";
    await evaluateJs("""
(function(){
  var el = $findEl;
  if (!el || el === document.body) return;
  var nativeSetter =
    Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value')?.set ||
    Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype, 'value')?.set;
  if (nativeSetter) { nativeSetter.call(el, ''); }
  else if (el.isContentEditable) { el.textContent = ''; }
  else if ('value' in el) { el.value = ''; }
})()""");
  }

  /// Dispatches input + change events after typing, so that React/Vue/Angular
  /// controlled inputs pick up the new value from CDP insertText.
  Future<void> _dispatchInputEvents(String? cssSelector) async {
    final findEl = (cssSelector != null && cssSelector.isNotEmpty)
        ? "document.querySelector('${cssSelector.replaceAll("'", r"\'")}') || document.activeElement"
        : "document.activeElement";
    await evaluateJs("""
(function(){
  var el = $findEl;
  if (!el || el === document.body) return;
  el.dispatchEvent(new Event('input', {bubbles:true}));
  el.dispatchEvent(new Event('change', {bubbles:true}));
})()""");
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Navigate to [url] and wait for the page to finish loading (up to 12s).
  ///
  /// When [clean] is true the browser state is fully wiped before the test
  /// starts, guaranteeing a logged-out baseline:
  ///
  ///  1. Cookies and HTTP cache are cleared globally (origin-independent).
  ///  2. The page is loaded so the JS engine is on the correct origin.
  ///  3. localStorage + sessionStorage are cleared while on that origin
  ///     (they are origin-scoped — clearing from about:blank does nothing).
  ///  4. The page is reloaded so the app boots with completely empty storage.
  ///
  /// In-test `navigate` actions always use [clean]=false (the default).
  Future<void> navigate(String url, {bool clean = false}) async {
    if (clean) {
      // Step 1 — global clears (work from any origin / any page).
      try { await CookieManager.instance().deleteAllCookies(); } catch (_) {}
      try { await InAppWebViewController.clearAllCache(); } catch (_) {}
      _dpr = 1.0;
    }

    // Load the page (first load if clean, only load otherwise).
    _loadStopCompleter = Completer<void>();
    await _ctrl.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    await _loadStopCompleter!.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () {/* continue */},
    );

    if (clean) {
      // Step 2 — storage clear: we are now on the correct origin.
      // Uses callAsyncJavaScript so we can properly await IndexedDB operations.
      //
      // Clears (in order):
      //  a) localStorage + sessionStorage  (sync, fastest)
      //  b) Non-HttpOnly cookies via JS    (belt-and-suspenders on top of
      //                                    CookieManager.deleteAllCookies)
      //  c) IndexedDB databases            (Firebase Auth stores tokens here —
      //                                    this is the most common cause of
      //                                    "still logged in" after cleanup)
      //  d) Service worker registrations   (may cache auth responses)
      try {
        await _ctrl.callAsyncJavaScript(functionBody: r'''
try { window.localStorage.clear(); } catch(e) {}
try { window.sessionStorage.clear(); } catch(e) {}

// Clear JS-accessible (non-HttpOnly) cookies
try {
  document.cookie.split(';').forEach(function(c) {
    var k = c.split('=')[0].trim();
    if (!k) return;
    document.cookie = k + '=;expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/;';
    document.cookie = k + '=;expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/;domain='
                      + location.hostname + ';';
  });
} catch(e) {}

// Delete all IndexedDB databases (Firebase Auth, PouchDB, etc.)
try {
  if (window.indexedDB && window.indexedDB.databases) {
    var dbs = await window.indexedDB.databases();
    await Promise.all(dbs.map(function(db) {
      return new Promise(function(resolve) {
        var req = window.indexedDB.deleteDatabase(db.name);
        req.onsuccess = resolve;
        req.onerror   = resolve;
        req.onblocked = resolve;
      });
    }));
  }
} catch(e) {}

// Unregister all service workers (may cache authenticated API responses)
try {
  if (navigator.serviceWorker) {
    var regs = await navigator.serviceWorker.getRegistrations();
    await Promise.all(regs.map(function(r) { return r.unregister(); }));
  }
} catch(e) {}
''').timeout(const Duration(seconds: 8), onTimeout: () => null);
      } catch (_) {}

      // Step 3 — reload: the app now boots with empty storage and no cookies.
      dev.log('Storage cleared — reloading for clean start…', name: 'SymUITest');
      _loadStopCompleter = Completer<void>();
      await _ctrl.reload();
      await _loadStopCompleter!.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () {/* continue */},
      );
      dev.log('Clean navigate ✓', name: 'SymUITest');
    }

    await _readDpr();
  }

  // ── Screenshot ─────────────────────────────────────────────────────────────

  Future<Uint8List> screenshot() async {
    final bytes = await _ctrl.takeScreenshot();
    if (bytes == null || bytes.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      final retry = await _ctrl.takeScreenshot();
      if (retry == null || retry.isEmpty) {
        throw WebViewException('takeScreenshot returned null');
      }
      return retry;
    }
    return bytes;
  }

  Future<dynamic> evaluateJs(String js) async {
    return _ctrl.evaluateJavascript(source: js);
  }

  // ── Action dispatch ────────────────────────────────────────────────────────

  Future<void> executeAction(LlmAction action) async {
    if (action.type == ActionType.done || action.type == ActionType.fail) {
      return;
    }

    if (action.type == ActionType.wait) {
      await Future.delayed(Duration(milliseconds: action.waitMs ?? 1000));
      return;
    }

    if (action.type == ActionType.navigate) {
      if (action.url != null && action.url!.isNotEmpty) {
        dev.log('NAV → ${action.url}', name: 'SymUITest');
        await navigate(action.url!);
      }
      return;
    }

    // ── click / doubleClick / longPress ─────────────────────────────────────
    if (action.type == ActionType.click ||
        action.type == ActionType.doubleClick ||
        action.type == ActionType.longPress) {
      final clickCount = action.type == ActionType.doubleClick ? 2 : 1;

      // Resolve element center: CSS selector (with shadow DOM) → XPath → raw coords.
      // _resolveCenter returns CSS pixels (getBoundingClientRect).
      // action.x/y are physical pixels from the LLM screenshot → divide by _dpr.
      final center =
          await _resolveCenter(action.cssSelector, action.xpathSelector);
      final x = center?[0] ?? (action.x != null ? action.x! / _dpr : null);
      final y = center?[1] ?? (action.y != null ? action.y! / _dpr : null);

      if (x != null && y != null) {
        if (action.type == ActionType.longPress) {
          await _cdpLongPress(x, y, durationMs: action.waitMs ?? 800);
        } else {
          await _cdpClick(x, y, clickCount: clickCount);
        }
      } else if (action.cssSelector != null &&
          action.cssSelector!.isNotEmpty) {
        // Coordinates could not be resolved — fall back to pure JS click.
        dev.log('click: coords not resolved, using JS fallback', name: 'SymUITest');
        await _jsFallbackClick(action.cssSelector!, isDouble: clickCount == 2);
      } else {
        dev.log('click: no selector or coordinates available', name: 'SymUITest');
      }
      return;
    }

    // ── type ────────────────────────────────────────────────────────────────
    if (action.type == ActionType.type && action.value != null) {
      // Step 1: Focus the element via CDP click (most reliable) or JS fallback.
      // Same DPR conversion as the click path above.
      final center =
          await _resolveCenter(action.cssSelector, action.xpathSelector);
      final x = center?[0] ?? (action.x != null ? action.x! / _dpr : null);
      final y = center?[1] ?? (action.y != null ? action.y! / _dpr : null);

      if (x != null && y != null) {
        await _cdpClick(x, y);
        // 350 ms gives SPAs time to route focus to the underlying <input>
        await Future.delayed(const Duration(milliseconds: 350));
      } else if (action.cssSelector != null &&
          action.cssSelector!.isNotEmpty) {
        // Can't resolve coordinates — JS focus fallback
        final sel = action.cssSelector!.replaceAll("'", r"\'");
        await evaluateJs("""
(function(){
  var el = document.querySelector('$sel');
  if (el) { el.scrollIntoView({block:'nearest', behavior:'instant'}); el.focus(); el.click(); }
})()""");
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Step 2: Clear existing content so insertText doesn't append
      await _clearElement(action.cssSelector);
      await Future.delayed(const Duration(milliseconds: 50));

      // Step 3: Type via CDP (inserts into the focused browser input)
      await _cdpType(action.value!);

      // Step 4: Dispatch input + change so React/Vue/Angular pick up the value
      await Future.delayed(const Duration(milliseconds: 50));
      await _dispatchInputEvents(action.cssSelector);

      // Step 5: Blur the field so the next click action starts with no focused
      // input. Flutter's hidden <input> retaining focus causes widget rebuilds
      // mid-tap that break the gesture arena on the subsequent click.
      await _ctrl.evaluateJavascript(source: '''
(function(){
  var el = document.activeElement;
  while (el && el.shadowRoot) {
    var inner = el.shadowRoot.activeElement;
    if (!inner) break;
    el = inner;
  }
  if (el && el !== document.body && el !== document.documentElement) el.blur();
})()''');
      await Future.delayed(const Duration(milliseconds: 150));
      return;
    }

    // ── scroll ──────────────────────────────────────────────────────────────
    if (action.type == ActionType.scroll) {
      await _ensureFocus();
      final dx = (action.scrollDeltaX ?? 0).toDouble();
      final dy = (action.scrollDeltaY ?? 300).toDouble();
      // action.x/y are physical px → convert to CSS px for CDP mouseWheel
      final x = (action.x != null ? action.x! / _dpr : 400.0);
      final y = (action.y != null ? action.y! / _dpr : 300.0);
      dev.log('Scroll → dx=$dx dy=$dy', name: 'SymUITest');

      // Try CDP scroll first
      try {
        await _cdp('Input.dispatchMouseEvent', {
          'type': 'mouseWheel',
          'x': x,
          'y': y,
          'deltaX': dx,
          'deltaY': dy,
          'modifiers': 0,
          'pointerType': 'mouse',
        });
      } catch (_) {}

      // Also JS scroll for belt-and-suspenders
      await evaluateJs('window.scrollBy($dx, $dy);');
      return;
    }

    // ── pressKey ─────────────────────────────────────────────────────────────
    if (action.type == ActionType.pressKey && action.key != null) {
      await _cdpKey(action.key!);
      return;
    }

    // ── hover ────────────────────────────────────────────────────────────────
    if (action.type == ActionType.hover &&
        action.x != null &&
        action.y != null) {
      await _ensureFocus();
      await _cdp('Input.dispatchMouseEvent', {
        'type': 'mouseMoved',
        'x': action.x! / _dpr,
        'y': action.y! / _dpr,
        'button': 'none',
        'modifiers': 0,
        'pointerType': 'mouse',
      });
      return;
    }

    // ── assertions (JS still works fine for these) ──────────────────────────
    final js = _jsBuilder.build(action);
    final result = await evaluateJs(js);
    dev.log('Assert ${action.type.name} → $result', name: 'SymUITest');

    if (action.type == ActionType.assert_text ||
        action.type == ActionType.assert_url ||
        action.type == ActionType.assert_visible) {
      if (result == false || result == 'false') {
        throw WebViewException(
          'Assertion failed: ${action.type.name} result=$result',
        );
      }
    }
  }

  Future<String> currentUrl() async {
    final url = await _ctrl.getUrl();
    return url?.toString() ?? '';
  }

  // ── Key mapping helpers ───────────────────────────────────────────────────

  /// The text character generated by a key press (empty for control keys).
  String _keyText(String key) {
    const map = {
      'Enter': '\r', 'Return': '\r',
      'Tab': '\t',
      'Space': ' ', ' ': ' ',
      'Backspace': '\b',
    };
    if (map.containsKey(key)) return map[key]!;
    if (key.length == 1) return key;
    return '';
  }

  /// CDP `code` field (physical key).
  String _keyCode(String key) {
    const map = {
      'Enter': 'Enter', 'Return': 'Enter',
      'Tab': 'Tab',
      'Escape': 'Escape', 'Esc': 'Escape',
      'Space': 'Space', ' ': 'Space',
      'Backspace': 'Backspace',
      'Delete': 'Delete',
      'ArrowLeft': 'ArrowLeft',
      'ArrowRight': 'ArrowRight',
      'ArrowUp': 'ArrowUp',
      'ArrowDown': 'ArrowDown',
      'Home': 'Home',
      'End': 'End',
      'PageUp': 'PageUp',
      'PageDown': 'PageDown',
    };
    if (map.containsKey(key)) return map[key]!;
    if (key.length == 1) return 'Key${key.toUpperCase()}';
    return key;
  }

  /// Windows Virtual Key code for CDP `windowsVirtualKeyCode`.
  int _windowsVk(String key) {
    const map = {
      'Enter': 13, 'Return': 13,
      'Tab': 9,
      'Escape': 27, 'Esc': 27,
      'Space': 32, ' ': 32,
      'Backspace': 8,
      'Delete': 46,
      'ArrowLeft': 37,
      'ArrowUp': 38,
      'ArrowRight': 39,
      'ArrowDown': 40,
      'Home': 36,
      'End': 35,
      'PageUp': 33,
      'PageDown': 34,
    };
    if (map.containsKey(key)) return map[key]!;
    if (key.length == 1) return key.toUpperCase().codeUnitAt(0);
    return 0;
  }
}
