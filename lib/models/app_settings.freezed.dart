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

 String get activeProvider; String get ovhBaseUrl; String get ovhApiKey; String get ovhPrimaryModel; String get ovhFallbackModel; String get vertexAiBaseUrl; String get vertexAiApiKey; String get vertexAiPrimaryModel; String get vertexAiFallbackModel; bool get browserHeadless; double get confidenceThreshold;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.activeProvider, activeProvider) || other.activeProvider == activeProvider)&&(identical(other.ovhBaseUrl, ovhBaseUrl) || other.ovhBaseUrl == ovhBaseUrl)&&(identical(other.ovhApiKey, ovhApiKey) || other.ovhApiKey == ovhApiKey)&&(identical(other.ovhPrimaryModel, ovhPrimaryModel) || other.ovhPrimaryModel == ovhPrimaryModel)&&(identical(other.ovhFallbackModel, ovhFallbackModel) || other.ovhFallbackModel == ovhFallbackModel)&&(identical(other.vertexAiBaseUrl, vertexAiBaseUrl) || other.vertexAiBaseUrl == vertexAiBaseUrl)&&(identical(other.vertexAiApiKey, vertexAiApiKey) || other.vertexAiApiKey == vertexAiApiKey)&&(identical(other.vertexAiPrimaryModel, vertexAiPrimaryModel) || other.vertexAiPrimaryModel == vertexAiPrimaryModel)&&(identical(other.vertexAiFallbackModel, vertexAiFallbackModel) || other.vertexAiFallbackModel == vertexAiFallbackModel)&&(identical(other.browserHeadless, browserHeadless) || other.browserHeadless == browserHeadless)&&(identical(other.confidenceThreshold, confidenceThreshold) || other.confidenceThreshold == confidenceThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeProvider,ovhBaseUrl,ovhApiKey,ovhPrimaryModel,ovhFallbackModel,vertexAiBaseUrl,vertexAiApiKey,vertexAiPrimaryModel,vertexAiFallbackModel,browserHeadless,confidenceThreshold);

