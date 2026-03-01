// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

 String get llmBaseUrl; String get llmApiKey; String get llmModel; String get llmFallbackModel; bool get browserHeadless; double get confidenceThreshold;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.llmBaseUrl, llmBaseUrl) || other.llmBaseUrl == llmBaseUrl)&&(identical(other.llmApiKey, llmApiKey) || other.llmApiKey == llmApiKey)&&(identical(other.llmModel, llmModel) || other.llmModel == llmModel)&&(identical(other.llmFallbackModel, llmFallbackModel) || other.llmFallbackModel == llmFallbackModel)&&(identical(other.browserHeadless, browserHeadless) || other.browserHeadless == browserHeadless)&&(identical(other.confidenceThreshold, confidenceThreshold) || other.confidenceThreshold == confidenceThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,llmBaseUrl,llmApiKey,llmModel,llmFallbackModel,browserHeadless,confidenceThreshold);

@override
String toString() {
  return 'AppSettings(llmBaseUrl: $llmBaseUrl, llmApiKey: $llmApiKey, llmModel: $llmModel, llmFallbackModel: $llmFallbackModel, browserHeadless: $browserHeadless, confidenceThreshold: $confidenceThreshold)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 String llmBaseUrl, String llmApiKey, String llmModel, String llmFallbackModel, bool browserHeadless, double confidenceThreshold
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? llmBaseUrl = null,Object? llmApiKey = null,Object? llmModel = null,Object? llmFallbackModel = null,Object? browserHeadless = null,Object? confidenceThreshold = null,}) {
  return _then(_self.copyWith(
llmBaseUrl: null == llmBaseUrl ? _self.llmBaseUrl : llmBaseUrl // ignore: cast_nullable_to_non_nullable
as String,llmApiKey: null == llmApiKey ? _self.llmApiKey : llmApiKey // ignore: cast_nullable_to_non_nullable
as String,llmModel: null == llmModel ? _self.llmModel : llmModel // ignore: cast_nullable_to_non_nullable
as String,llmFallbackModel: null == llmFallbackModel ? _self.llmFallbackModel : llmFallbackModel // ignore: cast_nullable_to_non_nullable
as String,browserHeadless: null == browserHeadless ? _self.browserHeadless : browserHeadless // ignore: cast_nullable_to_non_nullable
as bool,confidenceThreshold: null == confidenceThreshold ? _self.confidenceThreshold : confidenceThreshold // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String llmBaseUrl,  String llmApiKey,  String llmModel,  String llmFallbackModel,  bool browserHeadless,  double confidenceThreshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.llmBaseUrl,_that.llmApiKey,_that.llmModel,_that.llmFallbackModel,_that.browserHeadless,_that.confidenceThreshold);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String llmBaseUrl,  String llmApiKey,  String llmModel,  String llmFallbackModel,  bool browserHeadless,  double confidenceThreshold)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.llmBaseUrl,_that.llmApiKey,_that.llmModel,_that.llmFallbackModel,_that.browserHeadless,_that.confidenceThreshold);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String llmBaseUrl,  String llmApiKey,  String llmModel,  String llmFallbackModel,  bool browserHeadless,  double confidenceThreshold)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.llmBaseUrl,_that.llmApiKey,_that.llmModel,_that.llmFallbackModel,_that.browserHeadless,_that.confidenceThreshold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings implements AppSettings {
  const _AppSettings({this.llmBaseUrl = AppConstants.defaultLlmBaseUrl, this.llmApiKey = '', this.llmModel = AppConstants.defaultLlmModel, this.llmFallbackModel = AppConstants.mistralModel, this.browserHeadless = false, this.confidenceThreshold = 0.5});
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override@JsonKey() final  String llmBaseUrl;
@override@JsonKey() final  String llmApiKey;
@override@JsonKey() final  String llmModel;
@override@JsonKey() final  String llmFallbackModel;
@override@JsonKey() final  bool browserHeadless;
@override@JsonKey() final  double confidenceThreshold;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.llmBaseUrl, llmBaseUrl) || other.llmBaseUrl == llmBaseUrl)&&(identical(other.llmApiKey, llmApiKey) || other.llmApiKey == llmApiKey)&&(identical(other.llmModel, llmModel) || other.llmModel == llmModel)&&(identical(other.llmFallbackModel, llmFallbackModel) || other.llmFallbackModel == llmFallbackModel)&&(identical(other.browserHeadless, browserHeadless) || other.browserHeadless == browserHeadless)&&(identical(other.confidenceThreshold, confidenceThreshold) || other.confidenceThreshold == confidenceThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,llmBaseUrl,llmApiKey,llmModel,llmFallbackModel,browserHeadless,confidenceThreshold);

@override
String toString() {
  return 'AppSettings(llmBaseUrl: $llmBaseUrl, llmApiKey: $llmApiKey, llmModel: $llmModel, llmFallbackModel: $llmFallbackModel, browserHeadless: $browserHeadless, confidenceThreshold: $confidenceThreshold)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 String llmBaseUrl, String llmApiKey, String llmModel, String llmFallbackModel, bool browserHeadless, double confidenceThreshold
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? llmBaseUrl = null,Object? llmApiKey = null,Object? llmModel = null,Object? llmFallbackModel = null,Object? browserHeadless = null,Object? confidenceThreshold = null,}) {
  return _then(_AppSettings(
llmBaseUrl: null == llmBaseUrl ? _self.llmBaseUrl : llmBaseUrl // ignore: cast_nullable_to_non_nullable
as String,llmApiKey: null == llmApiKey ? _self.llmApiKey : llmApiKey // ignore: cast_nullable_to_non_nullable
as String,llmModel: null == llmModel ? _self.llmModel : llmModel // ignore: cast_nullable_to_non_nullable
as String,llmFallbackModel: null == llmFallbackModel ? _self.llmFallbackModel : llmFallbackModel // ignore: cast_nullable_to_non_nullable
as String,browserHeadless: null == browserHeadless ? _self.browserHeadless : browserHeadless // ignore: cast_nullable_to_non_nullable
as bool,confidenceThreshold: null == confidenceThreshold ? _self.confidenceThreshold : confidenceThreshold // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
