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

  @override
  void initState() {
    super.initState();
    _instructionCtrl =
        TextEditingController(text: widget.step.instruction);
    _hintCtrl = TextEditingController(text: widget.step.hint ?? '');
    _assertCtrl = TextEditingController(text: widget.step.assertion ?? '');
    _timeoutCtrl =
        TextEditingController(text: widget.step.timeoutSeconds.toString());
  }

  @override
  void didUpdateWidget(_StepCard old) {
    super.didUpdateWidget(old);
    if (old.step.id != widget.step.id) {
      _instructionCtrl.text = widget.step.instruction;
      _hintCtrl.text = widget.step.hint ?? '';
      _assertCtrl.text = widget.step.assertion ?? '';
      _timeoutCtrl.text = widget.step.timeoutSeconds.toString();
    }
  }

  @override
  void dispose() {
    _instructionCtrl.dispose();
    _hintCtrl.dispose();
    _assertCtrl.dispose();
    _timeoutCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(widget.step.copyWith(
      instruction: _instructionCtrl.text,
      hint: _hintCtrl.text.isEmpty ? null : _hintCtrl.text,
      assertion: _assertCtrl.text.isEmpty ? null : _assertCtrl.text,
      timeoutSeconds: int.tryParse(_timeoutCtrl.text) ?? 30,
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.drag_handle, size: 20),
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
            const SizedBox(height: 8),
            TextFormField(
              controller: _instructionCtrl,
              decoration: const InputDecoration(
                labelText: 'Instruction *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
              onChanged: (_) => _notify(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hintCtrl,
              decoration: const InputDecoration(
                labelText: 'Hint (optional — helps LLM identify elements)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
              onChanged: (_) => _notify(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _assertCtrl,
              decoration: const InputDecoration(
                labelText: 'Assert (optional — condition to verify after action)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => _notify(),
            ),
            const SizedBox(height: 8),
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
      ),
    );
  }
}