@override
String toString() {
  return 'AppSettings(activeProvider: $activeProvider, ovhBaseUrl: $ovhBaseUrl, ovhApiKey: $ovhApiKey, ovhPrimaryModel: $ovhPrimaryModel, ovhFallbackModel: $ovhFallbackModel, vertexAiBaseUrl: $vertexAiBaseUrl, vertexAiApiKey: $vertexAiApiKey, vertexAiPrimaryModel: $vertexAiPrimaryModel, vertexAiFallbackModel: $vertexAiFallbackModel, browserHeadless: $browserHeadless, confidenceThreshold: $confidenceThreshold)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 String activeProvider, String ovhBaseUrl, String ovhApiKey, String ovhPrimaryModel, String ovhFallbackModel, String vertexAiBaseUrl, String vertexAiApiKey, String vertexAiPrimaryModel, String vertexAiFallbackModel, bool browserHeadless, double confidenceThreshold
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
@pragma('vm:prefer-inline') @override $Res call({Object? activeProvider = null,Object? ovhBaseUrl = null,Object? ovhApiKey = null,Object? ovhPrimaryModel = null,Object? ovhFallbackModel = null,Object? vertexAiBaseUrl = null,Object? vertexAiApiKey = null,Object? vertexAiPrimaryModel = null,Object? vertexAiFallbackModel = null,Object? browserHeadless = null,Object? confidenceThreshold = null,}) {
  return _then(_self.copyWith(
activeProvider: null == activeProvider ? _self.activeProvider : activeProvider // ignore: cast_nullable_to_non_nullable
as String,ovhBaseUrl: null == ovhBaseUrl ? _self.ovhBaseUrl : ovhBaseUrl // ignore: cast_nullable_to_non_nullable
as String,ovhApiKey: null == ovhApiKey ? _self.ovhApiKey : ovhApiKey // ignore: cast_nullable_to_non_nullable
as String,ovhPrimaryModel: null == ovhPrimaryModel ? _self.ovhPrimaryModel : ovhPrimaryModel // ignore: cast_nullable_to_non_nullable
as String,ovhFallbackModel: null == ovhFallbackModel ? _self.ovhFallbackModel : ovhFallbackModel // ignore: cast_nullable_to_non_nullable
as String,vertexAiBaseUrl: null == vertexAiBaseUrl ? _self.vertexAiBaseUrl : vertexAiBaseUrl // ignore: cast_nullable_to_non_nullable
as String,vertexAiApiKey: null == vertexAiApiKey ? _self.vertexAiApiKey : vertexAiApiKey // ignore: cast_nullable_to_non_nullable
as String,vertexAiPrimaryModel: null == vertexAiPrimaryModel ? _self.vertexAiPrimaryModel : vertexAiPrimaryModel // ignore: cast_nullable_to_non_nullable
as String,vertexAiFallbackModel: null == vertexAiFallbackModel ? _self.vertexAiFallbackModel : vertexAiFallbackModel // ignore: cast_nullable_to_non_nullable
as String,browserHeadless: null == browserHeadless ? _self.browserHeadless : browserHeadless // ignore: cast_nullable_to_non_nullable
as bool,confidenceThreshold: null == confidenceThreshold ? _self.confidenceThreshold : confidenceThreshold // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
/// A variant of `map` that fallback to returning `orElse`.
@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String activeProvider,  String ovhBaseUrl,  String ovhApiKey,  String ovhPrimaryModel,  String ovhFallbackModel,  String vertexAiBaseUrl,  String vertexAiApiKey,  String vertexAiPrimaryModel,  String vertexAiFallbackModel,  bool browserHeadless,  double confidenceThreshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.activeProvider,_that.ovhBaseUrl,_that.ovhApiKey,_that.ovhPrimaryModel,_that.ovhFallbackModel,_that.vertexAiBaseUrl,_that.vertexAiApiKey,_that.vertexAiPrimaryModel,_that.vertexAiFallbackModel,_that.browserHeadless,_that.confidenceThreshold);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String activeProvider,  String ovhBaseUrl,  String ovhApiKey,  String ovhPrimaryModel,  String ovhFallbackModel,  String vertexAiBaseUrl,  String vertexAiApiKey,  String vertexAiPrimaryModel,  String vertexAiFallbackModel,  bool browserHeadless,  double confidenceThreshold)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.activeProvider,_that.ovhBaseUrl,_that.ovhApiKey,_that.ovhPrimaryModel,_that.ovhFallbackModel,_that.vertexAiBaseUrl,_that.vertexAiApiKey,_that.vertexAiPrimaryModel,_that.vertexAiFallbackModel,_that.browserHeadless,_that.confidenceThreshold);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String activeProvider,  String ovhBaseUrl,  String ovhApiKey,  String ovhPrimaryModel,  String ovhFallbackModel,  String vertexAiBaseUrl,  String vertexAiApiKey,  String vertexAiPrimaryModel,  String vertexAiFallbackModel,  bool browserHeadless,  double confidenceThreshold)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.activeProvider,_that.ovhBaseUrl,_that.ovhApiKey,_that.ovhPrimaryModel,_that.ovhFallbackModel,_that.vertexAiBaseUrl,_that.vertexAiApiKey,_that.vertexAiPrimaryModel,_that.vertexAiFallbackModel,_that.browserHeadless,_that.confidenceThreshold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings implements AppSettings {
  const _AppSettings({this.activeProvider = 'ovh', this.ovhBaseUrl = AppConstants.defaultLlmBaseUrl, this.ovhApiKey = '', this.ovhPrimaryModel = AppConstants.defaultLlmModel, this.ovhFallbackModel = AppConstants.mistralModel, this.vertexAiBaseUrl = AppConstants.vertexAiBaseUrl, this.vertexAiApiKey = '', this.vertexAiPrimaryModel = AppConstants.geminiFlashModel, this.vertexAiFallbackModel = AppConstants.geminiFlashLiteModel, this.browserHeadless = false, this.confidenceThreshold = 0.5});
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override@JsonKey() final  String activeProvider;
@override@JsonKey() final  String ovhBaseUrl;
@override@JsonKey() final  String ovhApiKey;
@override@JsonKey() final  String ovhPrimaryModel;
@override@JsonKey() final  String ovhFallbackModel;
@override@JsonKey() final  String vertexAiBaseUrl;
@override@JsonKey() final  String vertexAiApiKey;
@override@JsonKey() final  String vertexAiPrimaryModel;
@override@JsonKey() final  String vertexAiFallbackModel;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.activeProvider, activeProvider) || other.activeProvider == activeProvider)&&(identical(other.ovhBaseUrl, ovhBaseUrl) || other.ovhBaseUrl == ovhBaseUrl)&&(identical(other.ovhApiKey, ovhApiKey) || other.ovhApiKey == ovhApiKey)&&(identical(other.ovhPrimaryModel, ovhPrimaryModel) || other.ovhPrimaryModel == ovhPrimaryModel)&&(identical(other.ovhFallbackModel, ovhFallbackModel) || other.ovhFallbackModel == ovhFallbackModel)&&(identical(other.vertexAiBaseUrl, vertexAiBaseUrl) || other.vertexAiBaseUrl == vertexAiBaseUrl)&&(identical(other.vertexAiApiKey, vertexAiApiKey) || other.vertexAiApiKey == vertexAiApiKey)&&(identical(other.vertexAiPrimaryModel, vertexAiPrimaryModel) || other.vertexAiPrimaryModel == vertexAiPrimaryModel)&&(identical(other.vertexAiFallbackModel, vertexAiFallbackModel) || other.vertexAiFallbackModel == vertexAiFallbackModel)&&(identical(other.browserHeadless, browserHeadless) || other.browserHeadless == browserHeadless)&&(identical(other.confidenceThreshold, confidenceThreshold) || other.confidenceThreshold == confidenceThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeProvider,ovhBaseUrl,ovhApiKey,ovhPrimaryModel,ovhFallbackModel,vertexAiBaseUrl,vertexAiApiKey,vertexAiPrimaryModel,vertexAiFallbackModel,browserHeadless,confidenceThreshold);

