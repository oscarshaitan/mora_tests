import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/llm_action.dart';

/// Renders a visual overlay on top of the builder WebView to show the user
/// where/what the pending AI action will do before they accept or reject it.
///
/// Coordinates from the LLM are in physical pixels (screenshot resolution).
/// Divide by [dpr] to convert to the logical pixels used by the overlay.
class ActionOverlay extends StatelessWidget {
  final LlmAction action;
  final double dpr;

  const ActionOverlay({
    super.key,
    required this.action,
    required this.dpr,
  });

  @override
  Widget build(BuildContext context) {
    return switch (action.type) {
      ActionType.click => _CrosshairOverlay(
          x: action.x,
          y: action.y,
          dpr: dpr,
          rings: 1,
          color: Colors.blue,
          label: 'click',
        ),
      ActionType.doubleClick => _CrosshairOverlay(
          x: action.x,
          y: action.y,
          dpr: dpr,
          rings: 2,
          color: Colors.blue,
          label: 'double click',
        ),
      ActionType.longPress => _CrosshairOverlay(
          x: action.x,
          y: action.y,
          dpr: dpr,
          rings: 1,
          color: Colors.orange,
          label: 'long press',
          showHoldArc: true,
        ),
      ActionType.hover => _CrosshairOverlay(
          x: action.x,
          y: action.y,
          dpr: dpr,
          rings: 1,
          color: Colors.purple,
          label: 'hover',
          dashed: true,
        ),
      ActionType.type => _TypeOverlay(
          x: action.x,
          y: action.y,
          dpr: dpr,
          value: action.value ?? '',
        ),
      ActionType.selectOption => _TypeOverlay(
          x: action.x,
          y: action.y,
          dpr: dpr,
          value: action.value ?? '',
          label: 'select',
        ),
      ActionType.scroll => _ScrollOverlay(
          x: action.x,
          y: action.y,
          dpr: dpr,
          deltaY: action.scrollDeltaY ?? 0,
        ),
      ActionType.navigate => _BannerOverlay(
          text: action.url ?? 'Navigate',
          icon: Icons.public,
          color: Colors.indigo,
          position: _BannerPosition.top,
        ),
      ActionType.pressKey => _KeyCapOverlay(
          keyName: action.key ?? '?',
        ),
      ActionType.wait => _BannerOverlay(
          text: 'Wait ${action.waitMs ?? 0} ms',
          icon: Icons.hourglass_empty,
          color: Colors.grey,
          position: _BannerPosition.center,
        ),
      ActionType.assert_text || ActionType.assert_url ||
      ActionType.assert_visible =>
        _BannerOverlay(
          text: action.expectedText ??
              action.expectedUrl ??
              'Assert visible',
          icon: Icons.search,
          color: Colors.teal,
          position: _BannerPosition.bottom,
        ),
      ActionType.done => const _TerminalOverlay(
          icon: Icons.check_circle,
          color: Colors.green,
          label: 'Done',
        ),
      ActionType.fail => const _TerminalOverlay(
          icon: Icons.cancel,
          color: Colors.red,
          label: 'Fail',
        ),
    };
  }
}

// ── Crosshair overlay (click, doubleClick, longPress, hover) ─────────────────

class _CrosshairOverlay extends StatelessWidget {
  final double? x;
  final double? y;
  final double dpr;
  final int rings;
  final Color color;
  final String label;
  final bool dashed;
  final bool showHoldArc;

  const _CrosshairOverlay({
    required this.x,
    required this.y,
    required this.dpr,
    required this.rings,
    required this.color,
    required this.label,
    this.dashed = false,
    this.showHoldArc = false,
  });

  @override
  Widget build(BuildContext context) {
    if (x == null || y == null) return const SizedBox.shrink();
    final lx = x! / dpr;
    final ly = y! / dpr;

    return Stack(
      children: [
        // Crosshair lines
        Positioned(
          left: lx,
          top: 0,
          bottom: 0,
          child: Container(
            width: 1,
            color: color.withValues(alpha: 0.3),
          ),
        ),
        Positioned(
          top: ly,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            color: color.withValues(alpha: 0.3),
          ),
        ),
        // Ring(s)
        for (int i = 0; i < rings; i++)
          Positioned(
            left: lx - 12 - (i * 6),
            top: ly - 12 - (i * 6),
            child: _PulsingRing(
              size: 24.0 + (i * 12),
              color: color,
              dashed: dashed,
            ),
          ),
        // Hold arc for long press
        if (showHoldArc)
          Positioned(
            left: lx - 14,
            top: ly - 14,
            child: _HoldArcIndicator(color: color),
          ),
        // Center dot
        Positioned(
          left: lx - 3,
          top: ly - 3,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
        // Label
        Positioned(
          left: lx + 16,
          top: ly - 10,
          child: _ActionLabel(text: label, color: color),
        ),
      ],
    );
  }
}

