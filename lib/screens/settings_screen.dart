import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/settings/settings_cubit.dart';
import '../cubits/settings/settings_state.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _baseUrlCtrl;
  late TextEditingController _apiKeyCtrl;
  late TextEditingController _modelCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsCubit>().state.settings;
    _baseUrlCtrl = TextEditingController(text: s.llmBaseUrl);
    _apiKeyCtrl = TextEditingController(text: s.llmApiKey);
    _modelCtrl = TextEditingController(text: s.llmModel);
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    cubit.update(cubit.state.settings.copyWith(
      llmBaseUrl: _baseUrlCtrl.text.trim(),
      llmApiKey: _apiKeyCtrl.text.trim(),
      llmModel: _modelCtrl.text.trim(),
    ));
    cubit.save();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.savedMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.savedMessage!)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 560,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                Text('LLM Configuration',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _baseUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    border: OutlineInputBorder(),
                    hintText: 'https://oai.endpoints.kepler.ai.cloud.ovh.net/v1',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apiKeyCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'API Key / Access Token',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _modelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Model ID',
                    border: OutlineInputBorder(),
                    hintText: 'Qwen2.5-VL-72B-Instruct',
                  ),
                ),
                const SizedBox(height: 24),
                Text('Behaviour',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Headless WebView'),
                  subtitle: const Text(
                      'Run WebView without visible window (not supported on all platforms)'),
                  value: state.settings.browserHeadless,
                  onChanged: (v) => cubit.update(
                    state.settings.copyWith(browserHeadless: v),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: state.isSaving ? null : () => _save(context),
                  icon: state.isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Save Settings'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
