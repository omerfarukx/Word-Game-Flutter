import 'dart:math';
import 'package:flutter/material.dart';
import '../app_colors.dart';

/// A one-shot confetti burst. Change [trigger] to fire; particles fall once
/// and fade. Lightweight (no package) — used to celebrate records / level-ups.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, required this.trigger, this.colors});

  final int trigger;
  final List<Color>? colors;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  final _rand = Random();
  List<_Particle> _particles = [];

  static const _palette = [
    AppColors.word,
    AppColors.visual,
    AppColors.reading,
    AppColors.success,
    AppColors.wordSoft,
  ];

  @override
  void didUpdateWidget(ConfettiBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger > 0) _fire();
  }

  void _fire() {
    final colors = widget.colors ?? _palette;
    _particles = List.generate(70, (_) {
      final angle = -pi / 2 + (_rand.nextDouble() - 0.5) * 1.4;
      final speed = 0.6 + _rand.nextDouble() * 0.9;
      return _Particle(
        x: 0.5 + (_rand.nextDouble() - 0.5) * 0.1,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        color: colors[_rand.nextInt(colors.length)],
        size: 6 + _rand.nextDouble() * 8,
        rot: _rand.nextDouble() * pi,
        rotSpeed: (_rand.nextDouble() - 0.5) * 8,
      );
    });
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => _c.isAnimating
            ? CustomPaint(
                size: Size.infinite,
                painter: _ConfettiPainter(_particles, _c.value),
              )
            : const SizedBox.expand(),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rot,
    required this.rotSpeed,
  });

  final double x; // 0..1 start
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double rot;
  final double rotSpeed;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = (1 - t).clamp(0.0, 1.0);
    for (final p in particles) {
      final px = p.x * size.width + p.vx * size.width * 0.6 * t;
      final py = size.height * 0.32 +
          p.vy * size.height * 0.5 * t +
          size.height * 1.1 * t * t; // gravity
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rot + p.rotSpeed * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.5),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
