import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants.dart';
import '../cubits/settings/settings_cubit.dart';
import '../cubits/settings/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _baseUrlCtrl;
  late TextEditingController _apiKeyCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _fallbackModelCtrl;

  static const _presets = [
    AppConstants.defaultLlmModel,
    AppConstants.mistralModel,
  ];

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsCubit>().state.settings;
    _baseUrlCtrl = TextEditingController(text: s.llmBaseUrl);
    _apiKeyCtrl = TextEditingController(text: s.llmApiKey);
    _modelCtrl = TextEditingController(text: s.llmModel);
    _fallbackModelCtrl = TextEditingController(text: s.llmFallbackModel);
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    _modelCtrl.dispose();
    _fallbackModelCtrl.dispose();
    super.dispose();
  }

  /// Selects [model] as primary and auto-sets the fallback to the other preset
  /// (if the current primary is a known preset).
  void _selectPrimary(String model) {
    setState(() {
      _modelCtrl.text = model;
      // Auto-set fallback to the other preset
      final other = _presets.firstWhere((p) => p != model, orElse: () => '');
      if (other.isNotEmpty) _fallbackModelCtrl.text = other;
    });
  }

  void _save(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    cubit.update(cubit.state.settings.copyWith(
      llmBaseUrl: _baseUrlCtrl.text.trim(),
      llmApiKey: _apiKeyCtrl.text.trim(),
      llmModel: _modelCtrl.text.trim(),
      llmFallbackModel: _fallbackModelCtrl.text.trim(),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),

                  // ── LLM Configuration ─────────────────────────────────────
                  Text('LLM Configuration',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _baseUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Base URL',
                      border: OutlineInputBorder(),
                      hintText:
                          'https://oai.endpoints.kepler.ai.cloud.ovh.net/v1',
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
                  const SizedBox(height: 20),

                  // ── Model Selection ────────────────────────────────────────
                  Text('Model Selection',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your primary model. The other preset is used as automatic fallback when the primary fails.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _presets.map((preset) {
                      final isPrimary = _modelCtrl.text == preset;
                      final isFallback = _fallbackModelCtrl.text == preset;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: preset == _presets.last ? 0 : 8,
                          ),
                          child: _ModelCard(
                            modelId: preset,
                            isPrimary: isPrimary,
                            isFallback: isFallback && !isPrimary,
                            onSetPrimary: () => _selectPrimary(preset),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _modelCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Primary model (custom override)',
                      border: OutlineInputBorder(),
                      hintText: 'Qwen2.5-VL-72B-Instruct',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _fallbackModelCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Fallback model (custom override)',
                      border: OutlineInputBorder(),
                      hintText: 'Mistral-Small-3.2-24B-Instruct-2506',
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Behaviour ──────────────────────────────────────────────
                  Text('Behaviour',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: SwitchListTile(
                      title: const Text('Headless WebView'),
                      subtitle: const Text(
                          'Run WebView without a visible window'
                          ' (not supported on all platforms)'),
                      value: state.settings.browserHeadless,
                      onChanged: (v) => cubit.update(
                        state.settings.copyWith(browserHeadless: v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  FilledButton.icon(
                    onPressed: state.isSaving ? null : () => _save(context),
                    icon: state.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: const Text('Save Settings'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModelCard extends StatelessWidget {
  final String modelId;
  final bool isPrimary;
  final bool isFallback;
  final VoidCallback onSetPrimary;

  const _ModelCard({
    required this.modelId,
    required this.isPrimary,
    required this.isFallback,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = isPrimary
        ? colorScheme.primary
        : isFallback
            ? colorScheme.outline
            : colorScheme.outlineVariant;

    return InkWell(
      onTap: isPrimary ? null : onSetPrimary,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: isPrimary ? 2 : 1),
          color: isPrimary
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    modelId,
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (isPrimary)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PRIMARY',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (isFallback)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'FALLBACK',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: onSetPrimary,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Set as primary',
                    style: TextStyle(fontSize: 10)),
              ),
          ],
        ),
      ),
    );
  }
}
