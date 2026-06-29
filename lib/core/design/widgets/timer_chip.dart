import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';

/// Countdown chip for a game's top bar. Turns red under [warnAt] seconds.
class TimerChip extends StatelessWidget {
  const TimerChip({super.key, required this.seconds, this.warnAt = 15});

  final int seconds;
  final int warnAt;

  @override
  Widget build(BuildContext context) {
    final low = seconds <= warnAt;
    final color = low ? AppColors.danger : AppColors.textHi;
    final mm = (seconds ~/ 60).toString();
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color:
            low ? AppColors.danger.withValues(alpha: 0.14) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              low ? AppColors.danger.withValues(alpha: 0.5) : AppColors.stroke,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Text('$mm:$ss', style: AppText.display(16, color: color)),
        ],
      ),
    );
  }
}
