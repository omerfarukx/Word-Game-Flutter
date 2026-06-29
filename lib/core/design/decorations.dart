import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Accent gradients — accents are never flat fills anymore; they glow.
class AppGradients {
  const AppGradients._();

  static const word = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA585FF), Color(0xFF6D54F0)],
  );
  static const visual = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF52E5F5), Color(0xFF1FA8D6)],
  );
  static const reading = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFCE73), Color(0xFFF59E0B)],
  );

  static LinearGradient forAccent(Color accent) {
    if (accent == AppColors.visual) return visual;
    if (accent == AppColors.reading) return reading;
    return word;
  }
}

/// Reusable surface treatments so cards feel layered and tactile instead of
/// flat. A tile has a top-lit vertical gradient, a hairline highlight edge and
/// a soft drop shadow.
class Surfaces {
  const Surfaces._();

  static BoxDecoration tile({
    double radius = 18,
    Color? border,
    Color top = AppColors.surfaceHi,
    Color bottom = AppColors.surface,
  }) =>
      BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? AppColors.stroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      );

  /// A tile washed and ringed with [accent], for selected/active states.
  static BoxDecoration accentTile(Color accent, {double radius = 18}) =>
      BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.22),
            accent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      );
}
