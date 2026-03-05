import 'package:flutter_test/flutter_test.dart';
import 'package:mora_tests/models/llm_action.dart';
import 'package:mora_tests/services/js_builder.dart';

void main() {
  late JsBuilder builder;

  setUp(() {
    builder = JsBuilder();
  });

  // ── Helpers ────────────────────────────────────────────────────────────────

  LlmAction action(
    ActionType type, {
    String? cssSelector,
    String? xpathSelector,
    double? x,
    double? y,
    String? value,
    String? url,
    String? key,
    int? scrollDeltaX,
    int? scrollDeltaY,
    int? waitMs,
    String? expectedText,
    String? expectedUrl,
  }) {
    return LlmAction(
      type: type,
      cssSelector: cssSelector,
      xpathSelector: xpathSelector,
      x: x,
      y: y,
      value: value,
      url: url,
      key: key,
      scrollDeltaX: scrollDeltaX,
      scrollDeltaY: scrollDeltaY,
      waitMs: waitMs,
      expectedText: expectedText,
      expectedUrl: expectedUrl,
    );
  }

  // ── click ──────────────────────────────────────────────────────────────────

  group('click', () {
    test('by coordinates — uses elementFromPoint', () {
      final js = builder.build(action(ActionType.click, x: 100, y: 200));
      expect(js, contains('elementFromPoint(100.0,200.0)'));
      expect(js, contains("dispatchEvent(new MouseEvent('click'"));
    });

    test('by CSS selector — scrolls into view and fires events', () {
      final js = builder.build(
          action(ActionType.click, cssSelector: '#submit-btn'));
      expect(js, contains("querySelector('#submit-btn')"));
      expect(js, contains('scrollIntoView'));
      expect(js, contains("dispatchEvent(new MouseEvent('click'"));
      expect(js, contains('el.click()'));
    });

    test('by xpath selector — uses document.evaluate', () {
      final js = builder.build(
          action(ActionType.click, xpathSelector: '//button[@id="ok"]'));
      expect(js, contains('document.evaluate'));
      // _esc escapes only single quotes and backslashes; double quotes are safe
      // inside single-quoted JS string literals and are left unescaped.
      expect(js, contains('//button[@id="ok"]'));
      expect(js, contains("dispatchEvent(new MouseEvent('click'"));
    });

    test('CSS selector takes priority over coordinates', () {
      final js = builder.build(
          action(ActionType.click, cssSelector: '.btn', x: 50, y: 50));
      expect(js, contains("querySelector('.btn')"));
      expect(js, isNot(contains('elementFromPoint')));
    });

    test('no target — returns void 0', () {
      final js = builder.build(action(ActionType.click));
      expect(js.trim(), equals('void 0;'));
    });

    test('fires full pointer + mouse event sequence', () {
      final js = builder.build(action(ActionType.click, x: 10, y: 20));
      expect(js, contains("PointerEvent('pointerdown'"));
      expect(js, contains("MouseEvent('mousedown'"));
      expect(js, contains("PointerEvent('pointerup'"));
      expect(js, contains("MouseEvent('mouseup'"));
      expect(js, contains("MouseEvent('click'"));
    });

    test('does NOT fire dblclick event for single click', () {
      final js = builder.build(action(ActionType.click, x: 10, y: 20));
      expect(js, isNot(contains('dblclick')));
    });
  });

  // ── doubleClick ────────────────────────────────────────────────────────────

  group('doubleClick', () {
    test('fires dblclick event', () {
      final js = builder.build(action(ActionType.doubleClick, x: 50, y: 60));
      expect(js, contains('dblclick'));
    });

    test('fires two click events before dblclick', () {
      final js = builder.build(action(ActionType.doubleClick, x: 50, y: 60));
      // Count click occurrences — should appear twice before dblclick
      final clickCount = "MouseEvent('click'".allMatches(js).length;
      expect(clickCount, equals(2));
    });

    test('by CSS selector', () {
      final js = builder.build(
          action(ActionType.doubleClick, cssSelector: 'td.cell'));
      expect(js, contains("querySelector('td.cell')"));
      expect(js, contains('dblclick'));
    });
  });

  // ── hover ──────────────────────────────────────────────────────────────────

  group('hover', () {
    test('by CSS selector — fires mouseover and mouseenter', () {
      final js =
          builder.build(action(ActionType.hover, cssSelector: '.menu-item'));
      expect(js, contains("querySelector('.menu-item')"));
      expect(js, contains("MouseEvent('mouseover'"));
      expect(js, contains("MouseEvent('mouseenter'"));
    });

    test('by coordinates — fires mouseover at point', () {
      final js = builder.build(action(ActionType.hover, x: 75, y: 80));
      expect(js, contains('elementFromPoint(75.0,80.0)'));
      expect(js, contains("MouseEvent('mouseover'"));
    });
  });

  // ── type ──────────────────────────────────────────────────────────────────

  group('type', () {
    test('by CSS selector — focuses, sets value, dispatches events', () {
      final js = builder.build(
          action(ActionType.type, cssSelector: '#email', value: 'user@test.com'));
      expect(js, contains("querySelector('#email')"));
      expect(js, contains('el.focus()'));
      expect(js, contains("'user@test.com'"));
      expect(js, contains("Event('input'"));
      expect(js, contains("Event('change'"));
    });

    test('by xpath selector', () {
      final js = builder.build(action(
        ActionType.type,
        xpathSelector: '//input[@name="email"]',
        value: 'hello',
      ));
      expect(js, contains('document.evaluate'));
      expect(js, contains("'hello'"));
      expect(js, contains("Event('input'"));
    });

    test('fallback to active element when no selector given', () {
      final js =
          builder.build(action(ActionType.type, value: 'typed text'));
      expect(js, contains('document.activeElement'));
      expect(js, contains("'typed text'"));
    });

    test('empty value is handled without error', () {
      final js = builder.build(
          action(ActionType.type, cssSelector: '#field', value: ''));
      expect(js, isNotEmpty);
      expect(js, contains("querySelector('#field')"));
    });

    test('escapes single quotes in value', () {
      final js = builder.build(
          action(ActionType.type, cssSelector: '#f', value: "it's alive"));
      expect(js, contains(r"it\'s alive"));
    });

    test('uses native value setter to trigger React/Vue onChange', () {
      final js = builder.build(
          action(ActionType.type, cssSelector: '#inp', value: 'v'));
      // Should reference the native prototype setter
      expect(js, contains('HTMLInputElement.prototype'));
    });
  });

  // ── scroll ────────────────────────────────────────────────────────────────

  group('scroll', () {
    test('without selector — calls window.scrollBy', () {
      final js = builder.build(
          action(ActionType.scroll, scrollDeltaX: 0, scrollDeltaY: 300));
      expect(js, contains('window.scrollBy(0,300)'));
    });

    test('with CSS selector — calls element.scrollBy', () {
      final js = builder.build(action(
        ActionType.scroll,
        cssSelector: '.feed',
        scrollDeltaY: 600,
      ));
      expect(js, contains("querySelector('.feed')"));
      expect(js, contains('scrollBy(0,600)'));
    });

    test('defaults scrollDeltaY to 300 when not provided', () {
      final js = builder.build(action(ActionType.scroll));
      expect(js, contains('window.scrollBy(0,300)'));
    });

    test('negative delta scrolls up', () {
      final js = builder.build(
          action(ActionType.scroll, scrollDeltaY: -200));
      expect(js, contains('window.scrollBy(0,-200)'));
    });
  });

  // ── navigate ──────────────────────────────────────────────────────────────

  group('navigate', () {
    test('sets window.location.href to given URL', () {
      final js = builder.build(
          action(ActionType.navigate, url: 'https://example.com/page'));
      expect(js, contains("window.location.href='https://example.com/page'"));
    });

    test('empty URL produces void 0', () {
      final js = builder.build(action(ActionType.navigate, url: ''));
      expect(js.trim(), equals('void 0;'));
    });

    test('null URL produces void 0', () {
      final js = builder.build(action(ActionType.navigate));
      expect(js.trim(), equals('void 0;'));
    });
  });

  // ── wait ──────────────────────────────────────────────────────────────────

  group('wait', () {
    test('returns void 0 (wait is handled in Dart, not JS)', () {
      final js = builder.build(action(ActionType.wait, waitMs: 2000));
      expect(js.trim(), equals('void 0;'));
    });
  });

  // ── pressKey ──────────────────────────────────────────────────────────────

  group('pressKey', () {
    test('Enter key uses keyCode 13', () {
      final js = builder.build(action(ActionType.pressKey, key: 'Enter'));
      expect(js, contains('keyCode:13'));
      expect(js, contains("key:'Enter'"));
    });

    test('Tab key uses keyCode 9', () {
      final js = builder.build(action(ActionType.pressKey, key: 'Tab'));
      expect(js, contains('keyCode:9'));
    });

    test('Escape key uses keyCode 27', () {
      final js = builder.build(action(ActionType.pressKey, key: 'Escape'));
      expect(js, contains('keyCode:27'));
    });

    test('ArrowDown key uses keyCode 40', () {
      final js = builder.build(action(ActionType.pressKey, key: 'ArrowDown'));
      expect(js, contains('keyCode:40'));
    });

    test('Space key uses keyCode 32', () {
      final js = builder.build(action(ActionType.pressKey, key: 'Space'));
      expect(js, contains('keyCode:32'));
    });

    test('F12 key uses keyCode 123', () {
      final js = builder.build(action(ActionType.pressKey, key: 'F12'));
      expect(js, contains('keyCode:123'));
    });

    test('single character key uses char code', () {
      // 'A' = char code 65
      final js = builder.build(action(ActionType.pressKey, key: 'a'));
      expect(js, contains('keyCode:65'));
    });

    test('unknown multi-char key uses keyCode 0', () {
      final js = builder.build(action(ActionType.pressKey, key: 'FnLock'));
      expect(js, contains('keyCode:0'));
    });

    test('fires keydown, keypress, and keyup events', () {
      final js = builder.build(action(ActionType.pressKey, key: 'Enter'));
      expect(js, contains("KeyboardEvent('keydown'"));
      expect(js, contains("KeyboardEvent('keypress'"));
      expect(js, contains("KeyboardEvent('keyup'"));
    });

    test('dispatches on document.activeElement', () {
      final js = builder.build(action(ActionType.pressKey, key: 'Enter'));
      expect(js, contains('document.activeElement'));
    });
  });

  // ── selectOption ──────────────────────────────────────────────────────────

  group('selectOption', () {
    test('sets value and dispatches change and input events', () {
      final js = builder.build(action(
        ActionType.selectOption,
        cssSelector: '#country',
        value: 'UK',
      ));
      expect(js, contains("querySelector('#country')"));
      expect(js, contains("el.value='UK'"));
      expect(js, contains("Event('change'"));
      expect(js, contains("Event('input'"));
    });
  });

  // ── assert_text ───────────────────────────────────────────────────────────

  group('assert_text', () {
    test('checks body innerText (case-insensitive)', () {
      final js = builder.build(
          action(ActionType.assert_text, expectedText: 'Welcome'));
      expect(js, contains('document.body.innerText.toLowerCase()'));
      expect(js, contains("includes('welcome')"));
    });

    test('lowercases expected text', () {
      final js = builder.build(
          action(ActionType.assert_text, expectedText: 'Hello World'));
      expect(js, contains("includes('hello world')"));
    });

    test('empty expected text includes empty string (always true)', () {
      final js =
          builder.build(action(ActionType.assert_text, expectedText: ''));
      expect(js, contains("includes('')"));
    });
  });

  // ── assert_url ────────────────────────────────────────────────────────────

  group('assert_url', () {
    test('checks window.location.href contains pattern', () {
      final js = builder.build(
          action(ActionType.assert_url, expectedUrl: '/dashboard'));
      expect(js, contains("window.location.href.includes('/dashboard')"));
    });

    test('null expectedUrl checks for empty string', () {
      final js = builder.build(action(ActionType.assert_url));
      expect(js, contains("window.location.href.includes('')"));
    });
  });

  // ── assert_visible ────────────────────────────────────────────────────────

  group('assert_visible', () {
    test('with selector — checks getBoundingClientRect', () {
      final js = builder.build(
          action(ActionType.assert_visible, cssSelector: '.modal'));
      expect(js, contains("querySelector('.modal')"));
      expect(js, contains('getBoundingClientRect'));
      expect(js, contains('r.width > 0'));
      expect(js, contains('r.top < window.innerHeight'));
    });

    test('without selector — returns true (cannot verify)', () {
      final js = builder.build(action(ActionType.assert_visible));
      expect(js.trim(), equals('true'));
    });
  });

  // ── done / fail / longPress ───────────────────────────────────────────────

  group('terminal actions', () {
    test('done returns void 0', () {
      final js = builder.build(action(ActionType.done));
      expect(js.trim(), equals('void 0;'));
    });

    test('fail returns void 0', () {
      final js = builder.build(action(ActionType.fail));
      expect(js.trim(), equals('void 0;'));
    });

    test('longPress returns void 0 (handled by CDP in WebViewService)', () {
      final js = builder.build(action(ActionType.longPress, x: 10, y: 10));
      expect(js.trim(), equals('void 0;'));
    });
  });

  // ── _esc helper (tested indirectly via type) ──────────────────────────────

  group('string escaping (_esc)', () {
    test('single quotes in selector are escaped', () {
      final js = builder.build(
          action(ActionType.click, cssSelector: "div[data-v='x']"));
      expect(js, contains(r"div[data-v=\'x\']"));
    });

    test('backslashes in value are escaped', () {
      final js = builder.build(
          action(ActionType.type, cssSelector: '#f', value: r'C:\Users'));
      expect(js, contains(r'C:\\Users'));
    });

    test('CSS selector with shadow DOM fallback contains loop', () {
      final js = builder.build(
          action(ActionType.click, cssSelector: '#deep-button'));
      expect(js, contains('shadowRoot'));
    });
  });
}
