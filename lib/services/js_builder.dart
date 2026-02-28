import '../models/llm_action.dart';

/// Generates JavaScript strings for each [ActionType] to be injected
/// into the embedded WebView via evaluateJavascript().
class JsBuilder {
  String build(LlmAction action) {
    final sel = _esc(action.cssSelector ?? '');
    final xp = _esc(action.xpathSelector ?? '');
    final val = _esc(action.value ?? '');
    final key = _esc(action.key ?? '');

    switch (action.type) {
      case ActionType.click:
        return _clickJs(sel, xp, action.x, action.y, isDouble: false);

      case ActionType.doubleClick:
        return _clickJs(sel, xp, action.x, action.y, isDouble: true);

      case ActionType.hover:
        if (sel.isNotEmpty) {
          return """
(function(){
  var el = document.querySelector('$sel');
  if(!el) return;
  var rect = el.getBoundingClientRect();
  var cx = rect.left + rect.width/2, cy = rect.top + rect.height/2;
  var opts = {bubbles:true,cancelable:true,composed:true,view:window,clientX:cx,clientY:cy};
  el.dispatchEvent(new MouseEvent('mouseover', opts));
  el.dispatchEvent(new MouseEvent('mouseenter', opts));
})();""";
        }
        return "document.elementFromPoint(${action.x ?? 0},${action.y ?? 0})?.dispatchEvent(new MouseEvent('mouseover',{bubbles:true,composed:true,view:window}));";

      case ActionType.type:
        if (sel.isNotEmpty) {
          return _typeJs(sel, val);
        } else if (xp.isNotEmpty) {
          return _typeJsXpath(xp, val);
        }
        // Fallback: type into currently focused element
        return _typeJsActiveElement(val);

      case ActionType.scroll:
        final dx = action.scrollDeltaX ?? 0;
        final dy = action.scrollDeltaY ?? 300;
        if (sel.isNotEmpty) {
          return """
(function(){
  var el = document.querySelector('$sel');
  if(el){ el.scrollBy($dx,$dy); } else { window.scrollBy($dx,$dy); }
})();""";
        }
        return 'window.scrollBy($dx,$dy);';

      case ActionType.navigate:
        final url = _esc(action.url ?? '');
        return url.isNotEmpty ? "window.location.href='$url';" : 'void 0;';

      case ActionType.wait:
        // Handled in Dart via Future.delayed — JS no-op
        return 'void 0;';

      case ActionType.pressKey:
        final kc = _keyCode(action.key ?? '');
        return """
(function(){
  var opts = {key:'$key',code:'$key',keyCode:$kc,which:$kc,bubbles:true,cancelable:true,composed:true};
  document.activeElement.dispatchEvent(new KeyboardEvent('keydown', opts));
  document.activeElement.dispatchEvent(new KeyboardEvent('keypress', opts));
  document.activeElement.dispatchEvent(new KeyboardEvent('keyup', opts));
})();""";

      case ActionType.selectOption:
        return """
(function(){
  var el = document.querySelector('$sel');
  if(!el) return;
  el.value='$val';
  el.dispatchEvent(new Event('change',{bubbles:true}));
  el.dispatchEvent(new Event('input',{bubbles:true}));
})();""";

      case ActionType.assert_text:
        final expected = _esc((action.expectedText ?? '').toLowerCase());
        return "document.body.innerText.toLowerCase().includes('$expected')";

      case ActionType.assert_url:
        final expected = _esc(action.expectedUrl ?? '');
        return "window.location.href.includes('$expected')";

      case ActionType.assert_visible:
        if (sel.isNotEmpty) {
          return """
(function(){
  var el = document.querySelector('$sel');
  if(!el) return false;
  var r = el.getBoundingClientRect();
  return r.width > 0 && r.height > 0 && r.top < window.innerHeight && r.bottom > 0;
})()""";
        }
        return 'true';

      case ActionType.longPress:
      case ActionType.done:
      case ActionType.fail:
        return 'void 0;';
    }
  }

  // ── Click / DoubleClick ──────────────────────────────────────────────────────

  String _clickJs(
    String sel,
    String xp,
    double? x,
    double? y, {
    required bool isDouble,
  }) {
    if (sel.isNotEmpty) {
      return _clickBySelector(sel, isDouble: isDouble);
    } else if (xp.isNotEmpty) {
      return _clickByXpath(xp, isDouble: isDouble);
    } else if (x != null && y != null) {
      return _clickByCoords(x, y, isDouble: isDouble);
    }
    return 'void 0;';
  }

  /// Fires the full pointer+mouse event sequence on a CSS-selected element.
  /// Returns a string describing the outcome so we can log it.
  String _clickBySelector(String sel, {required bool isDouble}) {
    final body = _clickEventSequence(isDouble: isDouble);
    return """
(function(){
  // Standard querySelector
  var el = document.querySelector('$sel');
  // Shadow DOM piercing fallback: walk all shadow roots
  if(!el){
    var all = document.querySelectorAll('*');
    for(var i=0;i<all.length;i++){
      if(all[i].shadowRoot){
        var found=all[i].shadowRoot.querySelector('$sel');
        if(found){el=found;break;}
      }
    }
  }
  if(!el) return 'NOT_FOUND:$sel';
  el.scrollIntoView({block:'nearest',inline:'nearest'});
  var rect = el.getBoundingClientRect();
  var cx = rect.left + rect.width/2, cy = rect.top + rect.height/2;
  var opts = {bubbles:true,cancelable:true,composed:true,view:window,clientX:cx,clientY:cy};
  $body
  return 'OK tag='+el.tagName+' cx='+Math.round(cx)+' cy='+Math.round(cy);
})();""";
  }

