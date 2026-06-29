import 'dart:math';
import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Living gradient backdrop: an ink base with a few accent-tinted blobs that
/// drift slowly, plus an edge vignette. Gives every game a premium, deep feel
/// without any per-screen work.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, required this.accent});
  final Color accent;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 18))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value * 2 * pi;
          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.bg, AppColors.bgDeep],
                  ),
                ),
              ),
              _blob(Alignment(-0.85 + 0.25 * sin(t), -0.95 + 0.18 * cos(t)),
                  widget.accent, 0.26, 420),
              _blob(Alignment(0.95 + 0.18 * cos(t * 0.8), 0.95 + 0.16 * sin(t * 0.8)),
                  AppColors.visual, 0.12, 460),
              _blob(Alignment(0.5 * sin(t * 0.6), 0.15 * cos(t)),
                  widget.accent, 0.06, 320),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.15,
                    colors: [Colors.transparent, Color(0x99080C17)],
                    stops: [0.6, 1.0],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _blob(Alignment a, Color color, double opacity, double size) => Align(
        alignment: a,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color.withValues(alpha: opacity), Colors.transparent],
              ),
            ),
          ),
        ),
      );
}
