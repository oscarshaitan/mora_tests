import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/builder/builder_cubit.dart';
import '../../models/http_hook.dart';
import '../../models/test_case.dart';
import 'step_list_editor.dart';

class TestForm extends StatefulWidget {
  final TestCase test;
  const TestForm({super.key, required this.test});

  @override
  State<TestForm> createState() => _TestFormState();
}

class _TestFormState extends State<TestForm> {
  late TextEditingController _nameCtrl;
  late TextEditingController _urlCtrl;
  late TextEditingController _descCtrl;

  // Seeder
  bool _seederEnabled = false;
  late TextEditingController _seederUrlCtrl;
  late TextEditingController _seederBodyCtrl;
  String _seederMethod = 'POST';

  // Teardown
  bool _teardownEnabled = false;
  late TextEditingController _teardownUrlCtrl;
  late TextEditingController _teardownBodyCtrl;
  String _teardownMethod = 'DELETE';

  @override
  void initState() {
    super.initState();
    _initControllers(widget.test);
  }

  void _initControllers(TestCase test) {
    _nameCtrl = TextEditingController(text: test.name);
    _urlCtrl = TextEditingController(text: test.startUrl);
    _descCtrl = TextEditingController(text: test.description);

    _seederEnabled = test.seeder != null;
    _seederUrlCtrl = TextEditingController(text: test.seeder?.url ?? '');
    _seederBodyCtrl = TextEditingController(text: test.seeder?.body ?? '');
    _seederMethod = test.seeder?.method ?? 'POST';

    _teardownEnabled = test.teardown != null;
    _teardownUrlCtrl = TextEditingController(text: test.teardown?.url ?? '');
    _teardownBodyCtrl = TextEditingController(text: test.teardown?.body ?? '');
    _teardownMethod = test.teardown?.method ?? 'DELETE';
  }

  @override
  void didUpdateWidget(TestForm old) {
    super.didUpdateWidget(old);
    if (old.test.id != widget.test.id) {
      _disposeControllers();
      _initControllers(widget.test);
    }
  }

