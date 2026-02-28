import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/app_settings.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    required AppSettings settings,
    @Default(false) bool isSaving,
    String? savedMessage,
  }) = _SettingsState;
}
