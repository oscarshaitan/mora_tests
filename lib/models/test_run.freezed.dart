// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TestRun {

 String get id; String get testCaseId; String get testCaseName; DateTime get startedAt; DateTime? get finishedAt; RunStatus get status; List<StepResult> get results;
/// Create a copy of TestRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestRunCopyWith<TestRun> get copyWith => _$TestRunCopyWithImpl<TestRun>(this as TestRun, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestRun&&(identical(other.id, id) || other.id == id)&&(identical(other.testCaseId, testCaseId) || other.testCaseId == testCaseId)&&(identical(other.testCaseName, testCaseName) || other.testCaseName == testCaseName)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.results, results));
}


@override
int get hashCode => Object.hash(runtimeType,id,testCaseId,testCaseName,startedAt,finishedAt,status,const DeepCollectionEquality().hash(results));

@override
String toString() {
  return 'TestRun(id: $id, testCaseId: $testCaseId, testCaseName: $testCaseName, startedAt: $startedAt, finishedAt: $finishedAt, status: $status, results: $results)';
}


}

/// @nodoc
abstract mixin class $TestRunCopyWith<$Res>  {
  factory $TestRunCopyWith(TestRun value, $Res Function(TestRun) _then) = _$TestRunCopyWithImpl;
@useResult
$Res call({
 String id, String testCaseId, String testCaseName, DateTime startedAt, DateTime? finishedAt, RunStatus status, List<StepResult> results
});




}
/// @nodoc
class _$TestRunCopyWithImpl<$Res>
    implements $TestRunCopyWith<$Res> {
  _$TestRunCopyWithImpl(this._self, this._then);

  final TestRun _self;
  final $Res Function(TestRun) _then;

/// Create a copy of TestRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? testCaseId = null,Object? testCaseName = null,Object? startedAt = null,Object? finishedAt = freezed,Object? status = null,Object? results = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,testCaseId: null == testCaseId ? _self.testCaseId : testCaseId // ignore: cast_nullable_to_non_nullable
as String,testCaseName: null == testCaseName ? _self.testCaseName : testCaseName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RunStatus,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<StepResult>,
  ));
}

}


/// Adds pattern-matching-related methods to [TestRun].
extension TestRunPatterns on TestRun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TestRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TestRun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TestRun value)  $default,){
final _that = this;
switch (_that) {
case _TestRun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TestRun value)?  $default,){
final _that = this;
switch (_that) {
case _TestRun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String testCaseId,  String testCaseName,  DateTime startedAt,  DateTime? finishedAt,  RunStatus status,  List<StepResult> results)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TestRun() when $default != null:
return $default(_that.id,_that.testCaseId,_that.testCaseName,_that.startedAt,_that.finishedAt,_that.status,_that.results);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String testCaseId,  String testCaseName,  DateTime startedAt,  DateTime? finishedAt,  RunStatus status,  List<StepResult> results)  $default,) {final _that = this;
switch (_that) {
case _TestRun():
return $default(_that.id,_that.testCaseId,_that.testCaseName,_that.startedAt,_that.finishedAt,_that.status,_that.results);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String testCaseId,  String testCaseName,  DateTime startedAt,  DateTime? finishedAt,  RunStatus status,  List<StepResult> results)?  $default,) {final _that = this;
switch (_that) {
case _TestRun() when $default != null:
return $default(_that.id,_that.testCaseId,_that.testCaseName,_that.startedAt,_that.finishedAt,_that.status,_that.results);case _:
  return null;

}
}

}

/// @nodoc


class _TestRun extends TestRun {
  const _TestRun({required this.id, required this.testCaseId, required this.testCaseName, required this.startedAt, this.finishedAt, this.status = RunStatus.running, final  List<StepResult> results = const []}): _results = results,super._();
  

@override final  String id;
@override final  String testCaseId;
@override final  String testCaseName;
@override final  DateTime startedAt;
@override final  DateTime? finishedAt;
@override@JsonKey() final  RunStatus status;
 final  List<StepResult> _results;
@override@JsonKey() List<StepResult> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of TestRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestRunCopyWith<_TestRun> get copyWith => __$TestRunCopyWithImpl<_TestRun>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestRun&&(identical(other.id, id) || other.id == id)&&(identical(other.testCaseId, testCaseId) || other.testCaseId == testCaseId)&&(identical(other.testCaseName, testCaseName) || other.testCaseName == testCaseName)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._results, _results));
}


@override
int get hashCode => Object.hash(runtimeType,id,testCaseId,testCaseName,startedAt,finishedAt,status,const DeepCollectionEquality().hash(_results));

@override
String toString() {
  return 'TestRun(id: $id, testCaseId: $testCaseId, testCaseName: $testCaseName, startedAt: $startedAt, finishedAt: $finishedAt, status: $status, results: $results)';
}


}

/// @nodoc
abstract mixin class _$TestRunCopyWith<$Res> implements $TestRunCopyWith<$Res> {
  factory _$TestRunCopyWith(_TestRun value, $Res Function(_TestRun) _then) = __$TestRunCopyWithImpl;
@override @useResult
$Res call({
 String id, String testCaseId, String testCaseName, DateTime startedAt, DateTime? finishedAt, RunStatus status, List<StepResult> results
});




}
/// @nodoc
class __$TestRunCopyWithImpl<$Res>
    implements _$TestRunCopyWith<$Res> {
  __$TestRunCopyWithImpl(this._self, this._then);

  final _TestRun _self;
  final $Res Function(_TestRun) _then;

/// Create a copy of TestRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? testCaseId = null,Object? testCaseName = null,Object? startedAt = null,Object? finishedAt = freezed,Object? status = null,Object? results = null,}) {
  return _then(_TestRun(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,testCaseId: null == testCaseId ? _self.testCaseId : testCaseId // ignore: cast_nullable_to_non_nullable
as String,testCaseName: null == testCaseName ? _self.testCaseName : testCaseName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RunStatus,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<StepResult>,
  ));
}


}

// dart format on
