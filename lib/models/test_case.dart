import 'package:freezed_annotation/freezed_annotation.dart';

import 'http_hook.dart';
import 'test_step.dart';

part 'test_case.freezed.dart';
part 'test_case.g.dart';

enum TestStatus { idle, running, passed, failed, partial }

@freezed
abstract class TestCase with _$TestCase {
  const factory TestCase({
    required String id,
    required String name,
    @Default('') String description,
    @Default('') String startUrl,
    HttpHook? seeder,
    HttpHook? teardown,
    @Default([]) List<TestStep> steps,
    @Default({}) Map<String, String> variables,
    @Default(1280) int viewportWidth,
    @Default(720) int viewportHeight,
    @Default(TestStatus.idle) TestStatus status,
    String? filePath,
  }) = _TestCase;

  factory TestCase.fromJson(Map<String, Object?> json) =>
      _$TestCaseFromJson(json);
}
