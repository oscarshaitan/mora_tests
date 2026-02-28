import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/test_case.dart';

part 'builder_state.freezed.dart';

@freezed
abstract class BuilderState with _$BuilderState {
  const factory BuilderState({
    @Default([]) List<TestCase> testCases,
    TestCase? selectedTest,
    @Default(false) bool isDirty,
    String? savedPath,
    String? errorMessage,
  }) = _BuilderState;
}