  String _clickByXpath(String xp, {required bool isDouble}) {
    final body = _clickEventSequence(isDouble: isDouble);
    return """
(function(){
  var el = document.evaluate('$xp',document,null,XPathResult.FIRST_ORDERED_NODE_TYPE,null).singleNodeValue;
  if(!el) return 'NOT_FOUND_XPATH:$xp';
  el.scrollIntoView({block:'nearest',inline:'nearest'});
  var rect = el.getBoundingClientRect();
  var cx = rect.left + rect.width/2, cy = rect.top + rect.height/2;
  var opts = {bubbles:true,cancelable:true,composed:true,view:window,clientX:cx,clientY:cy};
  $body
  return 'OK tag='+el.tagName+' cx='+Math.round(cx)+' cy='+Math.round(cy);
})();""";
  }

  String _clickByCoords(double x, double y, {required bool isDouble}) {
    final body = _clickEventSequence(isDouble: isDouble);
    return """
(function(){
  var el = document.elementFromPoint($x,$y);
  if(!el) return 'NOT_FOUND_AT:$x,$y';
  var opts = {bubbles:true,cancelable:true,composed:true,view:window,clientX:$x,clientY:$y};
  $body
  return 'OK tag='+el.tagName;
})();""";
  }

  /// Generates the event dispatch sequence (pointer+mouse) that goes inside
  /// an IIFE where `el` and `opts` are already defined.
  String _clickEventSequence({required bool isDouble}) {
    if (isDouble) {
      return """
  el.dispatchEvent(new PointerEvent('pointerdown',opts));
  el.dispatchEvent(new MouseEvent('mousedown',opts));
  el.dispatchEvent(new PointerEvent('pointerup',opts));
  el.dispatchEvent(new MouseEvent('mouseup',opts));
  el.dispatchEvent(new MouseEvent('click',opts));
  el.dispatchEvent(new PointerEvent('pointerdown',opts));
  el.dispatchEvent(new MouseEvent('mousedown',opts));
  el.dispatchEvent(new PointerEvent('pointerup',opts));
  el.dispatchEvent(new MouseEvent('mouseup',opts));
  el.dispatchEvent(new MouseEvent('click',opts));
  el.dispatchEvent(new MouseEvent('dblclick',opts));""";
    }
    return """
  el.dispatchEvent(new PointerEvent('pointerdown',opts));
  el.dispatchEvent(new MouseEvent('mousedown',opts));
  el.dispatchEvent(new PointerEvent('pointerup',opts));
  el.dispatchEvent(new MouseEvent('mouseup',opts));
  el.dispatchEvent(new MouseEvent('click',opts));
  el.click();""";
  }

  // ── Type ────────────────────────────────────────────────────────────────────

  String _typeJs(String sel, String val) {
    return """
(function(){
  var el = document.querySelector('$sel');
  if(!el) return;
  el.focus();
  if(el.isContentEditable){
    el.textContent='$val';
    var range=document.createRange();
    range.selectNodeContents(el);
    range.collapse(false);
    var sel=window.getSelection();
    sel.removeAllRanges();
    sel.addRange(range);
  } else {
    var inSetter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value')?.set
      ||Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype,'value')?.set;
    if(inSetter){ inSetter.call(el,'$val'); }
    else { el.value='$val'; }
  }
  el.dispatchEvent(new KeyboardEvent('keydown',{bubbles:true,cancelable:true,key:'a',keyCode:65,which:65}));
  el.dispatchEvent(new Event('input',{bubbles:true}));
  el.dispatchEvent(new Event('change',{bubbles:true}));
})();""";
  }

  String _typeJsXpath(String xp, String val) {
    return """
(function(){
  var el=document.evaluate('$xp',document,null,XPathResult.FIRST_ORDERED_NODE_TYPE,null).singleNodeValue;
  if(!el) return;
  el.focus();
  if(el.isContentEditable){
    el.textContent='$val';
  } else {
    var inSetter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value')?.set
      ||Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype,'value')?.set;
    if(inSetter){ inSetter.call(el,'$val'); }
    else { el.value='$val'; }
  }
  el.dispatchEvent(new Event('input',{bubbles:true}));
  el.dispatchEvent(new Event('change',{bubbles:true}));
})();""";
  }

  String _typeJsActiveElement(String val) {
    return """
(function(){
  var el=document.activeElement;
  if(!el||el===document.body) return;
  if(el.isContentEditable){
    el.textContent='$val';
  } else {
    var inSetter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value')?.set
      ||Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype,'value')?.set;
    if(inSetter){ inSetter.call(el,'$val'); }
    else if('value' in el){ el.value='$val'; }
  }
  el.dispatchEvent(new Event('input',{bubbles:true}));
  el.dispatchEvent(new Event('change',{bubbles:true}));
})();""";
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Maps common key names to their legacy keyCode values.
  /// Required by many older frameworks that still read event.keyCode.
  int _keyCode(String key) {
    const map = {
      'Enter': 13,
      'Return': 13,
      'Tab': 9,
      'Escape': 27,
      'Esc': 27,
      'Space': 32,
      ' ': 32,
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
      'F1': 112,
      'F2': 113,
      'F3': 114,
      'F4': 115,
      'F5': 116,
      'F12': 123,
    };
    if (map.containsKey(key)) return map[key]!;
    // Single character keys: use char code
    if (key.length == 1) return key.toUpperCase().codeUnitAt(0);
    return 0;
  }

  /// Escape single quotes and backslashes for safe inline JS string literals.
  String _esc(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
}
