import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../core/constants.dart';
import '../cubits/settings/settings_cubit.dart';
import '../cubits/settings/settings_state.dart';

// ---------------------------------------------------------------------------
// Simple data holder for one provider's config (used as local UI state)
// ---------------------------------------------------------------------------

class _ProviderConfig {
  String baseUrl;
  String apiKey;
  String serviceAccountJson;
  String primaryModel;
  String fallbackModel;

  _ProviderConfig({
    required this.baseUrl,
    this.apiKey = '',
    this.serviceAccountJson = '',
    required this.primaryModel,
    required this.fallbackModel,
  });
}

// ---------------------------------------------------------------------------
// Settings screen
// ---------------------------------------------------------------------------

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late LlmProvider _activeProvider;
  late _ProviderConfig _ovhConfig;
  late _ProviderConfig _vertexConfig;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsCubit>().state.settings;
    _activeProvider =
        s.activeProvider == 'vertexAi' ? LlmProvider.vertexAi : LlmProvider.ovh;
    _ovhConfig = _ProviderConfig(
      baseUrl: s.ovhBaseUrl,
      apiKey: s.ovhApiKey,
      primaryModel: s.ovhPrimaryModel,
      fallbackModel: s.ovhFallbackModel,
    );
    _vertexConfig = _ProviderConfig(
      baseUrl: s.vertexAiBaseUrl,
      serviceAccountJson: s.vertexAiServiceAccountJson,
      primaryModel: s.vertexAiPrimaryModel,
      fallbackModel: s.vertexAiFallbackModel,
    );
  }

  Future<void> _openSettings(LlmProvider provider) async {
    final isVertex = provider == LlmProvider.vertexAi;
    final config = isVertex ? _vertexConfig : _ovhConfig;

    final result = await showDialog<_ProviderConfig>(
      context: context,
      builder: (_) => _ProviderSettingsDialog(
        title: isVertex ? 'Vertex AI' : 'OVH AI',
        config: config,
        primaryModelHint: isVertex
            ? AppConstants.geminiFlashModel
            : AppConstants.defaultLlmModel,
        fallbackModelHint: isVertex
            ? AppConstants.geminiFlashLiteModel
            : AppConstants.mistralModel,
        isVertex: isVertex,
      ),
    );

    if (result != null) {
      setState(() {
        if (isVertex) {
          _vertexConfig = result;
        } else {
          _ovhConfig = result;
        }
      });
    }
  }

  void _save(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    cubit.update(cubit.state.settings.copyWith(
      activeProvider:
          _activeProvider == LlmProvider.vertexAi ? 'vertexAi' : 'ovh',
      ovhBaseUrl: _ovhConfig.baseUrl,
      ovhApiKey: _ovhConfig.apiKey,
      ovhPrimaryModel: _ovhConfig.primaryModel,
      ovhFallbackModel: _ovhConfig.fallbackModel,
      vertexAiBaseUrl: _vertexConfig.baseUrl,
      vertexAiServiceAccountJson: _vertexConfig.serviceAccountJson,
      vertexAiPrimaryModel: _vertexConfig.primaryModel,
      vertexAiFallbackModel: _vertexConfig.fallbackModel,
    ));
    cubit.save();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (_, _) {},
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

                  // ── LLM Providers ──────────────────────────────────────────
                  Text('LLM Providers',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Toggle a provider to make it the active service. '
                    'Tap the settings icon to configure its URL, key, and models.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  _ProviderCard(
                    title: 'OVH AI',
                    config: _ovhConfig,
                    isActive: _activeProvider == LlmProvider.ovh,
                    onActivate: () {
                      setState(() => _activeProvider = LlmProvider.ovh);
                      _save(context);
                    },
                    onConfigure: () => _openSettings(LlmProvider.ovh),
                  ),
                  const SizedBox(height: 12),
                  _ProviderCard(
                    title: 'Vertex AI',
                    config: _vertexConfig,
                    isActive: _activeProvider == LlmProvider.vertexAi,
                    onActivate: () {
                      setState(() => _activeProvider = LlmProvider.vertexAi);
                      _save(context);
                    },
                    onConfigure: () => _openSettings(LlmProvider.vertexAi),
                  ),
                  const SizedBox(height: 32),

                  // ── Behaviour ──────────────────────────────────────────────
                  Text('Behaviour',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          color:
                              Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: SwitchListTile(
                      title: const Text('Headless WebView'),
                      subtitle: const Text(
                          'Run WebView without a visible window'
                          ' (not supported on all platforms)'),
                      value: state.settings.browserHeadless,
                      onChanged: (v) {
                        cubit.update(state.settings.copyWith(browserHeadless: v));
                        cubit.save();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Provider card widget
// ---------------------------------------------------------------------------

class _ProviderCard extends StatelessWidget {
  final String title;
  final _ProviderConfig config;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onConfigure;

  const _ProviderCard({
    required this.title,
    required this.config,
    required this.isActive,
    required this.onActivate,
    required this.onConfigure,
  });

  String _short(String model) => model.replaceFirst('google/', '');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
          width: isActive ? 2 : 1,
        ),
      ),
      color: isActive
          ? colorScheme.primaryContainer.withValues(alpha: 0.15)
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Primary: ${_short(config.primaryModel)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Fallback: ${_short(config.fallbackModel)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Configure',
              onPressed: onConfigure,
            ),
            GestureDetector(
              onTap: isActive ? null : onActivate,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Provider settings dialog
// ---------------------------------------------------------------------------

class _ProviderSettingsDialog extends StatefulWidget {
  final String title;
  final _ProviderConfig config;
  final String primaryModelHint;
  final String fallbackModelHint;
  final bool isVertex;

  const _ProviderSettingsDialog({
    required this.title,
    required this.config,
    required this.primaryModelHint,
    required this.fallbackModelHint,
    this.isVertex = false,
  });

  @override
  State<_ProviderSettingsDialog> createState() =>
      _ProviderSettingsDialogState();
}

class _ProviderSettingsDialogState extends State<_ProviderSettingsDialog> {
  late TextEditingController _baseUrlCtrl;
  late TextEditingController _apiKeyCtrl;
  late TextEditingController _serviceAccountJsonCtrl;
  late TextEditingController _primaryModelCtrl;
  late TextEditingController _fallbackModelCtrl;

  @override
  void initState() {
    super.initState();
    _baseUrlCtrl = TextEditingController(text: widget.config.baseUrl);
    _apiKeyCtrl = TextEditingController(text: widget.config.apiKey);
    _serviceAccountJsonCtrl =
        TextEditingController(text: widget.config.serviceAccountJson);
    _primaryModelCtrl =
        TextEditingController(text: widget.config.primaryModel);
    _fallbackModelCtrl =
        TextEditingController(text: widget.config.fallbackModel);
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    _serviceAccountJsonCtrl.dispose();
    _primaryModelCtrl.dispose();
    _fallbackModelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.title} — Configuration'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isVertex)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Replace YOUR_PROJECT_ID in the URL with your Google Cloud project ID.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              TextFormField(
                controller: _baseUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (widget.isVertex) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text('Service Account JSON',
                          style: Theme.of(context).textTheme.labelLarge),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.folder_open_outlined, size: 16),
                      label: const Text('Load file'),
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['json'],
                          dialogTitle: 'Select service account JSON key',
                        );
                        final path = result?.files.single.path;
                        if (path != null) {
                          final content = await File(path).readAsString();
                          setState(
                              () => _serviceAccountJsonCtrl.text = content);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _serviceAccountJsonCtrl,
                  decoration: const InputDecoration(
                    hintText: '{ "type": "service_account", ... }',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  minLines: 5,
                  maxLines: 10,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ] else
                TextFormField(
                  controller: _apiKeyCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 20),
              Text('Models', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextFormField(
                controller: _primaryModelCtrl,
                decoration: InputDecoration(
                  labelText: 'Primary model',
                  border: const OutlineInputBorder(),
                  hintText: widget.primaryModelHint,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fallbackModelCtrl,
                decoration: InputDecoration(
                  labelText: 'Fallback model (optional)',
                  border: const OutlineInputBorder(),
                  hintText: widget.fallbackModelHint,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _ProviderConfig(
              baseUrl: _baseUrlCtrl.text.trim(),
              apiKey: widget.isVertex ? '' : _apiKeyCtrl.text.trim(),
              serviceAccountJson: widget.isVertex
                  ? _serviceAccountJsonCtrl.text.trim()
                  : '',
              primaryModel: _primaryModelCtrl.text.trim(),
              fallbackModel: _fallbackModelCtrl.text.trim(),
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Model card (reused inside the dialog)
// ---------------------------------------------------------------------------
