import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../decorations.dart';

/// A compact label-over-value tile used for score, combo, timer, etc.
/// Gives a quick scale pulse whenever its value changes, so points feel alive.
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

class _StatPillState extends State<StatPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void didUpdateWidget(StatPill old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tint = widget.accent ?? AppColors.textHi;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final s = 1 + 0.10 * math.sin(_c.value * math.pi);
        return Transform.scale(scale: s, child: child);
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
  }
}
