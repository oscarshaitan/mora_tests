import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../injection.dart';
import '../../models/app_settings.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(AppSettings initial, this._prefs)
      : super(SettingsState(settings: initial));

  void update(AppSettings settings) {
    emit(state.copyWith(settings: settings, savedMessage: null));
  }

  Future<void> save() async {
    emit(state.copyWith(isSaving: true));
    try {
      final json = jsonEncode(state.settings.toJson());
      await _prefs.setString('app_settings', json);
      refreshLlmService(state.settings);
      emit(state.copyWith(isSaving: false, savedMessage: 'Settings saved'));
    } catch (_) {
      emit(state.copyWith(isSaving: false, savedMessage: 'Save failed'));
    }
  }
}
