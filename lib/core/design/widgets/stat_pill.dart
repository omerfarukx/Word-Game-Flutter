import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../decorations.dart';

/// A compact label-over-value tile used for score, combo, timer, etc.
///
/// Whenever its value changes it pulses (a quick scale + accent glow), and when
/// a numeric value *increases* a floating "+N" rises and fades above it — so
/// every point gained feels alive. Every game gets this for free just by using
/// StatPill for its score and combo.
class StatPill extends StatefulWidget {
  const StatPill({
    super.key,
    required this.label,
    required this.value,
    this.accent,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final Color? accent;

  /// When true the value is tinted with [accent] and the tile gets a faint
  /// accent wash — used to make the live stat (e.g. an active combo) pop.
  final bool emphasized;

  @override
  State<StatPill> createState() => _StatPillState();
}

class _StatPillState extends State<StatPill> with TickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  int? _delta;

  /// Pulls the first signed integer out of a value like "36", "x3" or "–".
  int? _numeric(String v) {
    final m = RegExp(r'-?\d+').firstMatch(v);
    return m == null ? null : int.tryParse(m.group(0)!);
  }

  @override
  void didUpdateWidget(StatPill old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      _pop.forward(from: 0);
      final before = _numeric(old.value);
      final after = _numeric(widget.value);
      if (before != null && after != null && after > before) {
        _delta = after - before;
        _float.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tint = widget.accent ?? AppColors.textHi;
    final gain = widget.accent ?? AppColors.success;

    final pill = AnimatedBuilder(
      animation: _pop,
      builder: (context, child) {
        final t = _pop.value;
        final s = 1 + 0.10 * math.sin(t * math.pi);
        final glow = math.sin(t * math.pi);
        // Emphasized stats (a live combo) get a little shake on top of the pop.
        final dx = widget.emphasized
            ? math.sin(t * math.pi * 3) * 3 * (1 - t)
            : 0.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(
          scale: s,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: glow > 0.01
                  ? [
                      BoxShadow(
                        color: gain.withValues(alpha: 0.45 * glow),
                        blurRadius: 20 * glow,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: widget.emphasized && widget.accent != null
            ? Surfaces.accentTile(widget.accent!, radius: 16)
            : Surfaces.tile(radius: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: AppText.label(10)),
            const SizedBox(height: 3),
            Text(
              widget.value,
              style: AppText.display(
                18,
                color: widget.emphasized ? tint : AppColors.textHi,
              ),
            ),
          ],
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        pill,
        if (_delta != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _float,
                builder: (context, _) {
                  final t = _float.value;
                  final opacity = math.sin(t * math.pi);
                  if (opacity <= 0.01) return const SizedBox.shrink();
                  return Align(
                    alignment: Alignment.topRight,
                    child: Transform.translate(
                      offset: Offset(-8, -10 - 22 * t),
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Text(
                          '+$_delta',
                          style: AppText.display(15, color: gain),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
