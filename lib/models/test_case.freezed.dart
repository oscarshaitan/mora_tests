// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_case.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TestCase {

 String get id; String get name; String get description; String get startUrl; HttpHook? get seeder; HttpHook? get teardown; List<TestStep> get steps; Map<String, String> get variables; TestStatus get status; String? get filePath;
/// Create a copy of TestCase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestCaseCopyWith<TestCase> get copyWith => _$TestCaseCopyWithImpl<TestCase>(this as TestCase, _$identity);

  /// Serializes this TestCase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestCase&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startUrl, startUrl) || other.startUrl == startUrl)&&(identical(other.seeder, seeder) || other.seeder == seeder)&&(identical(other.teardown, teardown) || other.teardown == teardown)&&const DeepCollectionEquality().equals(other.steps, steps)&&const DeepCollectionEquality().equals(other.variables, variables)&&(identical(other.status, status) || other.status == status)&&(identical(other.filePath, filePath) || other.filePath == filePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,startUrl,seeder,teardown,const DeepCollectionEquality().hash(steps),const DeepCollectionEquality().hash(variables),status,filePath);

@override
String toString() {
  return 'TestCase(id: $id, name: $name, description: $description, startUrl: $startUrl, seeder: $seeder, teardown: $teardown, steps: $steps, variables: $variables, status: $status, filePath: $filePath)';
}


}

/// @nodoc
abstract mixin class $TestCaseCopyWith<$Res>  {
  factory $TestCaseCopyWith(TestCase value, $Res Function(TestCase) _then) = _$TestCaseCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String startUrl, HttpHook? seeder, HttpHook? teardown, List<TestStep> steps, Map<String, String> variables, TestStatus status, String? filePath
});


$HttpHookCopyWith<$Res>? get seeder;$HttpHookCopyWith<$Res>? get teardown;

}
/// @nodoc
class _$TestCaseCopyWithImpl<$Res>
    implements $TestCaseCopyWith<$Res> {
  _$TestCaseCopyWithImpl(this._self, this._then);

  final TestCase _self;
  final $Res Function(TestCase) _then;

/// Create a copy of TestCase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? startUrl = null,Object? seeder = freezed,Object? teardown = freezed,Object? steps = null,Object? variables = null,Object? status = null,Object? filePath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startUrl: null == startUrl ? _self.startUrl : startUrl // ignore: cast_nullable_to_non_nullable
as String,seeder: freezed == seeder ? _self.seeder : seeder // ignore: cast_nullable_to_non_nullable
as HttpHook?,teardown: freezed == teardown ? _self.teardown : teardown // ignore: cast_nullable_to_non_nullable
as HttpHook?,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<TestStep>,variables: null == variables ? _self.variables : variables // ignore: cast_nullable_to_non_nullable
as Map<String, String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TestStatus,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TestCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HttpHookCopyWith<$Res>? get seeder {
    if (_self.seeder == null) {
    return null;
  }

  return $HttpHookCopyWith<$Res>(_self.seeder!, (value) {
    return _then(_self.copyWith(seeder: value));
  });
}/// Create a copy of TestCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HttpHookCopyWith<$Res>? get teardown {
    if (_self.teardown == null) {
    return null;
  }

  return $HttpHookCopyWith<$Res>(_self.teardown!, (value) {
    return _then(_self.copyWith(teardown: value));
  });
}
}


