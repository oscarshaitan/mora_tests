// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'step_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StepResult {

 String get stepId; bool get success; LlmAction? get actionTaken; Uint8List get screenshotBefore; Uint8List? get screenshotAfter; String? get errorMessage; String? get rawLlmResponse; Duration get duration; DateTime get executedAt;/// Sub-step results for call steps (populated when step.call != null).
 List<StepResult> get subStepResults;
/// Create a copy of StepResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepResultCopyWith<StepResult> get copyWith => _$StepResultCopyWithImpl<StepResult>(this as StepResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StepResult&&(identical(other.stepId, stepId) || other.stepId == stepId)&&(identical(other.success, success) || other.success == success)&&(identical(other.actionTaken, actionTaken) || other.actionTaken == actionTaken)&&const DeepCollectionEquality().equals(other.screenshotBefore, screenshotBefore)&&const DeepCollectionEquality().equals(other.screenshotAfter, screenshotAfter)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.rawLlmResponse, rawLlmResponse) || other.rawLlmResponse == rawLlmResponse)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.executedAt, executedAt) || other.executedAt == executedAt)&&const DeepCollectionEquality().equals(other.subStepResults, subStepResults));
}


@override
int get hashCode => Object.hash(runtimeType,stepId,success,actionTaken,const DeepCollectionEquality().hash(screenshotBefore),const DeepCollectionEquality().hash(screenshotAfter),errorMessage,rawLlmResponse,duration,executedAt,const DeepCollectionEquality().hash(subStepResults));

@override
String toString() {
  return 'StepResult(stepId: $stepId, success: $success, actionTaken: $actionTaken, screenshotBefore: $screenshotBefore, screenshotAfter: $screenshotAfter, errorMessage: $errorMessage, rawLlmResponse: $rawLlmResponse, duration: $duration, executedAt: $executedAt, subStepResults: $subStepResults)';
}


}

/// @nodoc
abstract mixin class $StepResultCopyWith<$Res>  {
  factory $StepResultCopyWith(StepResult value, $Res Function(StepResult) _then) = _$StepResultCopyWithImpl;
@useResult
$Res call({
 String stepId, bool success, LlmAction? actionTaken, Uint8List screenshotBefore, Uint8List? screenshotAfter, String? errorMessage, String? rawLlmResponse, Duration duration, DateTime executedAt, List<StepResult> subStepResults
});


$LlmActionCopyWith<$Res>? get actionTaken;

}
/// @nodoc
class _$StepResultCopyWithImpl<$Res>
    implements $StepResultCopyWith<$Res> {
  _$StepResultCopyWithImpl(this._self, this._then);

  final StepResult _self;
  final $Res Function(StepResult) _then;

/// Create a copy of StepResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stepId = null,Object? success = null,Object? actionTaken = freezed,Object? screenshotBefore = null,Object? screenshotAfter = freezed,Object? errorMessage = freezed,Object? rawLlmResponse = freezed,Object? duration = null,Object? executedAt = null,Object? subStepResults = null,}) {
  return _then(_self.copyWith(
stepId: null == stepId ? _self.stepId : stepId // ignore: cast_nullable_to_non_nullable
as String,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,actionTaken: freezed == actionTaken ? _self.actionTaken : actionTaken // ignore: cast_nullable_to_non_nullable
as LlmAction?,screenshotBefore: null == screenshotBefore ? _self.screenshotBefore : screenshotBefore // ignore: cast_nullable_to_non_nullable
as Uint8List,screenshotAfter: freezed == screenshotAfter ? _self.screenshotAfter : screenshotAfter // ignore: cast_nullable_to_non_nullable
as Uint8List?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,rawLlmResponse: freezed == rawLlmResponse ? _self.rawLlmResponse : rawLlmResponse // ignore: cast_nullable_to_non_nullable
as String?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,executedAt: null == executedAt ? _self.executedAt : executedAt // ignore: cast_nullable_to_non_nullable
as DateTime,subStepResults: null == subStepResults ? _self.subStepResults : subStepResults // ignore: cast_nullable_to_non_nullable
as List<StepResult>,
  ));
}
/// Create a copy of StepResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LlmActionCopyWith<$Res>? get actionTaken {
    if (_self.actionTaken == null) {
    return null;
  }

  return $LlmActionCopyWith<$Res>(_self.actionTaken!, (value) {
    return _then(_self.copyWith(actionTaken: value));
  });
}
}


/// Adds pattern-matching-related methods to [StepResult].
extension StepResultPatterns on StepResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StepResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StepResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StepResult value)  $default,){
final _that = this;
switch (_that) {
case _StepResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StepResult value)?  $default,){
final _that = this;
switch (_that) {
case _StepResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stepId,  bool success,  LlmAction? actionTaken,  Uint8List screenshotBefore,  Uint8List? screenshotAfter,  String? errorMessage,  String? rawLlmResponse,  Duration duration,  DateTime executedAt,  List<StepResult> subStepResults)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StepResult() when $default != null:
return $default(_that.stepId,_that.success,_that.actionTaken,_that.screenshotBefore,_that.screenshotAfter,_that.errorMessage,_that.rawLlmResponse,_that.duration,_that.executedAt,_that.subStepResults);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stepId,  bool success,  LlmAction? actionTaken,  Uint8List screenshotBefore,  Uint8List? screenshotAfter,  String? errorMessage,  String? rawLlmResponse,  Duration duration,  DateTime executedAt,  List<StepResult> subStepResults)  $default,) {final _that = this;
switch (_that) {
case _StepResult():
return $default(_that.stepId,_that.success,_that.actionTaken,_that.screenshotBefore,_that.screenshotAfter,_that.errorMessage,_that.rawLlmResponse,_that.duration,_that.executedAt,_that.subStepResults);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stepId,  bool success,  LlmAction? actionTaken,  Uint8List screenshotBefore,  Uint8List? screenshotAfter,  String? errorMessage,  String? rawLlmResponse,  Duration duration,  DateTime executedAt,  List<StepResult> subStepResults)?  $default,) {final _that = this;
switch (_that) {
case _StepResult() when $default != null:
return $default(_that.stepId,_that.success,_that.actionTaken,_that.screenshotBefore,_that.screenshotAfter,_that.errorMessage,_that.rawLlmResponse,_that.duration,_that.executedAt,_that.subStepResults);case _:
  return null;

}
}

}

