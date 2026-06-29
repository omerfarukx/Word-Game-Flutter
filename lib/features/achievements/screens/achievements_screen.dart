import 'package:flutter/material.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/design/decorations.dart';
import '../../../core/design/widgets/game_scaffold.dart';
import '../../../core/design/widgets/reveal.dart';
import '../../../core/feedback/achievements.dart';

const _accent = AppColors.word;

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const all = Achievements.all;
    final unlocked = Achievements.instance.unlockedCount;

    return GameScaffold(
      title: 'Başarımlar',
      accent: _accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Reveal(child: _Progress(unlocked: unlocked, total: all.length)),
          const SizedBox(height: 16),
          for (var i = 0; i < all.length; i++) ...[
            Reveal(
              delay: Duration(milliseconds: i * 35),
              child: _AchievementCard(
                achievement: all[i],
                unlocked: Achievements.instance.isUnlocked(all[i].id),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.unlocked, required this.total});
  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: Surfaces.tile(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$unlocked', style: AppText.display(36, color: _accent)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('/ $total rozet', style: AppText.body(15)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : unlocked / total,
              minHeight: 8,
              backgroundColor: AppColors.surfaceHi,
              valueColor: const AlwaysStoppedAnimation(_accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, required this.unlocked});
  final Achievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: Surfaces.tile(
          radius: 18,
          border: unlocked ? AppColors.reading.withValues(alpha: 0.5) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: unlocked ? AppGradients.reading : null,
                color: unlocked ? null : AppColors.surfaceHi,
                borderRadius: BorderRadius.circular(14),
                border: unlocked
                    ? null
                    : Border.all(color: AppColors.stroke),
              ),
              child: Icon(
                unlocked ? achievement.icon : Icons.lock_rounded,
                color: unlocked ? Colors.white : AppColors.textLow,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievement.title, style: AppText.display(16)),
                  const SizedBox(height: 3),
                  Text(achievement.desc,
                      style: AppText.body(13, color: AppColors.textLow)),
                ],
              ),
            ),
            if (unlocked)
              const Icon(Icons.verified_rounded,
                  color: AppColors.reading, size: 22),
          ],
        ),
      ),
    );
  }
}