/// Adds pattern-matching-related methods to [TestCase].
extension TestCasePatterns on TestCase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TestCase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TestCase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TestCase value)  $default,){
final _that = this;
switch (_that) {
case _TestCase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TestCase value)?  $default,){
final _that = this;
switch (_that) {
case _TestCase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String startUrl,  HttpHook? seeder,  HttpHook? teardown,  List<TestStep> steps,  Map<String, String> variables,  TestStatus status,  String? filePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TestCase() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.startUrl,_that.seeder,_that.teardown,_that.steps,_that.variables,_that.status,_that.filePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String startUrl,  HttpHook? seeder,  HttpHook? teardown,  List<TestStep> steps,  Map<String, String> variables,  TestStatus status,  String? filePath)  $default,) {final _that = this;
switch (_that) {
case _TestCase():
return $default(_that.id,_that.name,_that.description,_that.startUrl,_that.seeder,_that.teardown,_that.steps,_that.variables,_that.status,_that.filePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String startUrl,  HttpHook? seeder,  HttpHook? teardown,  List<TestStep> steps,  Map<String, String> variables,  TestStatus status,  String? filePath)?  $default,) {final _that = this;
switch (_that) {
case _TestCase() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.startUrl,_that.seeder,_that.teardown,_that.steps,_that.variables,_that.status,_that.filePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TestCase implements TestCase {
  const _TestCase({required this.id, required this.name, this.description = '', this.startUrl = '', this.seeder, this.teardown, final  List<TestStep> steps = const [], final  Map<String, String> variables = const {}, this.status = TestStatus.idle, this.filePath}): _steps = steps,_variables = variables;
  factory _TestCase.fromJson(Map<String, dynamic> json) => _$TestCaseFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  String startUrl;
@override final  HttpHook? seeder;
@override final  HttpHook? teardown;
 final  List<TestStep> _steps;
@override@JsonKey() List<TestStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

 final  Map<String, String> _variables;
@override@JsonKey() Map<String, String> get variables {
  if (_variables is EqualUnmodifiableMapView) return _variables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_variables);
}

@override@JsonKey() final  TestStatus status;
@override final  String? filePath;

/// Create a copy of TestCase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestCaseCopyWith<_TestCase> get copyWith => __$TestCaseCopyWithImpl<_TestCase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TestCaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestCase&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startUrl, startUrl) || other.startUrl == startUrl)&&(identical(other.seeder, seeder) || other.seeder == seeder)&&(identical(other.teardown, teardown) || other.teardown == teardown)&&const DeepCollectionEquality().equals(other._steps, _steps)&&const DeepCollectionEquality().equals(other._variables, _variables)&&(identical(other.status, status) || other.status == status)&&(identical(other.filePath, filePath) || other.filePath == filePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,startUrl,seeder,teardown,const DeepCollectionEquality().hash(_steps),const DeepCollectionEquality().hash(_variables),status,filePath);

@override
String toString() {
  return 'TestCase(id: $id, name: $name, description: $description, startUrl: $startUrl, seeder: $seeder, teardown: $teardown, steps: $steps, variables: $variables, status: $status, filePath: $filePath)';
}


}

/// @nodoc
abstract mixin class _$TestCaseCopyWith<$Res> implements $TestCaseCopyWith<$Res> {
  factory _$TestCaseCopyWith(_TestCase value, $Res Function(_TestCase) _then) = __$TestCaseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String startUrl, HttpHook? seeder, HttpHook? teardown, List<TestStep> steps, Map<String, String> variables, TestStatus status, String? filePath
});


@override $HttpHookCopyWith<$Res>? get seeder;@override $HttpHookCopyWith<$Res>? get teardown;

}
/// @nodoc
class __$TestCaseCopyWithImpl<$Res>
    implements _$TestCaseCopyWith<$Res> {
  __$TestCaseCopyWithImpl(this._self, this._then);

  final _TestCase _self;
  final $Res Function(_TestCase) _then;

/// Create a copy of TestCase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? startUrl = null,Object? seeder = freezed,Object? teardown = freezed,Object? steps = null,Object? variables = null,Object? status = null,Object? filePath = freezed,}) {
  return _then(_TestCase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startUrl: null == startUrl ? _self.startUrl : startUrl // ignore: cast_nullable_to_non_nullable
as String,seeder: freezed == seeder ? _self.seeder : seeder // ignore: cast_nullable_to_non_nullable
as HttpHook?,teardown: freezed == teardown ? _self.teardown : teardown // ignore: cast_nullable_to_non_nullable
as HttpHook?,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<TestStep>,variables: null == variables ? _self._variables : variables // ignore: cast_nullable_to_non_nullable
as Map<String, String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TestStatus,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TestCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HttpHookCopyWith<$Res>? get seeder {
    if (_self.seeder == null) {
    return null;
  }

  return $HttpHookCopyWith<$Res>(_self.seeder!, (value) {
    return _then(_self.copyWith(seeder: value));
  });
}/// Create a copy of TestCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HttpHookCopyWith<$Res>? get teardown {
    if (_self.teardown == null) {
    return null;
  }

  return $HttpHookCopyWith<$Res>(_self.teardown!, (value) {
    return _then(_self.copyWith(teardown: value));
  });
}
}

// dart format on