/// @nodoc


class _StepResult implements StepResult {
  const _StepResult({required this.stepId, required this.success, this.actionTaken, required this.screenshotBefore, this.screenshotAfter, this.errorMessage, this.rawLlmResponse, required this.duration, required this.executedAt, final  List<StepResult> subStepResults = const []}): _subStepResults = subStepResults;
  

@override final  String stepId;
@override final  bool success;
@override final  LlmAction? actionTaken;
@override final  Uint8List screenshotBefore;
@override final  Uint8List? screenshotAfter;
@override final  String? errorMessage;
@override final  String? rawLlmResponse;
@override final  Duration duration;
@override final  DateTime executedAt;
/// Sub-step results for call steps (populated when step.call != null).
 final  List<StepResult> _subStepResults;
/// Sub-step results for call steps (populated when step.call != null).
@override@JsonKey() List<StepResult> get subStepResults {
  if (_subStepResults is EqualUnmodifiableListView) return _subStepResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subStepResults);
}


/// Create a copy of StepResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StepResultCopyWith<_StepResult> get copyWith => __$StepResultCopyWithImpl<_StepResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StepResult&&(identical(other.stepId, stepId) || other.stepId == stepId)&&(identical(other.success, success) || other.success == success)&&(identical(other.actionTaken, actionTaken) || other.actionTaken == actionTaken)&&const DeepCollectionEquality().equals(other.screenshotBefore, screenshotBefore)&&const DeepCollectionEquality().equals(other.screenshotAfter, screenshotAfter)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.rawLlmResponse, rawLlmResponse) || other.rawLlmResponse == rawLlmResponse)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.executedAt, executedAt) || other.executedAt == executedAt)&&const DeepCollectionEquality().equals(other._subStepResults, _subStepResults));
}


@override
int get hashCode => Object.hash(runtimeType,stepId,success,actionTaken,const DeepCollectionEquality().hash(screenshotBefore),const DeepCollectionEquality().hash(screenshotAfter),errorMessage,rawLlmResponse,duration,executedAt,const DeepCollectionEquality().hash(_subStepResults));

@override
String toString() {
  return 'StepResult(stepId: $stepId, success: $success, actionTaken: $actionTaken, screenshotBefore: $screenshotBefore, screenshotAfter: $screenshotAfter, errorMessage: $errorMessage, rawLlmResponse: $rawLlmResponse, duration: $duration, executedAt: $executedAt, subStepResults: $subStepResults)';
}


}

/// @nodoc
abstract mixin class _$StepResultCopyWith<$Res> implements $StepResultCopyWith<$Res> {
  factory _$StepResultCopyWith(_StepResult value, $Res Function(_StepResult) _then) = __$StepResultCopyWithImpl;
@override @useResult
$Res call({
 String stepId, bool success, LlmAction? actionTaken, Uint8List screenshotBefore, Uint8List? screenshotAfter, String? errorMessage, String? rawLlmResponse, Duration duration, DateTime executedAt, List<StepResult> subStepResults
});


@override $LlmActionCopyWith<$Res>? get actionTaken;

}
/// @nodoc
class __$StepResultCopyWithImpl<$Res>
    implements _$StepResultCopyWith<$Res> {
  __$StepResultCopyWithImpl(this._self, this._then);

  final _StepResult _self;
  final $Res Function(_StepResult) _then;

/// Create a copy of StepResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stepId = null,Object? success = null,Object? actionTaken = freezed,Object? screenshotBefore = null,Object? screenshotAfter = freezed,Object? errorMessage = freezed,Object? rawLlmResponse = freezed,Object? duration = null,Object? executedAt = null,Object? subStepResults = null,}) {
  return _then(_StepResult(
stepId: null == stepId ? _self.stepId : stepId // ignore: cast_nullable_to_non_nullable
as String,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,actionTaken: freezed == actionTaken ? _self.actionTaken : actionTaken // ignore: cast_nullable_to_non_nullable
as LlmAction?,screenshotBefore: null == screenshotBefore ? _self.screenshotBefore : screenshotBefore // ignore: cast_nullable_to_non_nullable
as Uint8List,screenshotAfter: freezed == screenshotAfter ? _self.screenshotAfter : screenshotAfter // ignore: cast_nullable_to_non_nullable
as Uint8List?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,rawLlmResponse: freezed == rawLlmResponse ? _self.rawLlmResponse : rawLlmResponse // ignore: cast_nullable_to_non_nullable
as String?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,executedAt: null == executedAt ? _self.executedAt : executedAt // ignore: cast_nullable_to_non_nullable
as DateTime,subStepResults: null == subStepResults ? _self._subStepResults : subStepResults // ignore: cast_nullable_to_non_nullable
as List<StepResult>,
  ));
}

/// Create a copy of StepResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LlmActionCopyWith<$Res>? get actionTaken {
    if (_self.actionTaken == null) {
    return null;
  }

  return $LlmActionCopyWith<$Res>(_self.actionTaken!, (value) {
    return _then(_self.copyWith(actionTaken: value));
  });
}
}

// dart format on
