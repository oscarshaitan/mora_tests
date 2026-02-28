// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'http_hook.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HttpHook {

 String get url; String get method; Map<String, String> get headers; String? get body; int get timeoutSeconds;
/// Create a copy of HttpHook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HttpHookCopyWith<HttpHook> get copyWith => _$HttpHookCopyWithImpl<HttpHook>(this as HttpHook, _$identity);

  /// Serializes this HttpHook to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HttpHook&&(identical(other.url, url) || other.url == url)&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other.headers, headers)&&(identical(other.body, body) || other.body == body)&&(identical(other.timeoutSeconds, timeoutSeconds) || other.timeoutSeconds == timeoutSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,method,const DeepCollectionEquality().hash(headers),body,timeoutSeconds);

@override
String toString() {
  return 'HttpHook(url: $url, method: $method, headers: $headers, body: $body, timeoutSeconds: $timeoutSeconds)';
}


}

/// @nodoc
abstract mixin class $HttpHookCopyWith<$Res>  {
  factory $HttpHookCopyWith(HttpHook value, $Res Function(HttpHook) _then) = _$HttpHookCopyWithImpl;
@useResult
$Res call({
 String url, String method, Map<String, String> headers, String? body, int timeoutSeconds
});




}
/// @nodoc
class _$HttpHookCopyWithImpl<$Res>
    implements $HttpHookCopyWith<$Res> {
  _$HttpHookCopyWithImpl(this._self, this._then);

  final HttpHook _self;
  final $Res Function(HttpHook) _then;

/// Create a copy of HttpHook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? method = null,Object? headers = null,Object? body = freezed,Object? timeoutSeconds = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,timeoutSeconds: null == timeoutSeconds ? _self.timeoutSeconds : timeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HttpHook].
extension HttpHookPatterns on HttpHook {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HttpHook value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HttpHook() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HttpHook value)  $default,){
final _that = this;
switch (_that) {
case _HttpHook():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HttpHook value)?  $default,){
final _that = this;
switch (_that) {
case _HttpHook() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String method,  Map<String, String> headers,  String? body,  int timeoutSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HttpHook() when $default != null:
return $default(_that.url,_that.method,_that.headers,_that.body,_that.timeoutSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String method,  Map<String, String> headers,  String? body,  int timeoutSeconds)  $default,) {final _that = this;
switch (_that) {
case _HttpHook():
return $default(_that.url,_that.method,_that.headers,_that.body,_that.timeoutSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String method,  Map<String, String> headers,  String? body,  int timeoutSeconds)?  $default,) {final _that = this;
switch (_that) {
case _HttpHook() when $default != null:
return $default(_that.url,_that.method,_that.headers,_that.body,_that.timeoutSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HttpHook implements HttpHook {
  const _HttpHook({required this.url, this.method = 'POST', final  Map<String, String> headers = const {}, this.body, this.timeoutSeconds = 10}): _headers = headers;
  factory _HttpHook.fromJson(Map<String, dynamic> json) => _$HttpHookFromJson(json);

@override final  String url;
@override@JsonKey() final  String method;
 final  Map<String, String> _headers;
@override@JsonKey() Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}

@override final  String? body;
@override@JsonKey() final  int timeoutSeconds;

/// Create a copy of HttpHook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HttpHookCopyWith<_HttpHook> get copyWith => __$HttpHookCopyWithImpl<_HttpHook>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HttpHookToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HttpHook&&(identical(other.url, url) || other.url == url)&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other._headers, _headers)&&(identical(other.body, body) || other.body == body)&&(identical(other.timeoutSeconds, timeoutSeconds) || other.timeoutSeconds == timeoutSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,method,const DeepCollectionEquality().hash(_headers),body,timeoutSeconds);

@override
String toString() {
  return 'HttpHook(url: $url, method: $method, headers: $headers, body: $body, timeoutSeconds: $timeoutSeconds)';
}


}

/// @nodoc
abstract mixin class _$HttpHookCopyWith<$Res> implements $HttpHookCopyWith<$Res> {
  factory _$HttpHookCopyWith(_HttpHook value, $Res Function(_HttpHook) _then) = __$HttpHookCopyWithImpl;
@override @useResult
$Res call({
 String url, String method, Map<String, String> headers, String? body, int timeoutSeconds
});




}
/// @nodoc
class __$HttpHookCopyWithImpl<$Res>
    implements _$HttpHookCopyWith<$Res> {
  __$HttpHookCopyWithImpl(this._self, this._then);

  final _HttpHook _self;
  final $Res Function(_HttpHook) _then;

/// Create a copy of HttpHook
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? method = null,Object? headers = null,Object? body = freezed,Object? timeoutSeconds = null,}) {
  return _then(_HttpHook(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,timeoutSeconds: null == timeoutSeconds ? _self.timeoutSeconds : timeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
