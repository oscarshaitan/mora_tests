import 'dart:typed_data';

import 'package:flutter/material.dart';

class ScreenshotPanel extends StatelessWidget {
  final Uint8List bytes;
  final double? maxHeight;

  const ScreenshotPanel({
    super.key,
    required this.bytes,
    this.maxHeight = 300,
  });

  @override
  Widget build(BuildContext context) {
    if (bytes.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(
          child: Text('No screenshot', style: TextStyle(fontSize: 12)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
        child: Image.memory(
          bytes,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
