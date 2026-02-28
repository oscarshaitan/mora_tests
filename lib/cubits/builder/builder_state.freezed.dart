// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'builder_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BuilderState {

 List<TestCase> get testCases; TestCase? get selectedTest; bool get isDirty; String? get savedPath; String? get errorMessage;
/// Create a copy of BuilderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuilderStateCopyWith<BuilderState> get copyWith => _$BuilderStateCopyWithImpl<BuilderState>(this as BuilderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuilderState&&const DeepCollectionEquality().equals(other.testCases, testCases)&&(identical(other.selectedTest, selectedTest) || other.selectedTest == selectedTest)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.savedPath, savedPath) || other.savedPath == savedPath)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(testCases),selectedTest,isDirty,savedPath,errorMessage);

@override
String toString() {
  return 'BuilderState(testCases: $testCases, selectedTest: $selectedTest, isDirty: $isDirty, savedPath: $savedPath, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $BuilderStateCopyWith<$Res>  {
  factory $BuilderStateCopyWith(BuilderState value, $Res Function(BuilderState) _then) = _$BuilderStateCopyWithImpl;
@useResult
$Res call({
 List<TestCase> testCases, TestCase? selectedTest, bool isDirty, String? savedPath, String? errorMessage
});


$TestCaseCopyWith<$Res>? get selectedTest;

}
/// @nodoc
class _$BuilderStateCopyWithImpl<$Res>
    implements $BuilderStateCopyWith<$Res> {
  _$BuilderStateCopyWithImpl(this._self, this._then);

  final BuilderState _self;
  final $Res Function(BuilderState) _then;

/// Create a copy of BuilderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? testCases = null,Object? selectedTest = freezed,Object? isDirty = null,Object? savedPath = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
testCases: null == testCases ? _self.testCases : testCases // ignore: cast_nullable_to_non_nullable
as List<TestCase>,selectedTest: freezed == selectedTest ? _self.selectedTest : selectedTest // ignore: cast_nullable_to_non_nullable
as TestCase?,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,savedPath: freezed == savedPath ? _self.savedPath : savedPath // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of BuilderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TestCaseCopyWith<$Res>? get selectedTest {
    if (_self.selectedTest == null) {
    return null;
  }

  return $TestCaseCopyWith<$Res>(_self.selectedTest!, (value) {
    return _then(_self.copyWith(selectedTest: value));
  });
}
}


/// Adds pattern-matching-related methods to [BuilderState].
extension BuilderStatePatterns on BuilderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuilderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuilderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuilderState value)  $default,){
final _that = this;
switch (_that) {
case _BuilderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuilderState value)?  $default,){
final _that = this;
switch (_that) {
case _BuilderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TestCase> testCases,  TestCase? selectedTest,  bool isDirty,  String? savedPath,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuilderState() when $default != null:
return $default(_that.testCases,_that.selectedTest,_that.isDirty,_that.savedPath,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TestCase> testCases,  TestCase? selectedTest,  bool isDirty,  String? savedPath,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _BuilderState():
return $default(_that.testCases,_that.selectedTest,_that.isDirty,_that.savedPath,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TestCase> testCases,  TestCase? selectedTest,  bool isDirty,  String? savedPath,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _BuilderState() when $default != null:
return $default(_that.testCases,_that.selectedTest,_that.isDirty,_that.savedPath,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _BuilderState implements BuilderState {
  const _BuilderState({final  List<TestCase> testCases = const [], this.selectedTest, this.isDirty = false, this.savedPath, this.errorMessage}): _testCases = testCases;
  

 final  List<TestCase> _testCases;
@override@JsonKey() List<TestCase> get testCases {
  if (_testCases is EqualUnmodifiableListView) return _testCases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testCases);
}

@override final  TestCase? selectedTest;
@override@JsonKey() final  bool isDirty;
@override final  String? savedPath;
@override final  String? errorMessage;

/// Create a copy of BuilderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuilderStateCopyWith<_BuilderState> get copyWith => __$BuilderStateCopyWithImpl<_BuilderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuilderState&&const DeepCollectionEquality().equals(other._testCases, _testCases)&&(identical(other.selectedTest, selectedTest) || other.selectedTest == selectedTest)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.savedPath, savedPath) || other.savedPath == savedPath)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_testCases),selectedTest,isDirty,savedPath,errorMessage);

@override
String toString() {
  return 'BuilderState(testCases: $testCases, selectedTest: $selectedTest, isDirty: $isDirty, savedPath: $savedPath, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$BuilderStateCopyWith<$Res> implements $BuilderStateCopyWith<$Res> {
  factory _$BuilderStateCopyWith(_BuilderState value, $Res Function(_BuilderState) _then) = __$BuilderStateCopyWithImpl;
@override @useResult
$Res call({
 List<TestCase> testCases, TestCase? selectedTest, bool isDirty, String? savedPath, String? errorMessage
});


@override $TestCaseCopyWith<$Res>? get selectedTest;

}
/// @nodoc
class __$BuilderStateCopyWithImpl<$Res>
    implements _$BuilderStateCopyWith<$Res> {
  __$BuilderStateCopyWithImpl(this._self, this._then);

  final _BuilderState _self;
  final $Res Function(_BuilderState) _then;

/// Create a copy of BuilderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? testCases = null,Object? selectedTest = freezed,Object? isDirty = null,Object? savedPath = freezed,Object? errorMessage = freezed,}) {
  return _then(_BuilderState(
testCases: null == testCases ? _self._testCases : testCases // ignore: cast_nullable_to_non_nullable
as List<TestCase>,selectedTest: freezed == selectedTest ? _self.selectedTest : selectedTest // ignore: cast_nullable_to_non_nullable
as TestCase?,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,savedPath: freezed == savedPath ? _self.savedPath : savedPath // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of BuilderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TestCaseCopyWith<$Res>? get selectedTest {
    if (_self.selectedTest == null) {
    return null;
  }

  return $TestCaseCopyWith<$Res>(_self.selectedTest!, (value) {
    return _then(_self.copyWith(selectedTest: value));
  });
}
}

// dart format on
