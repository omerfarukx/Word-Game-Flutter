import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shakes its [child] horizontally each time [trigger] changes value.
/// Used to signal a rejected input without a disruptive dialog.
class Shaker extends StatefulWidget {
  const Shaker({super.key, required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<Shaker> createState() => _ShakerState();
}

class _ShakerState extends State<Shaker> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(Shaker old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Decaying sine — a few quick wobbles that settle.
        final dx = math.sin(_c.value * math.pi * 4) * 10 * (1 - _c.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
