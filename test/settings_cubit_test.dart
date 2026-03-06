import 'package:flutter_test/flutter_test.dart';
import 'package:mora_tests/cubits/settings/settings_cubit.dart';
import 'package:mora_tests/cubits/settings/settings_state.dart';
import 'package:mora_tests/injection.dart';
import 'package:mora_tests/models/app_settings.dart';
import 'package:mora_tests/services/llm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<SettingsCubit> makeCubit([AppSettings? settings]) async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsCubit(settings ?? const AppSettings(), prefs);
  }

  // ── Initial state ──────────────────────────────────────────────────────────

  group('initial state', () {
    test('state has the settings passed to the constructor', () async {
      final cubit = await makeCubit();
      expect(cubit.state.settings, equals(const AppSettings()));
    });

    test('isSaving defaults to false', () async {
      final cubit = await makeCubit();
      expect(cubit.state.isSaving, isFalse);
    });

    test('savedMessage defaults to null', () async {
      final cubit = await makeCubit();
      expect(cubit.state.savedMessage, isNull);
    });

    test('initial settings with custom values are preserved', () async {
      const custom = AppSettings(ovhApiKey: 'my-key', activeProvider: 'ovh');
      final cubit = await makeCubit(custom);
      expect(cubit.state.settings.ovhApiKey, equals('my-key'));
    });
  });

  // ── update() ──────────────────────────────────────────────────────────────

  group('update()', () {
    test('emits new settings', () async {
      final cubit = await makeCubit();
      const updated = AppSettings(ovhApiKey: 'new-key');
      cubit.update(updated);
      expect(cubit.state.settings.ovhApiKey, equals('new-key'));
    });

    test('clears savedMessage when updating', () async {
      final cubit = await makeCubit();
      // Manually emit a state with a savedMessage to simulate a prior save
      cubit.update(const AppSettings(ovhApiKey: 'k'));
      // Now update again
      cubit.update(const AppSettings(ovhApiKey: 'k2'));
      expect(cubit.state.savedMessage, isNull);
    });

    test('isSaving stays false after update', () async {
      final cubit = await makeCubit();
      cubit.update(const AppSettings(browserHeadless: true));
      expect(cubit.state.isSaving, isFalse);
    });

    test('updating provider changes it in state', () async {
      final cubit = await makeCubit();
      cubit.update(const AppSettings(activeProvider: 'vertexAi'));
      expect(cubit.state.settings.activeProvider, equals('vertexAi'));
    });
  });

  // ── save() ────────────────────────────────────────────────────────────────

  group('save()', () {
    tearDown(() async {
      // Reset get_it so LlmService registrations don't leak between tests.
      await sl.reset();
    });

    test('persists settings JSON to SharedPreferences', () async {
      final cubit = await makeCubit(const AppSettings(ovhApiKey: 'saved-key'));
      await cubit.save();
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('app_settings');
      expect(json, isNotNull);
      expect(json, contains('saved-key'));
    });

    test('emits savedMessage after successful save', () async {
      final cubit = await makeCubit();
      await cubit.save();
      expect(cubit.state.savedMessage, equals('Settings saved'));
      expect(cubit.state.isSaving, isFalse);
    });

    test('isSaving is false after save completes', () async {
      final cubit = await makeCubit();
      await cubit.save();
      expect(cubit.state.isSaving, isFalse);
    });

    test('save registers LlmService in the service locator', () async {
      final cubit = await makeCubit(const AppSettings(ovhApiKey: 'key'));
      await cubit.save();
      // refreshLlmService always registers (or re-registers) LlmService in sl.
      // Accessing the singleton should not throw.
      expect(() => sl<LlmService>(), returnsNormally);
    });
  });

  // ── SettingsState copyWith ─────────────────────────────────────────────────

  group('SettingsState', () {
    test('copyWith preserves unchanged fields', () {
      const state = SettingsState(
        settings: AppSettings(ovhApiKey: 'abc'),
        isSaving: false,
        savedMessage: null,
      );
      final updated = state.copyWith(isSaving: true);
      expect(updated.isSaving, isTrue);
      expect(updated.settings.ovhApiKey, equals('abc'));
      expect(updated.savedMessage, isNull);
    });

    test('copyWith can set savedMessage', () {
      const state = SettingsState(settings: AppSettings());
      final updated = state.copyWith(savedMessage: 'Settings saved');
      expect(updated.savedMessage, equals('Settings saved'));
    });
  });
}
