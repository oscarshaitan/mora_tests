// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'runner_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RunnerState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunnerState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RunnerState()';
}


}

/// @nodoc
class $RunnerStateCopyWith<$Res>  {
$RunnerStateCopyWith(RunnerState _, $Res Function(RunnerState) __);
}


/// Adds pattern-matching-related methods to [RunnerState].
extension RunnerStatePatterns on RunnerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RunnerIdle value)?  idle,TResult Function( RunnerReady value)?  ready,TResult Function( RunnerRunning value)?  running,TResult Function( RunnerFinished value)?  finished,TResult Function( RunnerError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RunnerIdle() when idle != null:
return idle(_that);case RunnerReady() when ready != null:
return ready(_that);case RunnerRunning() when running != null:
return running(_that);case RunnerFinished() when finished != null:
return finished(_that);case RunnerError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RunnerIdle value)  idle,required TResult Function( RunnerReady value)  ready,required TResult Function( RunnerRunning value)  running,required TResult Function( RunnerFinished value)  finished,required TResult Function( RunnerError value)  error,}){
final _that = this;
switch (_that) {
case RunnerIdle():
return idle(_that);case RunnerReady():
return ready(_that);case RunnerRunning():
return running(_that);case RunnerFinished():
return finished(_that);case RunnerError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RunnerIdle value)?  idle,TResult? Function( RunnerReady value)?  ready,TResult? Function( RunnerRunning value)?  running,TResult? Function( RunnerFinished value)?  finished,TResult? Function( RunnerError value)?  error,}){
final _that = this;
switch (_that) {
case RunnerIdle() when idle != null:
return idle(_that);case RunnerReady() when ready != null:
return ready(_that);case RunnerRunning() when running != null:
return running(_that);case RunnerFinished() when finished != null:
return finished(_that);case RunnerError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( List<TestCase> testCases,  List<String> selectedIds,  String? sourcePath)?  ready,TResult Function( TestCase currentTest,  List<StepResult> completedSteps,  TestStep activeStep,  int stepIndex,  int totalSteps,  String? lastLlmReasoning,  double? lastLlmConfidence,  String? lastActionName)?  running,TResult Function( List<TestRun> runs,  List<TestCase> testCases,  List<String> selectedIds)?  finished,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RunnerIdle() when idle != null:
return idle();case RunnerReady() when ready != null:
return ready(_that.testCases,_that.selectedIds,_that.sourcePath);case RunnerRunning() when running != null:
return running(_that.currentTest,_that.completedSteps,_that.activeStep,_that.stepIndex,_that.totalSteps,_that.lastLlmReasoning,_that.lastLlmConfidence,_that.lastActionName);case RunnerFinished() when finished != null:
return finished(_that.runs,_that.testCases,_that.selectedIds);case RunnerError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( List<TestCase> testCases,  List<String> selectedIds,  String? sourcePath)  ready,required TResult Function( TestCase currentTest,  List<StepResult> completedSteps,  TestStep activeStep,  int stepIndex,  int totalSteps,  String? lastLlmReasoning,  double? lastLlmConfidence,  String? lastActionName)  running,required TResult Function( List<TestRun> runs,  List<TestCase> testCases,  List<String> selectedIds)  finished,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case RunnerIdle():
return idle();case RunnerReady():
return ready(_that.testCases,_that.selectedIds,_that.sourcePath);case RunnerRunning():
return running(_that.currentTest,_that.completedSteps,_that.activeStep,_that.stepIndex,_that.totalSteps,_that.lastLlmReasoning,_that.lastLlmConfidence,_that.lastActionName);case RunnerFinished():
return finished(_that.runs,_that.testCases,_that.selectedIds);case RunnerError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( List<TestCase> testCases,  List<String> selectedIds,  String? sourcePath)?  ready,TResult? Function( TestCase currentTest,  List<StepResult> completedSteps,  TestStep activeStep,  int stepIndex,  int totalSteps,  String? lastLlmReasoning,  double? lastLlmConfidence,  String? lastActionName)?  running,TResult? Function( List<TestRun> runs,  List<TestCase> testCases,  List<String> selectedIds)?  finished,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case RunnerIdle() when idle != null:
return idle();case RunnerReady() when ready != null:
return ready(_that.testCases,_that.selectedIds,_that.sourcePath);case RunnerRunning() when running != null:
return running(_that.currentTest,_that.completedSteps,_that.activeStep,_that.stepIndex,_that.totalSteps,_that.lastLlmReasoning,_that.lastLlmConfidence,_that.lastActionName);case RunnerFinished() when finished != null:
return finished(_that.runs,_that.testCases,_that.selectedIds);case RunnerError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class RunnerIdle implements RunnerState {
  const RunnerIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunnerIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RunnerState.idle()';
}


}




/// @nodoc


class RunnerReady implements RunnerState {
  const RunnerReady({required final  List<TestCase> testCases, required final  List<String> selectedIds, this.sourcePath}): _testCases = testCases,_selectedIds = selectedIds;
  

 final  List<TestCase> _testCases;
 List<TestCase> get testCases {
  if (_testCases is EqualUnmodifiableListView) return _testCases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testCases);
}

 final  List<String> _selectedIds;
 List<String> get selectedIds {
  if (_selectedIds is EqualUnmodifiableListView) return _selectedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedIds);
}

 final  String? sourcePath;

