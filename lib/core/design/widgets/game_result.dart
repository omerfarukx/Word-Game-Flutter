import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../decorations.dart';
import 'app_button.dart';
import 'count_up.dart';

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
    this.onContinue,
    this.continueLabel = 'Reklamla Devam Et',
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

  /// When set, shows a "watch ad to continue" button above the actions.
  final VoidCallback? onContinue;
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.74),
        alignment: Alignment.center,
        child: Padding(
            padding: const EdgeInsets.all(28),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: Surfaces.tile(radius: 26),
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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.45),
                          blurRadius: 36,
                        ),
                      ],
                    ),
                    child: ShaderMask(
                      shaderCallback: (r) =>
                          AppGradients.forAccent(accent).createShader(r),
                      child: CountUp(bigValue,
                          style: AppText.display(58, color: Colors.white)),
                    ),
                  ),
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
                if (onContinue != null) ...[
                  _ContinueButton(
                    label: continueLabel,
                    accent: accent,
                    onTap: onContinue!,
                  ),
                  const SizedBox(height: 12),
                ],
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

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.label,
    required this.accent,
    required this.onTap,
  });
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.forAccent(accent),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: accent.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: SizedBox(
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_fill_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(label,
                      style: AppText.body(15,
                          weight: FontWeight.w700, color: Colors.white)),
                ],
              ),
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
