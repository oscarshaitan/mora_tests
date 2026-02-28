// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'llm_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LlmAction {

 ActionType get type; String? get cssSelector; String? get xpathSelector; double? get x; double? get y; String? get value; String? get url; String? get key; int? get scrollDeltaX; int? get scrollDeltaY; int? get waitMs; String? get expectedText; String? get expectedUrl; double get confidence; String get reasoning;
/// Create a copy of LlmAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LlmActionCopyWith<LlmAction> get copyWith => _$LlmActionCopyWithImpl<LlmAction>(this as LlmAction, _$identity);

  /// Serializes this LlmAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LlmAction&&(identical(other.type, type) || other.type == type)&&(identical(other.cssSelector, cssSelector) || other.cssSelector == cssSelector)&&(identical(other.xpathSelector, xpathSelector) || other.xpathSelector == xpathSelector)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.value, value) || other.value == value)&&(identical(other.url, url) || other.url == url)&&(identical(other.key, key) || other.key == key)&&(identical(other.scrollDeltaX, scrollDeltaX) || other.scrollDeltaX == scrollDeltaX)&&(identical(other.scrollDeltaY, scrollDeltaY) || other.scrollDeltaY == scrollDeltaY)&&(identical(other.waitMs, waitMs) || other.waitMs == waitMs)&&(identical(other.expectedText, expectedText) || other.expectedText == expectedText)&&(identical(other.expectedUrl, expectedUrl) || other.expectedUrl == expectedUrl)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,cssSelector,xpathSelector,x,y,value,url,key,scrollDeltaX,scrollDeltaY,waitMs,expectedText,expectedUrl,confidence,reasoning);

@override
String toString() {
  return 'LlmAction(type: $type, cssSelector: $cssSelector, xpathSelector: $xpathSelector, x: $x, y: $y, value: $value, url: $url, key: $key, scrollDeltaX: $scrollDeltaX, scrollDeltaY: $scrollDeltaY, waitMs: $waitMs, expectedText: $expectedText, expectedUrl: $expectedUrl, confidence: $confidence, reasoning: $reasoning)';
}


}

