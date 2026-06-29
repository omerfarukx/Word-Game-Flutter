import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import 'app_button.dart';

/// One small stat shown in the result summary (e.g. "EN İYİ" / "320").
class ResultStat {
  const ResultStat(this.label, this.value);
  final String label;
  final String value;
}

/// Shared end-of-game overlay: scrim, one big number, a row of mini stats,
/// and exit / play-again actions. Every game ends here so results feel uniform.
class GameResultOverlay extends StatelessWidget {
  const GameResultOverlay({
    super.key,
    required this.accent,
    required this.title,
    required this.bigValue,
    required this.bigLabel,
    required this.stats,
    required this.onRestart,
    required this.onExit,
    this.isRecord = false,
    this.restartLabel = 'Tekrar Oyna',
  });

  final Color accent;
  final String title;
  final String bigValue;
  final String bigLabel;
  final List<ResultStat> stats;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final bool isRecord;
  final String restartLabel;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.62),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRecord ? '🏆 Yeni Rekor!' : title,
                  textAlign: TextAlign.center,
                  style: AppText.display(24,
                      color: isRecord ? AppColors.reading : AppColors.textHi),
                ),
                const SizedBox(height: 18),
                Text(bigValue, style: AppText.display(56, color: accent)),
                Text(bigLabel, style: AppText.label(11)),
                if (stats.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      for (var i = 0; i < stats.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(child: _MiniStat(stats[i])),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: GhostButton(label: 'Çıkış', onTap: onExit)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: restartLabel,
                        color: accent,
                        onTap: onRestart,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.stat);
  final ResultStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHi,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(stat.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.display(16)),
          const SizedBox(height: 4),
          Text(stat.label, style: AppText.label(9)),
        ],
      ),
    );
  }
}
