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

    return Tooltip(
      message: 'Click to zoom',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _openLightbox(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: maxHeight ?? double.infinity),
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  void _openLightbox(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            // Full-resolution image — pinch / scroll to zoom
            InteractiveViewer(
              minScale: 0.3,
              maxScale: 5.0,
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
            // Close button overlay
            Padding(
              padding: const EdgeInsets.all(4),
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