@override
String toString() {
  return 'AppSettings(activeProvider: $activeProvider, ovhBaseUrl: $ovhBaseUrl, ovhApiKey: $ovhApiKey, ovhPrimaryModel: $ovhPrimaryModel, ovhFallbackModel: $ovhFallbackModel, vertexAiBaseUrl: $vertexAiBaseUrl, vertexAiApiKey: $vertexAiApiKey, vertexAiPrimaryModel: $vertexAiPrimaryModel, vertexAiFallbackModel: $vertexAiFallbackModel, browserHeadless: $browserHeadless, confidenceThreshold: $confidenceThreshold)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 String activeProvider, String ovhBaseUrl, String ovhApiKey, String ovhPrimaryModel, String ovhFallbackModel, String vertexAiBaseUrl, String vertexAiApiKey, String vertexAiPrimaryModel, String vertexAiFallbackModel, bool browserHeadless, double confidenceThreshold
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
@override @pragma('vm:prefer-inline') $Res call({Object? activeProvider = null,Object? ovhBaseUrl = null,Object? ovhApiKey = null,Object? ovhPrimaryModel = null,Object? ovhFallbackModel = null,Object? vertexAiBaseUrl = null,Object? vertexAiApiKey = null,Object? vertexAiPrimaryModel = null,Object? vertexAiFallbackModel = null,Object? browserHeadless = null,Object? confidenceThreshold = null,}) {
  return _then(_AppSettings(
activeProvider: null == activeProvider ? _self.activeProvider : activeProvider // ignore: cast_nullable_to_non_nullable
as String,ovhBaseUrl: null == ovhBaseUrl ? _self.ovhBaseUrl : ovhBaseUrl // ignore: cast_nullable_to_non_nullable
as String,ovhApiKey: null == ovhApiKey ? _self.ovhApiKey : ovhApiKey // ignore: cast_nullable_to_non_nullable
as String,ovhPrimaryModel: null == ovhPrimaryModel ? _self.ovhPrimaryModel : ovhPrimaryModel // ignore: cast_nullable_to_non_nullable
as String,ovhFallbackModel: null == ovhFallbackModel ? _self.ovhFallbackModel : ovhFallbackModel // ignore: cast_nullable_to_non_nullable
as String,vertexAiBaseUrl: null == vertexAiBaseUrl ? _self.vertexAiBaseUrl : vertexAiBaseUrl // ignore: cast_nullable_to_non_nullable
as String,vertexAiApiKey: null == vertexAiApiKey ? _self.vertexAiApiKey : vertexAiApiKey // ignore: cast_nullable_to_non_nullable
as String,vertexAiPrimaryModel: null == vertexAiPrimaryModel ? _self.vertexAiPrimaryModel : vertexAiPrimaryModel // ignore: cast_nullable_to_non_nullable
as String,vertexAiFallbackModel: null == vertexAiFallbackModel ? _self.vertexAiFallbackModel : vertexAiFallbackModel // ignore: cast_nullable_to_non_nullable
as String,browserHeadless: null == browserHeadless ? _self.browserHeadless : browserHeadless // ignore: cast_nullable_to_non_nullable
as bool,confidenceThreshold: null == confidenceThreshold ? _self.confidenceThreshold : confidenceThreshold // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
