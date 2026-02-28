// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TestStep {

 String get id; String get instruction; String? get hint; String? get assertion; int get timeoutSeconds;
/// Create a copy of TestStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestStepCopyWith<TestStep> get copyWith => _$TestStepCopyWithImpl<TestStep>(this as TestStep, _$identity);

  /// Serializes this TestStep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestStep&&(identical(other.id, id) || other.id == id)&&(identical(other.instruction, instruction) || other.instruction == instruction)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.assertion, assertion) || other.assertion == assertion)&&(identical(other.timeoutSeconds, timeoutSeconds) || other.timeoutSeconds == timeoutSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,instruction,hint,assertion,timeoutSeconds);

@override
String toString() {
  return 'TestStep(id: $id, instruction: $instruction, hint: $hint, assertion: $assertion, timeoutSeconds: $timeoutSeconds)';
}


}

/// @nodoc
abstract mixin class $TestStepCopyWith<$Res>  {
  factory $TestStepCopyWith(TestStep value, $Res Function(TestStep) _then) = _$TestStepCopyWithImpl;
@useResult
$Res call({
 String id, String instruction, String? hint, String? assertion, int timeoutSeconds
});




}
/// @nodoc
class _$TestStepCopyWithImpl<$Res>
    implements $TestStepCopyWith<$Res> {
  _$TestStepCopyWithImpl(this._self, this._then);

  final TestStep _self;
  final $Res Function(TestStep) _then;

/// Create a copy of TestStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? instruction = null,Object? hint = freezed,Object? assertion = freezed,Object? timeoutSeconds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,assertion: freezed == assertion ? _self.assertion : assertion // ignore: cast_nullable_to_non_nullable
as String?,timeoutSeconds: null == timeoutSeconds ? _self.timeoutSeconds : timeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TestStep].
extension TestStepPatterns on TestStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TestStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TestStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TestStep value)  $default,){
final _that = this;
switch (_that) {
case _TestStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TestStep value)?  $default,){
final _that = this;
switch (_that) {
case _TestStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String instruction,  String? hint,  String? assertion,  int timeoutSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TestStep() when $default != null:
return $default(_that.id,_that.instruction,_that.hint,_that.assertion,_that.timeoutSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String instruction,  String? hint,  String? assertion,  int timeoutSeconds)  $default,) {final _that = this;
switch (_that) {
case _TestStep():
return $default(_that.id,_that.instruction,_that.hint,_that.assertion,_that.timeoutSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String instruction,  String? hint,  String? assertion,  int timeoutSeconds)?  $default,) {final _that = this;
switch (_that) {
case _TestStep() when $default != null:
return $default(_that.id,_that.instruction,_that.hint,_that.assertion,_that.timeoutSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TestStep implements TestStep {
  const _TestStep({required this.id, required this.instruction, this.hint, this.assertion, this.timeoutSeconds = 30});
  factory _TestStep.fromJson(Map<String, dynamic> json) => _$TestStepFromJson(json);

@override final  String id;
@override final  String instruction;
@override final  String? hint;
@override final  String? assertion;
@override@JsonKey() final  int timeoutSeconds;

/// Create a copy of TestStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestStepCopyWith<_TestStep> get copyWith => __$TestStepCopyWithImpl<_TestStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TestStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestStep&&(identical(other.id, id) || other.id == id)&&(identical(other.instruction, instruction) || other.instruction == instruction)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.assertion, assertion) || other.assertion == assertion)&&(identical(other.timeoutSeconds, timeoutSeconds) || other.timeoutSeconds == timeoutSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,instruction,hint,assertion,timeoutSeconds);

@override
String toString() {
  return 'TestStep(id: $id, instruction: $instruction, hint: $hint, assertion: $assertion, timeoutSeconds: $timeoutSeconds)';
}


}

/// @nodoc
abstract mixin class _$TestStepCopyWith<$Res> implements $TestStepCopyWith<$Res> {
  factory _$TestStepCopyWith(_TestStep value, $Res Function(_TestStep) _then) = __$TestStepCopyWithImpl;
@override @useResult
$Res call({
 String id, String instruction, String? hint, String? assertion, int timeoutSeconds
});




}
/// @nodoc
class __$TestStepCopyWithImpl<$Res>
    implements _$TestStepCopyWith<$Res> {
  __$TestStepCopyWithImpl(this._self, this._then);

  final _TestStep _self;
  final $Res Function(_TestStep) _then;

/// Create a copy of TestStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? instruction = null,Object? hint = freezed,Object? assertion = freezed,Object? timeoutSeconds = null,}) {
  return _then(_TestStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,assertion: freezed == assertion ? _self.assertion : assertion // ignore: cast_nullable_to_non_nullable
as String?,timeoutSeconds: null == timeoutSeconds ? _self.timeoutSeconds : timeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