/// Create a copy of RunnerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunnerReadyCopyWith<RunnerReady> get copyWith => _$RunnerReadyCopyWithImpl<RunnerReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunnerReady&&const DeepCollectionEquality().equals(other._testCases, _testCases)&&const DeepCollectionEquality().equals(other._selectedIds, _selectedIds)&&(identical(other.sourcePath, sourcePath) || other.sourcePath == sourcePath));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_testCases),const DeepCollectionEquality().hash(_selectedIds),sourcePath);

@override
String toString() {
  return 'RunnerState.ready(testCases: $testCases, selectedIds: $selectedIds, sourcePath: $sourcePath)';
}


}

/// @nodoc
abstract mixin class $RunnerReadyCopyWith<$Res> implements $RunnerStateCopyWith<$Res> {
  factory $RunnerReadyCopyWith(RunnerReady value, $Res Function(RunnerReady) _then) = _$RunnerReadyCopyWithImpl;
@useResult
$Res call({
 List<TestCase> testCases, List<String> selectedIds, String? sourcePath
});




}
/// @nodoc
class _$RunnerReadyCopyWithImpl<$Res>
    implements $RunnerReadyCopyWith<$Res> {
  _$RunnerReadyCopyWithImpl(this._self, this._then);

  final RunnerReady _self;
  final $Res Function(RunnerReady) _then;

/// Create a copy of RunnerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? testCases = null,Object? selectedIds = null,Object? sourcePath = freezed,}) {
  return _then(RunnerReady(
testCases: null == testCases ? _self._testCases : testCases // ignore: cast_nullable_to_non_nullable
as List<TestCase>,selectedIds: null == selectedIds ? _self._selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as List<String>,sourcePath: freezed == sourcePath ? _self.sourcePath : sourcePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class RunnerRunning implements RunnerState {
  const RunnerRunning({required this.currentTest, required final  List<StepResult> completedSteps, required this.activeStep, required this.stepIndex, required this.totalSteps, this.lastLlmReasoning, this.lastLlmConfidence, this.lastActionName}): _completedSteps = completedSteps;
  

 final  TestCase currentTest;
 final  List<StepResult> _completedSteps;
 List<StepResult> get completedSteps {
  if (_completedSteps is EqualUnmodifiableListView) return _completedSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedSteps);
}

 final  TestStep activeStep;
 final  int stepIndex;
 final  int totalSteps;
 final  String? lastLlmReasoning;
 final  double? lastLlmConfidence;
 final  String? lastActionName;

/// Create a copy of RunnerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunnerRunningCopyWith<RunnerRunning> get copyWith => _$RunnerRunningCopyWithImpl<RunnerRunning>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunnerRunning&&(identical(other.currentTest, currentTest) || other.currentTest == currentTest)&&const DeepCollectionEquality().equals(other._completedSteps, _completedSteps)&&(identical(other.activeStep, activeStep) || other.activeStep == activeStep)&&(identical(other.stepIndex, stepIndex) || other.stepIndex == stepIndex)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps)&&(identical(other.lastLlmReasoning, lastLlmReasoning) || other.lastLlmReasoning == lastLlmReasoning)&&(identical(other.lastLlmConfidence, lastLlmConfidence) || other.lastLlmConfidence == lastLlmConfidence)&&(identical(other.lastActionName, lastActionName) || other.lastActionName == lastActionName));
}


@override
int get hashCode => Object.hash(runtimeType,currentTest,const DeepCollectionEquality().hash(_completedSteps),activeStep,stepIndex,totalSteps,lastLlmReasoning,lastLlmConfidence,lastActionName);

@override
String toString() {
  return 'RunnerState.running(currentTest: $currentTest, completedSteps: $completedSteps, activeStep: $activeStep, stepIndex: $stepIndex, totalSteps: $totalSteps, lastLlmReasoning: $lastLlmReasoning, lastLlmConfidence: $lastLlmConfidence, lastActionName: $lastActionName)';
}


}

/// @nodoc
abstract mixin class $RunnerRunningCopyWith<$Res> implements $RunnerStateCopyWith<$Res> {
  factory $RunnerRunningCopyWith(RunnerRunning value, $Res Function(RunnerRunning) _then) = _$RunnerRunningCopyWithImpl;
@useResult
$Res call({
 TestCase currentTest, List<StepResult> completedSteps, TestStep activeStep, int stepIndex, int totalSteps, String? lastLlmReasoning, double? lastLlmConfidence, String? lastActionName
});


$TestCaseCopyWith<$Res> get currentTest;$TestStepCopyWith<$Res> get activeStep;

}
/// @nodoc
class _$RunnerRunningCopyWithImpl<$Res>
    implements $RunnerRunningCopyWith<$Res> {
  _$RunnerRunningCopyWithImpl(this._self, this._then);

  final RunnerRunning _self;
  final $Res Function(RunnerRunning) _then;

/// Create a copy of RunnerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentTest = null,Object? completedSteps = null,Object? activeStep = null,Object? stepIndex = null,Object? totalSteps = null,Object? lastLlmReasoning = freezed,Object? lastLlmConfidence = freezed,Object? lastActionName = freezed,}) {
  return _then(RunnerRunning(
currentTest: null == currentTest ? _self.currentTest : currentTest // ignore: cast_nullable_to_non_nullable
as TestCase,completedSteps: null == completedSteps ? _self._completedSteps : completedSteps // ignore: cast_nullable_to_non_nullable
as List<StepResult>,activeStep: null == activeStep ? _self.activeStep : activeStep // ignore: cast_nullable_to_non_nullable
as TestStep,stepIndex: null == stepIndex ? _self.stepIndex : stepIndex // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,lastLlmReasoning: freezed == lastLlmReasoning ? _self.lastLlmReasoning : lastLlmReasoning // ignore: cast_nullable_to_non_nullable
as String?,lastLlmConfidence: freezed == lastLlmConfidence ? _self.lastLlmConfidence : lastLlmConfidence // ignore: cast_nullable_to_non_nullable
as double?,lastActionName: freezed == lastActionName ? _self.lastActionName : lastActionName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RunnerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TestCaseCopyWith<$Res> get currentTest {
  
  return $TestCaseCopyWith<$Res>(_self.currentTest, (value) {
    return _then(_self.copyWith(currentTest: value));
  });
}/// Create a copy of RunnerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TestStepCopyWith<$Res> get activeStep {
  
  return $TestStepCopyWith<$Res>(_self.activeStep, (value) {
    return _then(_self.copyWith(activeStep: value));
  });
}
}

/// @nodoc


class RunnerFinished implements RunnerState {
  const RunnerFinished({required final  List<TestRun> runs, required final  List<TestCase> testCases, required final  List<String> selectedIds}): _runs = runs,_testCases = testCases,_selectedIds = selectedIds;
  

 final  List<TestRun> _runs;
 List<TestRun> get runs {
  if (_runs is EqualUnmodifiableListView) return _runs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_runs);
}

 final  List<TestCase> _testCases;
 List<TestCase> get testCases {
  if (_testCases is EqualUnmodifiableListView) return _testCases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testCases);
}

 final  List<String> _selectedIds;
 List<String> get selectedIds {
  if (_selectedIds is EqualUnmodifiableListView) return _selectedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedIds);
}