  void _disposeControllers() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _descCtrl.dispose();
    _seederUrlCtrl.dispose();
    _seederBodyCtrl.dispose();
    _teardownUrlCtrl.dispose();
    _teardownBodyCtrl.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _pushUpdate(BuildContext context) {
    final cubit = context.read<BuilderCubit>();
    final test = widget.test.copyWith(
      name: _nameCtrl.text,
      startUrl: _urlCtrl.text,
      description: _descCtrl.text,
      seeder: _seederEnabled
          ? HttpHook(
              url: _seederUrlCtrl.text,
              method: _seederMethod,
              body: _seederBodyCtrl.text.isEmpty ? null : _seederBodyCtrl.text,
            )
          : null,
      teardown: _teardownEnabled
          ? HttpHook(
              url: _teardownUrlCtrl.text,
              method: _teardownMethod,
              body: _teardownBodyCtrl.text.isEmpty
                  ? null
                  : _teardownBodyCtrl.text,
            )
          : null,
    );
    cubit.updateTest(test);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuilderCubit>();

    return Column(
      children: [
        // Toolbar
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.test.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: cubit.save,
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Save'),
              ),
              TextButton.icon(
                onPressed: cubit.saveAs,
                icon: const Icon(Icons.save_as, size: 16),
                label: const Text('Save As'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic fields
                _field(
                  context,
                  controller: _nameCtrl,
                  label: 'Name',
                  onChanged: (_) => _pushUpdate(context),
                ),
                const SizedBox(height: 10),
                _field(
                  context,
                  controller: _urlCtrl,
                  label: 'Start URL',
                  onChanged: (_) => _pushUpdate(context),
                ),
                const SizedBox(height: 10),
                _field(
                  context,
                  controller: _descCtrl,
                  label: 'Description (optional)',
                  onChanged: (_) => _pushUpdate(context),
                ),
                const SizedBox(height: 16),

                // Seeder
                _HookSection(
                  title: 'Seeder',
                  subtitle: 'Called before the test runs',
                  enabled: _seederEnabled,
                  urlCtrl: _seederUrlCtrl,
                  bodyCtrl: _seederBodyCtrl,
                  method: _seederMethod,
                  onEnabledChanged: (v) {
                    setState(() => _seederEnabled = v);
                    _pushUpdate(context);
                  },
                  onMethodChanged: (v) {
                    setState(() => _seederMethod = v!);
                    _pushUpdate(context);
                  },
                  onChanged: () => _pushUpdate(context),
                ),
                const SizedBox(height: 12),

                // Teardown
                _HookSection(
                  title: 'Teardown',
                  subtitle: 'Called after the test completes (always)',
                  enabled: _teardownEnabled,
                  urlCtrl: _teardownUrlCtrl,
                  bodyCtrl: _teardownBodyCtrl,
                  method: _teardownMethod,
                  onEnabledChanged: (v) {
                    setState(() => _teardownEnabled = v);
                    _pushUpdate(context);
                  },
                  onMethodChanged: (v) {
                    setState(() => _teardownMethod = v!);
                    _pushUpdate(context);
                  },
                  onChanged: () => _pushUpdate(context),
                ),
                const SizedBox(height: 16),

                // Variables
                _VariablesEditor(
                  test: widget.test,
                  onChanged: (vars) {
                    cubit.updateTest(widget.test.copyWith(variables: vars));
                  },
                ),
                const SizedBox(height: 16),

                // Steps
                Text('Steps',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                StepListEditor(test: widget.test),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}

// ── Hook Section ────────────────────────────────────────────────────────────

class _HookSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool enabled;
  final TextEditingController urlCtrl;
  final TextEditingController bodyCtrl;
  final String method;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<String?> onMethodChanged;
  final VoidCallback onChanged;

  const _HookSection({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.urlCtrl,
    required this.bodyCtrl,
    required this.method,
    required this.onEnabledChanged,
    required this.onMethodChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(subtitle,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Switch(value: enabled, onChanged: onEnabledChanged),
              ],
            ),
            if (enabled) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  DropdownButton<String>(
                    value: method,
                    isDense: true,
                    items: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: onMethodChanged,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: urlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: bodyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Body (JSON, optional)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 3,
                onChanged: (_) => onChanged(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Variables Editor ────────────────────────────────────────────────────────

class _VariablesEditor extends StatefulWidget {
  final TestCase test;
  final ValueChanged<Map<String, String>> onChanged;

  const _VariablesEditor({required this.test, required this.onChanged});

  @override
  State<_VariablesEditor> createState() => _VariablesEditorState();
}

class _VariablesEditorState extends State<_VariablesEditor> {
  late List<_VarEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.test.variables.entries
        .map((e) => _VarEntry(
              keyCtrl: TextEditingController(text: e.key),
              valCtrl: TextEditingController(text: e.value),
            ))
        .toList();
  }

  @override
  void didUpdateWidget(_VariablesEditor old) {
    super.didUpdateWidget(old);
    if (old.test.id != widget.test.id) {
      for (final e in _entries) {
        e.keyCtrl.dispose();
        e.valCtrl.dispose();
      }
      _entries = widget.test.variables.entries
          .map((e) => _VarEntry(
                keyCtrl: TextEditingController(text: e.key),
                valCtrl: TextEditingController(text: e.value),
              ))
          .toList();
    }
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.keyCtrl.dispose();
      e.valCtrl.dispose();
    }
    super.dispose();
  }

  void _notify() {
    widget.onChanged({
      for (final e in _entries)
        if (e.keyCtrl.text.isNotEmpty) e.keyCtrl.text: e.valCtrl.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Variables',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              tooltip: 'Add variable',
              onPressed: () {
                setState(() {
                  _entries.add(_VarEntry(
                    keyCtrl: TextEditingController(),
                    valCtrl: TextEditingController(),
                  ));
                });
              },
            ),
          ],
        ),
        ...List.generate(_entries.length, (i) {
          final entry = _entries[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: entry.keyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Key',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _notify(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: entry.valCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _notify(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      _entries[i].keyCtrl.dispose();
                      _entries[i].valCtrl.dispose();
                      _entries.removeAt(i);
                    });
                    _notify();
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _VarEntry {
  final TextEditingController keyCtrl;
  final TextEditingController valCtrl;
  _VarEntry({required this.keyCtrl, required this.valCtrl});
}
