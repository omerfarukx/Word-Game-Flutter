import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../decorations.dart';

/// A compact label-over-value tile used for score, combo, timer, etc.
class StatPill extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final tint = accent ?? AppColors.textHi;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: emphasized && accent != null
          ? Surfaces.accentTile(accent!, radius: 16)
          : Surfaces.tile(radius: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label(10)),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppText.display(
              18,
              color: emphasized ? tint : AppColors.textHi,
            ),
          ),
        ],
      ),
    );
  }
}