// ── Type overlay (type, selectOption) ────────────────────────────────────────

class _TypeOverlay extends StatelessWidget {
  final double? x;
  final double? y;
  final double dpr;
  final String value;
  final String label;

  const _TypeOverlay({
    required this.x,
    required this.y,
    required this.dpr,
    required this.value,
    this.label = 'type',
  });

  @override
  Widget build(BuildContext context) {
    if (x == null || y == null) return const SizedBox.shrink();
    final lx = x! / dpr;
    final ly = y! / dpr;

    return Stack(
      children: [
        // Crosshair at click-to-focus point
        Positioned(
          left: lx - 8,
          top: ly - 8,
          child: _PulsingRing(size: 16, color: Colors.green),
        ),
        Positioned(
          left: lx - 2,
          top: ly - 2,
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
          ),
        ),
        // Text bubble above the target
        Positioned(
          left: (lx - 60).clamp(4, double.infinity),
          top: (ly - 44).clamp(4, double.infinity),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade800.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  label == 'select'
                      ? Icons.arrow_drop_down_circle
                      : Icons.keyboard,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '"$value"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Scroll overlay ───────────────────────────────────────────────────────────

class _ScrollOverlay extends StatelessWidget {
  final double? x;
  final double? y;
  final double dpr;
  final int deltaY;

  const _ScrollOverlay({
    required this.x,
    required this.y,
    required this.dpr,
    required this.deltaY,
  });

  @override
  Widget build(BuildContext context) {
    // Center the arrow in the viewport if no coordinates given
    final lx = x != null ? x! / dpr : null;
    final ly = y != null ? y! / dpr : null;
    final isDown = deltaY > 0;

    return Stack(
      children: [
        Positioned(
          left: lx != null ? lx - 20 : null,
          top: ly != null ? ly - 30 : null,
          right: lx == null ? 0 : null,
          bottom: ly == null ? 0 : null,
          child: lx == null
              ? Center(child: _scrollContent(isDown))
              : _scrollContent(isDown),
        ),
      ],
    );
  }

  Widget _scrollContent(bool isDown) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade800.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDown ? Icons.arrow_downward : Icons.arrow_upward,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 2),
          Text(
            '${deltaY.abs()} px',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banner overlay (navigate, wait, assert) ──────────────────────────────────

enum _BannerPosition { top, center, bottom }

class _BannerOverlay extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final _BannerPosition position;

  const _BannerOverlay({
    required this.text,
    required this.icon,
    required this.color,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final banner = Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );

    return switch (position) {
      _BannerPosition.top => Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(child: banner),
        ),
      _BannerPosition.center => Center(child: banner),
      _BannerPosition.bottom => Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Center(child: banner),
        ),
    };
  }
}

// ── Key cap overlay (pressKey) ───────────────────────────────────────────────

class _KeyCapOverlay extends StatelessWidget {
  final String keyName;
  const _KeyCapOverlay({required this.keyName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade800.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade500, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          '[$keyName]',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Terminal overlay (done, fail) ────────────────────────────────────────────

class _TerminalOverlay extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _TerminalOverlay({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: color.withValues(alpha: 0.8)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared: pulsing ring ─────────────────────────────────────────────────────

class _PulsingRing extends StatefulWidget {
  final double size;
  final Color color;
  final bool dashed;

  const _PulsingRing({
    required this.size,
    required this.color,
    this.dashed = false,
  });

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final scale = 1.0 + _ctrl.value * 0.25;
        final opacity = 0.8 - _ctrl.value * 0.4;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withValues(alpha: opacity),
                width: widget.dashed ? 1.5 : 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Shared: hold-arc indicator for long press ────────────────────────────────

class _HoldArcIndicator extends StatefulWidget {
  final Color color;
  const _HoldArcIndicator({required this.color});

  @override
  State<_HoldArcIndicator> createState() => _HoldArcIndicatorState();
}

class _HoldArcIndicatorState extends State<_HoldArcIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return CustomPaint(
          size: const Size(28, 28),
          painter: _ArcPainter(
            progress: _ctrl.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, -math.pi / 2, progress * 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ── Shared: action label ─────────────────────────────────────────────────────

class _ActionLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _ActionLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
