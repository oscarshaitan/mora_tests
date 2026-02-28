import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/builder/builder_cubit.dart';
import '../../cubits/builder/builder_state.dart';
import '../../models/test_case.dart';
import 'test_form.dart';

class BuilderScreen extends StatelessWidget {
  const BuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuilderCubit, BuilderState>(
      builder: (context, state) {
        return Row(
          children: [
            // Left: Test List
            SizedBox(
              width: 240,
              child: _TestList(state: state),
            ),
            const VerticalDivider(width: 1),
            // Right: Editor
            Expanded(
              child: state.selectedTest != null
                  ? TestForm(test: state.selectedTest!)
                  : const _EmptyEditor(),
            ),
          ],
        );
      },
    );
  }
}

class _TestList extends StatelessWidget {
  final BuilderState state;
  const _TestList({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuilderCubit>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: cubit.createNewTest,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Test'),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.folder_open),
                tooltip: 'Open YAML file',
                onPressed: cubit.openFile,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: state.testCases.length,
            itemBuilder: (context, i) {
              final test = state.testCases[i];
              final selected = state.selectedTest?.id == test.id;
              return ListTile(
                selected: selected,
                title: Text(
                  test.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${test.steps.length} step${test.steps.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () => cubit.selectTest(test),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _confirmDelete(context, cubit, test),
                ),
              );
            },
          ),
        ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              state.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    BuilderCubit cubit,
    TestCase test,
  ) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete test?'),
        content: Text('Delete "${test.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) cubit.deleteTest(test.id);
    });
  }
}

class _EmptyEditor extends StatelessWidget {
  const _EmptyEditor();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_note,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Select or create a test to edit',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
