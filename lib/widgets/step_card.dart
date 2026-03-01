import 'package:flutter/material.dart';

import '../models/step_result.dart';
import '../models/test_step.dart';

enum StepCardStatus { pending, running, passed, failed }

class StepCard extends StatelessWidget {
  final int index;
  final TestStep step;
  final StepCardStatus status;
  final StepResult? result;

  const StepCard({
    super.key,
    required this.index,
    required this.step,
    required this.status,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      StepCardStatus.pending => (Icons.radio_button_unchecked, Colors.grey),
      StepCardStatus.running => (Icons.pending, Colors.blue),
      StepCardStatus.passed => (Icons.check_circle, Colors.green),
      StepCardStatus.failed => (Icons.cancel, Colors.red),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: status == StepCardStatus.running
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: status == StepCardStatus.running
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          status == StepCardStatus.running
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  step.instruction,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (step.hint != null && step.hint!.isNotEmpty)
                  Text(
                    'Hint: ${step.hint}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (result?.errorMessage != null)
                  Text(
                    result!.errorMessage!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
