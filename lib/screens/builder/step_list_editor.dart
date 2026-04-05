import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/builder/builder_cubit.dart';
import '../../cubits/builder/builder_state.dart';
import '../../models/llm_action.dart';
import '../../models/test_case.dart';
import '../../models/test_step.dart';

enum _StepMode { normal, call }

class StepListEditor extends StatelessWidget {
  final TestCase test;
  const StepListEditor({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuilderCubit>();

    return BlocBuilder<BuilderCubit, BuilderState>(
      buildWhen: (prev, curr) =>
          prev.resolvingStepId != curr.resolvingStepId ||
          prev.pendingStepId != curr.pendingStepId ||
          prev.pendingAction != curr.pendingAction,
      builder: (context, builderState) {
        return Column(
          children: [
            _InsertDivider(onInsert: () => cubit.addStepAt(0)),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              padding: EdgeInsets.zero,
              itemCount: test.steps.length,
              onReorder: cubit.reorderSteps,
              itemBuilder: (context, i) {
                final step = test.steps[i];
                return Column(
                  key: ValueKey(step.id),
                  children: [
                    _StepCard(
                      step: step,
                      index: i,
                      isResolving:
                          builderState.resolvingStepId == step.id,
                      pendingAction:
                          builderState.pendingStepId == step.id
                              ? builderState.pendingAction
                              : null,
                      onChanged: (updated) {
                        final steps = [...test.steps];
                        steps[i] = updated;
                        cubit.updateTest(test.copyWith(steps: steps));
                      },
                      onDelete: () => cubit.removeStep(step.id),
                    ),
                    if (i < test.steps.length - 1)
                      _InsertDivider(
                        onInsert: () => cubit.addStepAt(i + 1),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: cubit.addStep,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Step'),
            ),
          ],
        );
      },
    );
  }
}

class _StepCard extends StatefulWidget {
  final TestStep step;
  final int index;
  final bool isResolving;
  final LlmAction? pendingAction;
  final ValueChanged<TestStep> onChanged;
  final VoidCallback onDelete;

  const _StepCard({
    required this.step,
    required this.index,
    required this.isResolving,
    required this.pendingAction,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  late _StepMode _mode;
  late TextEditingController _instructionCtrl;
  late TextEditingController _hintCtrl;
  late TextEditingController _assertCtrl;
  late TextEditingController _timeoutCtrl;
  late TextEditingController _callCtrl;
  late List<_WithVarEntry> _withVarsEntries;

  @override
  void initState() {
    super.initState();
    _initFrom(widget.step);
  }

  void _initFrom(TestStep step) {
    _mode = step.call != null ? _StepMode.call : _StepMode.normal;
    _instructionCtrl = TextEditingController(text: step.instruction);
    _hintCtrl = TextEditingController(text: step.hint ?? '');
    _assertCtrl = TextEditingController(text: step.assertion ?? '');
    _timeoutCtrl = TextEditingController(text: step.timeoutSeconds.toString());
    _callCtrl = TextEditingController(text: step.call ?? '');
    _withVarsEntries = step.withVars.entries
        .map((e) => _WithVarEntry(
              keyCtrl: TextEditingController(text: e.key),
              valCtrl: TextEditingController(text: e.value),
            ))
        .toList();
  }

  void _disposeControllers() {
    _instructionCtrl.dispose();
    _hintCtrl.dispose();
    _assertCtrl.dispose();
    _timeoutCtrl.dispose();
    _callCtrl.dispose();
    for (final e in _withVarsEntries) {
      e.keyCtrl.dispose();
      e.valCtrl.dispose();
    }
  }

  @override
  void didUpdateWidget(_StepCard old) {
    super.didUpdateWidget(old);
    if (old.step.id != widget.step.id) {
      _disposeControllers();
      _initFrom(widget.step);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(widget.step.copyWith(
      instruction: _mode == _StepMode.call ? '' : _instructionCtrl.text,
      hint: _mode == _StepMode.call || _hintCtrl.text.isEmpty
          ? null
          : _hintCtrl.text,
      assertion: _mode == _StepMode.call || _assertCtrl.text.isEmpty
          ? null
          : _assertCtrl.text,
      timeoutSeconds: int.tryParse(_timeoutCtrl.text) ?? 30,
      call: _mode == _StepMode.call
          ? (_callCtrl.text.isEmpty ? null : _callCtrl.text)
          : null,
      withVars: _mode == _StepMode.call
          ? {
              for (final e in _withVarsEntries)
                if (e.keyCtrl.text.isNotEmpty) e.keyCtrl.text: e.valCtrl.text,
            }
          : const {},
    ));
  }

  bool get _isCoordWarning =>
      widget.step.instruction.contains('coordinate ');

  bool get _isIncomplete {
    final s = widget.step;
    if (s.call != null) return s.call!.trim().isEmpty;
    return s.instruction.trim().isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasCoordWarning = _isCoordWarning;
    final incomplete = _isIncomplete;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: incomplete
              ? colorScheme.error
              : hasCoordWarning
                  ? Colors.amber.shade600
                  : colorScheme.outlineVariant,
          width: (incomplete || hasCoordWarning) ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Incomplete step banner ─────────────────────────────────
            if (incomplete) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: 16, color: colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.step.call != null
                            ? 'Call path is empty — add a YAML file path'
                            : 'Instruction is empty — this step will be skipped',
                        style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            // ── Coordinate warning banner ──────────────────────────────
            if (hasCoordWarning && !incomplete) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: Colors.amber.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Screen coordinates detected — consider updating the instruction to use a text or id selector',
                        style: TextStyle(
                            fontSize: 12, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            // ── Header row ────────────────────────────────────────────
            Row(
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Icon(Icons.drag_handle,
                        size: 20, color: colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Step ${widget.index + 1}',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: widget.onDelete,
                  tooltip: 'Remove step',
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Mode selector ─────────────────────────────────────────
            SegmentedButton<_StepMode>(
              segments: const [
                ButtonSegment(
                  value: _StepMode.normal,
                  label: Text('Normal'),
                  icon: Icon(Icons.play_arrow_outlined, size: 16),
                ),
                ButtonSegment(
                  value: _StepMode.call,
                  label: Text('Call sub-test'),
                  icon: Icon(Icons.call_merge, size: 16),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) {
                setState(() => _mode = s.first);
                _notify();
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 14),

            // ── Normal / Explore fields ────────────────────────────────
            if (_mode != _StepMode.call) ...[
              TextFormField(
                controller: _instructionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Instruction *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                minLines: 1,
                maxLines: null,
                onChanged: (_) => _notify(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _hintCtrl,
                decoration: const InputDecoration(
                  labelText: 'Hint (optional — helps LLM identify elements)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                minLines: 1,
                maxLines: null,
                onChanged: (_) => _notify(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _assertCtrl,
                decoration: const InputDecoration(
                  labelText:
                      'Assert (optional — condition to verify after action)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                minLines: 1,
                maxLines: null,
                onChanged: (_) => _notify(),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _timeoutCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Timeout (sec)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _notify(),
                    ),
                  ),
                ],
              ),

              // ── AI Coop Controls ───────────────────────────────────
              const SizedBox(height: 14),
              _AiCoopSection(
                step: widget.step,
                mode: _mode,
                isResolving: widget.isResolving,
                pendingAction: widget.pendingAction,
              ),
            ],

            // ── Call sub-test fields ───────────────────────────────────
            if (_mode == _StepMode.call) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _callCtrl,
                      decoration: const InputDecoration(
                        labelText: 'YAML file path (relative to this file)',
                        hintText: 'shared/login.yaml',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon:
                            Icon(Icons.insert_drive_file_outlined, size: 18),
                      ),
                      onChanged: (_) => _notify(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Browse for YAML file',
                    icon: const Icon(Icons.folder_open_outlined),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['yaml'],
                        dialogTitle: 'Select sub-test YAML',
                      );
                      final path = result?.files.single.path;
                      if (path != null) {
                        setState(() => _callCtrl.text = path);
                        _notify();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── withVars editor ──────────────────────────────────────
              Row(
                children: [
                  Text('Variables to pass',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    tooltip: 'Add variable',
                    onPressed: () {
                      setState(() {
                        _withVarsEntries.add(_WithVarEntry(
                          keyCtrl: TextEditingController(),
                          valCtrl: TextEditingController(),
                        ));
                      });
                    },
                  ),
                ],
              ),
              if (_withVarsEntries.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'No variables — the sub-test runs with its own defaults.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ...List.generate(_withVarsEntries.length, (i) {
                final entry = _withVarsEntries[i];
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
                            _withVarsEntries[i].keyCtrl.dispose();
                            _withVarsEntries[i].valCtrl.dispose();
                            _withVarsEntries.removeAt(i);
                          });
                          _notify();
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ── AI Coop Section ──────────────────────────────────────────────────────────

class _AiCoopSection extends StatelessWidget {
  final TestStep step;
  final _StepMode mode;
  final bool isResolving;
  final LlmAction? pendingAction;

  const _AiCoopSection({
    required this.step,
    required this.mode,
    required this.isResolving,
    required this.pendingAction,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuilderCubit>();
    final cs = Theme.of(context).colorScheme;

    // Show pending action preview with accept/reject
    if (pendingAction != null) {
      return _PendingActionCard(action: pendingAction!);
    }

    // Show resolved badge if step already has a pre-computed action
    if (step.resolvedAction != null) {
      return _ResolvedBadge(action: step.resolvedAction!, stepId: step.id);
    }

    // Show loading spinner while resolving
    if (isResolving) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Asking AI...',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    // Show "Ask AI" button
    final canResolve = step.instruction.trim().isNotEmpty;
    return OutlinedButton.icon(
      onPressed: canResolve ? () => cubit.resolveStep(step.id) : null,
      icon: const Icon(Icons.psychology_outlined, size: 16),
      label: const Text('Ask AI'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ── Pending Action Card (accept / reject) ────────────────────────────────────

class _PendingActionCard extends StatelessWidget {
  final LlmAction action;
  const _PendingActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuilderCubit>();
    final cs = Theme.of(context).colorScheme;
    final confidence = '${(action.confidence * 100).toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'AI suggests: ${action.type.name}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  confidence,
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          if (action.x != null && action.y != null) ...[
            const SizedBox(height: 4),
            Text(
              'at (${action.x!.toStringAsFixed(0)}, ${action.y!.toStringAsFixed(0)})',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
          if (action.value != null) ...[
            const SizedBox(height: 4),
            Text(
              'value: "${action.value}"',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
          if (action.cssSelector != null) ...[
            const SizedBox(height: 4),
            Text(
              'selector: ${action.cssSelector}',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
          if (action.reasoning.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              action.reasoning,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: cubit.rejectAction,
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.error,
                  side: BorderSide(color: cs.error),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: cubit.acceptAction,
                icon: const Icon(Icons.check, size: 14),
                label: const Text('Accept'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Resolved Badge ───────────────────────────────────────────────────────────

class _ResolvedBadge extends StatelessWidget {
  final LlmAction action;
  final String stepId;
  const _ResolvedBadge({required this.action, required this.stepId});

  String get _label {
    final parts = <String>[action.type.name];
    if (action.x != null && action.y != null) {
      parts.add(
          'at (${action.x!.toStringAsFixed(0)}, ${action.y!.toStringAsFixed(0)})');
    }
    if (action.value != null) {
      final v = action.value!.length > 20
          ? '${action.value!.substring(0, 17)}...'
          : action.value!;
      parts.add('"$v"');
    }
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuilderCubit>();
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 16, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _label,
              style: TextStyle(fontSize: 12, color: Colors.green.shade900),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () => cubit.clearResolvedAction(stepId),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 14, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Insert Divider ───────────────────────────────────────────────────────────

class _InsertDivider extends StatefulWidget {
  final VoidCallback onInsert;
  const _InsertDivider({required this.onInsert});

  @override
  State<_InsertDivider> createState() => _InsertDividerState();
}

class _InsertDividerState extends State<_InsertDivider> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SizedBox(
        height: 20,
        child: Row(
          children: [
            Expanded(
              child: Divider(
                height: 1,
                color: _hovered
                    ? cs.primary
                    : cs.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: widget.onInsert,
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _hovered
                      ? cs.primaryContainer
                      : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _hovered
                        ? cs.primary
                        : cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add,
                        size: 12,
                        color: _hovered
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(
                      'Insert step',
                      style: TextStyle(
                        fontSize: 10,
                        color: _hovered
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Divider(
                height: 1,
                color: _hovered
                    ? cs.primary
                    : cs.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _WithVarEntry {
  final TextEditingController keyCtrl;
  final TextEditingController valCtrl;
  _WithVarEntry({required this.keyCtrl, required this.valCtrl});
}
