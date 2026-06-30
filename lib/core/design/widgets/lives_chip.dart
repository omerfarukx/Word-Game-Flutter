import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Survival-mode life counter shown in a game's top bar (in place of the
/// timer): a row of hearts that empty as the player loses lives.
class LivesChip extends StatelessWidget {
  const LivesChip({super.key, required this.lives, this.max = 3});

  final int lives;
  final int max;

  @override
  Widget build(BuildContext context) {
    final low = lives <= 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: low
            ? AppColors.danger.withValues(alpha: 0.14)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: low
              ? AppColors.danger.withValues(alpha: 0.5)
              : AppColors.stroke,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < max; i++)
            Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 5),
              child: AnimatedScale(
                scale: i < lives ? 1.0 : 0.82,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  i < lives
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: i < lives ? AppColors.danger : AppColors.textLow,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
