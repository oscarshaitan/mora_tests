import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/builder/builder_cubit.dart';
import '../../models/test_case.dart';
import '../../models/test_step.dart';

class StepListEditor extends StatelessWidget {
  final TestCase test;
  const StepListEditor({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuilderCubit>();

    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: test.steps.length,
          onReorder: cubit.reorderSteps,
          itemBuilder: (context, i) {
            final step = test.steps[i];
            return _StepCard(
              key: ValueKey(step.id),
              step: step,
              index: i,
              onChanged: (updated) {
                final steps = [...test.steps];
                steps[i] = updated;
                cubit.updateTest(test.copyWith(steps: steps));
              },
              onDelete: () => cubit.removeStep(step.id),
            );
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: cubit.addStep,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Step'),
        ),
      ],
    );
  }
}

class _StepCard extends StatefulWidget {
  final TestStep step;
  final int index;
  final ValueChanged<TestStep> onChanged;
  final VoidCallback onDelete;

  const _StepCard({
    super.key,
    required this.step,
    required this.index,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  late TextEditingController _instructionCtrl;
  late TextEditingController _hintCtrl;
  late TextEditingController _assertCtrl;
  late TextEditingController _timeoutCtrl;
  late TextEditingController _subStepsCtrl;
  late bool _exploreMode;

  @override
  void initState() {
    super.initState();
    _exploreMode = widget.step.maxSubSteps != null;
    _instructionCtrl =
        TextEditingController(text: widget.step.instruction);
    _hintCtrl = TextEditingController(text: widget.step.hint ?? '');
    _assertCtrl = TextEditingController(text: widget.step.assertion ?? '');
    _timeoutCtrl =
        TextEditingController(text: widget.step.timeoutSeconds.toString());
    _subStepsCtrl = TextEditingController(
        text: (widget.step.maxSubSteps ?? 10).toString());
  }

  @override
  void didUpdateWidget(_StepCard old) {
    super.didUpdateWidget(old);
    if (old.step.id != widget.step.id) {
      _exploreMode = widget.step.maxSubSteps != null;
      _instructionCtrl.text = widget.step.instruction;
      _hintCtrl.text = widget.step.hint ?? '';
      _assertCtrl.text = widget.step.assertion ?? '';
      _timeoutCtrl.text = widget.step.timeoutSeconds.toString();
      _subStepsCtrl.text = (widget.step.maxSubSteps ?? 10).toString();
    }
  }

  @override
  void dispose() {
    _instructionCtrl.dispose();
    _hintCtrl.dispose();
    _assertCtrl.dispose();
    _timeoutCtrl.dispose();
    _subStepsCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(widget.step.copyWith(
      instruction: _instructionCtrl.text,
      hint: _hintCtrl.text.isEmpty ? null : _hintCtrl.text,
      assertion: _assertCtrl.text.isEmpty ? null : _assertCtrl.text,
      timeoutSeconds: int.tryParse(_timeoutCtrl.text) ?? 30,
      maxSubSteps:
          _exploreMode ? (int.tryParse(_subStepsCtrl.text) ?? 10) : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Icon(
                      Icons.drag_handle,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Step ${widget.index + 1}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: widget.onDelete,
                  tooltip: 'Remove step',
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                labelText: 'Assert (optional — condition to verify after action)',
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
                const SizedBox(width: 16),
                // ── Explore mode toggle ──────────────────────────────────
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    setState(() => _exploreMode = !_exploreMode);
                    _notify();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: _exploreMode,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (v) {
                            setState(() => _exploreMode = v);
                            _notify();
                          },
                        ),
                        const SizedBox(width: 4),
                        const Text('Explore mode'),
                      ],
                    ),
                  ),
                ),
                // Sub-steps count — only shown when explore mode is on
                if (_exploreMode) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 90,
                    child: TextFormField(
                      controller: _subStepsCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Sub-steps',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _notify(),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