/// Create a copy of RunnerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunnerFinishedCopyWith<RunnerFinished> get copyWith => _$RunnerFinishedCopyWithImpl<RunnerFinished>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunnerFinished&&const DeepCollectionEquality().equals(other._runs, _runs)&&const DeepCollectionEquality().equals(other._testCases, _testCases)&&const DeepCollectionEquality().equals(other._selectedIds, _selectedIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_runs),const DeepCollectionEquality().hash(_testCases),const DeepCollectionEquality().hash(_selectedIds));

@override
String toString() {
  return 'RunnerState.finished(runs: $runs, testCases: $testCases, selectedIds: $selectedIds)';
}


}

/// @nodoc
abstract mixin class $RunnerFinishedCopyWith<$Res> implements $RunnerStateCopyWith<$Res> {
  factory $RunnerFinishedCopyWith(RunnerFinished value, $Res Function(RunnerFinished) _then) = _$RunnerFinishedCopyWithImpl;
@useResult
$Res call({
 List<TestRun> runs, List<TestCase> testCases, List<String> selectedIds
});




}
/// @nodoc
class _$RunnerFinishedCopyWithImpl<$Res>
    implements $RunnerFinishedCopyWith<$Res> {
  _$RunnerFinishedCopyWithImpl(this._self, this._then);

  final RunnerFinished _self;
  final $Res Function(RunnerFinished) _then;

/// Create a copy of RunnerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? runs = null,Object? testCases = null,Object? selectedIds = null,}) {
  return _then(RunnerFinished(
runs: null == runs ? _self._runs : runs // ignore: cast_nullable_to_non_nullable
as List<TestRun>,testCases: null == testCases ? _self._testCases : testCases // ignore: cast_nullable_to_non_nullable
as List<TestCase>,selectedIds: null == selectedIds ? _self._selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class RunnerError implements RunnerState {
  const RunnerError(this.message);
  

 final  String message;

/// Create a copy of RunnerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunnerErrorCopyWith<RunnerError> get copyWith => _$RunnerErrorCopyWithImpl<RunnerError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunnerError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'RunnerState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $RunnerErrorCopyWith<$Res> implements $RunnerStateCopyWith<$Res> {
  factory $RunnerErrorCopyWith(RunnerError value, $Res Function(RunnerError) _then) = _$RunnerErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$RunnerErrorCopyWithImpl<$Res>
    implements $RunnerErrorCopyWith<$Res> {
  _$RunnerErrorCopyWithImpl(this._self, this._then);

  final RunnerError _self;
  final $Res Function(RunnerError) _then;

/// Create a copy of RunnerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(RunnerError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