/// @nodoc
abstract mixin class $LlmActionCopyWith<$Res>  {
  factory $LlmActionCopyWith(LlmAction value, $Res Function(LlmAction) _then) = _$LlmActionCopyWithImpl;
@useResult
$Res call({
 ActionType type, String? cssSelector, String? xpathSelector, double? x, double? y, String? value, String? url, String? key, int? scrollDeltaX, int? scrollDeltaY, int? waitMs, String? expectedText, String? expectedUrl, double confidence, String reasoning
});




}
/// @nodoc
class _$LlmActionCopyWithImpl<$Res>
    implements $LlmActionCopyWith<$Res> {
  _$LlmActionCopyWithImpl(this._self, this._then);

  final LlmAction _self;
  final $Res Function(LlmAction) _then;

/// Create a copy of LlmAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? cssSelector = freezed,Object? xpathSelector = freezed,Object? x = freezed,Object? y = freezed,Object? value = freezed,Object? url = freezed,Object? key = freezed,Object? scrollDeltaX = freezed,Object? scrollDeltaY = freezed,Object? waitMs = freezed,Object? expectedText = freezed,Object? expectedUrl = freezed,Object? confidence = null,Object? reasoning = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActionType,cssSelector: freezed == cssSelector ? _self.cssSelector : cssSelector // ignore: cast_nullable_to_non_nullable
as String?,xpathSelector: freezed == xpathSelector ? _self.xpathSelector : xpathSelector // ignore: cast_nullable_to_non_nullable
as String?,x: freezed == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double?,y: freezed == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,scrollDeltaX: freezed == scrollDeltaX ? _self.scrollDeltaX : scrollDeltaX // ignore: cast_nullable_to_non_nullable
as int?,scrollDeltaY: freezed == scrollDeltaY ? _self.scrollDeltaY : scrollDeltaY // ignore: cast_nullable_to_non_nullable
as int?,waitMs: freezed == waitMs ? _self.waitMs : waitMs // ignore: cast_nullable_to_non_nullable
as int?,expectedText: freezed == expectedText ? _self.expectedText : expectedText // ignore: cast_nullable_to_non_nullable
as String?,expectedUrl: freezed == expectedUrl ? _self.expectedUrl : expectedUrl // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LlmAction].
extension LlmActionPatterns on LlmAction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LlmAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LlmAction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LlmAction value)  $default,){
final _that = this;
switch (_that) {
case _LlmAction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LlmAction value)?  $default,){
final _that = this;
switch (_that) {
case _LlmAction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ActionType type,  String? cssSelector,  String? xpathSelector,  double? x,  double? y,  String? value,  String? url,  String? key,  int? scrollDeltaX,  int? scrollDeltaY,  int? waitMs,  String? expectedText,  String? expectedUrl,  double confidence,  String reasoning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LlmAction() when $default != null:
return $default(_that.type,_that.cssSelector,_that.xpathSelector,_that.x,_that.y,_that.value,_that.url,_that.key,_that.scrollDeltaX,_that.scrollDeltaY,_that.waitMs,_that.expectedText,_that.expectedUrl,_that.confidence,_that.reasoning);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ActionType type,  String? cssSelector,  String? xpathSelector,  double? x,  double? y,  String? value,  String? url,  String? key,  int? scrollDeltaX,  int? scrollDeltaY,  int? waitMs,  String? expectedText,  String? expectedUrl,  double confidence,  String reasoning)  $default,) {final _that = this;
switch (_that) {
case _LlmAction():
return $default(_that.type,_that.cssSelector,_that.xpathSelector,_that.x,_that.y,_that.value,_that.url,_that.key,_that.scrollDeltaX,_that.scrollDeltaY,_that.waitMs,_that.expectedText,_that.expectedUrl,_that.confidence,_that.reasoning);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ActionType type,  String? cssSelector,  String? xpathSelector,  double? x,  double? y,  String? value,  String? url,  String? key,  int? scrollDeltaX,  int? scrollDeltaY,  int? waitMs,  String? expectedText,  String? expectedUrl,  double confidence,  String reasoning)?  $default,) {final _that = this;
switch (_that) {
case _LlmAction() when $default != null:
return $default(_that.type,_that.cssSelector,_that.xpathSelector,_that.x,_that.y,_that.value,_that.url,_that.key,_that.scrollDeltaX,_that.scrollDeltaY,_that.waitMs,_that.expectedText,_that.expectedUrl,_that.confidence,_that.reasoning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LlmAction implements LlmAction {
  const _LlmAction({required this.type, this.cssSelector, this.xpathSelector, this.x, this.y, this.value, this.url, this.key, this.scrollDeltaX, this.scrollDeltaY, this.waitMs, this.expectedText, this.expectedUrl, this.confidence = 1.0, this.reasoning = ''});
  factory _LlmAction.fromJson(Map<String, dynamic> json) => _$LlmActionFromJson(json);

@override final  ActionType type;
@override final  String? cssSelector;
@override final  String? xpathSelector;
@override final  double? x;
@override final  double? y;
@override final  String? value;
@override final  String? url;
@override final  String? key;
@override final  int? scrollDeltaX;
@override final  int? scrollDeltaY;
@override final  int? waitMs;
@override final  String? expectedText;
@override final  String? expectedUrl;
@override@JsonKey() final  double confidence;
@override@JsonKey() final  String reasoning;

/// Create a copy of LlmAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LlmActionCopyWith<_LlmAction> get copyWith => __$LlmActionCopyWithImpl<_LlmAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LlmActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LlmAction&&(identical(other.type, type) || other.type == type)&&(identical(other.cssSelector, cssSelector) || other.cssSelector == cssSelector)&&(identical(other.xpathSelector, xpathSelector) || other.xpathSelector == xpathSelector)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.value, value) || other.value == value)&&(identical(other.url, url) || other.url == url)&&(identical(other.key, key) || other.key == key)&&(identical(other.scrollDeltaX, scrollDeltaX) || other.scrollDeltaX == scrollDeltaX)&&(identical(other.scrollDeltaY, scrollDeltaY) || other.scrollDeltaY == scrollDeltaY)&&(identical(other.waitMs, waitMs) || other.waitMs == waitMs)&&(identical(other.expectedText, expectedText) || other.expectedText == expectedText)&&(identical(other.expectedUrl, expectedUrl) || other.expectedUrl == expectedUrl)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,cssSelector,xpathSelector,x,y,value,url,key,scrollDeltaX,scrollDeltaY,waitMs,expectedText,expectedUrl,confidence,reasoning);

@override
String toString() {
  return 'LlmAction(type: $type, cssSelector: $cssSelector, xpathSelector: $xpathSelector, x: $x, y: $y, value: $value, url: $url, key: $key, scrollDeltaX: $scrollDeltaX, scrollDeltaY: $scrollDeltaY, waitMs: $waitMs, expectedText: $expectedText, expectedUrl: $expectedUrl, confidence: $confidence, reasoning: $reasoning)';
}


}

/// @nodoc
abstract mixin class _$LlmActionCopyWith<$Res> implements $LlmActionCopyWith<$Res> {
  factory _$LlmActionCopyWith(_LlmAction value, $Res Function(_LlmAction) _then) = __$LlmActionCopyWithImpl;
@override @useResult
$Res call({
 ActionType type, String? cssSelector, String? xpathSelector, double? x, double? y, String? value, String? url, String? key, int? scrollDeltaX, int? scrollDeltaY, int? waitMs, String? expectedText, String? expectedUrl, double confidence, String reasoning
});




}
/// @nodoc
class __$LlmActionCopyWithImpl<$Res>
    implements _$LlmActionCopyWith<$Res> {
  __$LlmActionCopyWithImpl(this._self, this._then);

  final _LlmAction _self;
  final $Res Function(_LlmAction) _then;

/// Create a copy of LlmAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? cssSelector = freezed,Object? xpathSelector = freezed,Object? x = freezed,Object? y = freezed,Object? value = freezed,Object? url = freezed,Object? key = freezed,Object? scrollDeltaX = freezed,Object? scrollDeltaY = freezed,Object? waitMs = freezed,Object? expectedText = freezed,Object? expectedUrl = freezed,Object? confidence = null,Object? reasoning = null,}) {
  return _then(_LlmAction(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActionType,cssSelector: freezed == cssSelector ? _self.cssSelector : cssSelector // ignore: cast_nullable_to_non_nullable
as String?,xpathSelector: freezed == xpathSelector ? _self.xpathSelector : xpathSelector // ignore: cast_nullable_to_non_nullable
as String?,x: freezed == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double?,y: freezed == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,scrollDeltaX: freezed == scrollDeltaX ? _self.scrollDeltaX : scrollDeltaX // ignore: cast_nullable_to_non_nullable
as int?,scrollDeltaY: freezed == scrollDeltaY ? _self.scrollDeltaY : scrollDeltaY // ignore: cast_nullable_to_non_nullable
as int?,waitMs: freezed == waitMs ? _self.waitMs : waitMs // ignore: cast_nullable_to_non_nullable
as int?,expectedText: freezed == expectedText ? _self.expectedText : expectedText // ignore: cast_nullable_to_non_nullable
as String?,expectedUrl: freezed == expectedUrl ? _self.expectedUrl : expectedUrl // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
