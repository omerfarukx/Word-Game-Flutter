import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/design/decorations.dart';
import '../../../core/design/widgets/aurora_background.dart';
import '../../../core/design/widgets/reveal.dart';
import '../../../core/feedback/achievements.dart';
import '../../../core/feedback/records.dart';
import '../providers/statistics_provider.dart';

/// One game's row in the records list.
class _GameRecord {
  const _GameRecord(
      this.title, this.route, this.id, this.icon, this.accent, this.isTime);
  final String title;
  final String route;
  final String id;
  final IconData icon;
  final Color accent;
  final bool isTime;
}

const _records = <_GameRecord>[
  _GameRecord('Kelime Çiftleri', RouteConstants.wordPairs, 'word_pairs',
      Icons.compare_arrows_rounded, AppColors.word, false),
  _GameRecord('Kelime Tanıma', RouteConstants.wordRecognition,
      'word_recognition', Icons.flash_on_rounded, AppColors.word, false),
  _GameRecord('Kelime Odağı', RouteConstants.wordFocus, 'word_focus',
      Icons.hub_rounded, AppColors.word, false),
  _GameRecord('Kelime Bulma', RouteConstants.wordSearch, 'word_search',
      Icons.grid_on_rounded, AppColors.word, false),
  _GameRecord('Kelime Zinciri', RouteConstants.wordChain, 'word_chain',
      Icons.link_rounded, AppColors.word, false),
  _GameRecord('Karışık Harfler', RouteConstants.anagram, 'anagram',
      Icons.shuffle_rounded, AppColors.word, false),
  _GameRecord('Harf Arama', RouteConstants.letterSearch, 'letter_search',
      Icons.search_rounded, AppColors.visual, false),
  _GameRecord('Göz Odaklama', RouteConstants.eyeFocus, 'schultz',
      Icons.center_focus_strong_rounded, AppColors.visual, true),
  _GameRecord('Çevresel Görüş', RouteConstants.peripheralVision, 'peripheral',
      Icons.blur_circular_rounded, AppColors.visual, false),
];

const _levelTiers = <(int, String)>[
  (0, 'Başlangıç'),
  (5, 'Orta'),
  (15, 'İleri'),
  (30, 'Uzman'),
  (50, 'Şampiyon'),
];

({String name, double progress, String hint}) _level(int completed) {
  var idx = 0;
  for (var i = 0; i < _levelTiers.length; i++) {
    if (completed >= _levelTiers[i].$1) idx = i;
  }
  final floor = _levelTiers[idx].$1;
  final hasNext = idx + 1 < _levelTiers.length;
  final nextFloor = hasNext ? _levelTiers[idx + 1].$1 : floor;
  return (
    name: _levelTiers[idx].$2,
    progress: hasNext ? ((completed - floor) / (nextFloor - floor)).clamp(0.0, 1.0) : 1.0,
    hint: hasNext
        ? 'Sonraki: ${_levelTiers[idx + 1].$2} • ${nextFloor - completed} egzersiz'
        : 'En üst seviyedesin 🏆',
  );
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticsProvider>();
    final level = _level(stats.completedExercises);
    var i = 0;
    Duration delay() => Duration(milliseconds: (i++) * 50);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AuroraBackground(accent: AppColors.word)),
          SafeArea(
            child: Column(
              children: [
                _TopBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    children: [
                      Reveal(delay: delay(), child: _LevelCard(level: level)),
                      const SizedBox(height: 12),
                      Reveal(delay: delay(), child: _TotalsRow(stats: stats)),
                      const SizedBox(height: 22),
                      Reveal(
                        delay: delay(),
                        child: _SectionHeader(
                          'Rozetler',
                          trailing:
                              '${Achievements.instance.unlockedCount}/${Achievements.instance.total}',
                          onTap: () => Navigator.pushNamed(
                              context, RouteConstants.achievements),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Reveal(delay: delay(), child: const _BadgeGrid()),
                      const SizedBox(height: 22),
                      Reveal(
                          delay: delay(),
                          child: const _SectionHeader('Kelime Oyunları')),
                      const SizedBox(height: 12),
                      for (final r in _records.where((r) => r.accent == AppColors.word))
                        Reveal(
                          delay: delay(),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RecordRow(record: r),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Reveal(
                          delay: delay(),
                          child: const _SectionHeader('Görsel Oyunlar')),
                      const SizedBox(height: 12),
                      for (final r in _records.where((r) => r.accent != AppColors.word))
                        Reveal(
                          delay: delay(),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RecordRow(record: r),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.stroke),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(context).maybePop(),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.arrow_back_rounded,
                    color: AppColors.textHi, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (r) => AppGradients.word.createShader(r),
            child: Text('İstatistikler',
                style: AppText.display(22, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level});
  final ({String name, double progress, String hint}) level;

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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppGradients.word,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.word.withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OKUMA DÜZEYİ', style: AppText.label(10)),
                    const SizedBox(height: 2),
                    Text(level.name, style: AppText.display(22)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 9, color: AppColors.bgDeep.withValues(alpha: 0.6)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor:
                      level.progress == 0 ? 0.0 : level.progress.clamp(0.04, 1.0),
                  child: Container(
                    height: 9,
                    decoration: BoxDecoration(
                      gradient: AppGradients.word,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(level.hint, style: AppText.body(11, color: AppColors.textLow)),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.stats});
  final StatisticsProvider stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Total(
            icon: Icons.local_fire_department_rounded,
            color: AppColors.reading,
            value: '${stats.streakDays}',
            label: 'GÜN SERİ',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Total(
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            value: '${stats.completedExercises}',
            label: 'EGZERSİZ',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Total(
            icon: Icons.timer_rounded,
            color: AppColors.word,
            value: '${stats.duration.toStringAsFixed(0)}dk',
            label: 'SÜRE',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, RouteConstants.achievements),
            child: _Total(
              icon: Icons.military_tech_rounded,
              color: AppColors.visual,
              value:
                  '${Achievements.instance.unlockedCount}/${Achievements.instance.total}',
              label: 'ROZET',
            ),
          ),
        ),
      ],
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.bgDeep.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.display(15)),
          const SizedBox(height: 2),
          Text(label, style: AppText.label(8)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text, {this.trailing, this.onTap});
  final String text;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Text(text.toUpperCase(),
            style: AppText.label(12, color: AppColors.textMid)),
        const Spacer(),
        if (trailing != null)
          Text(trailing!, style: AppText.label(11, color: AppColors.word)),
        if (onTap != null)
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.textLow),
      ],
    );
    if (onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }
}

/// A compact grid of every achievement badge — unlocked ones glow, locked ones
/// sit dim with a small lock — so the screen always has something to show and a
/// clear "collect them all" pull. Tapping the section opens the full list.
class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        for (final a in Achievements.all)
          _Badge(
            icon: a.icon,
            unlocked: Achievements.instance.isUnlocked(a.id),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.unlocked});
  final IconData icon;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    if (unlocked) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppGradients.reading,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.reading.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDeep.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(icon,
                color: AppColors.textLow.withValues(alpha: 0.4), size: 22),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Icon(Icons.lock_rounded,
                size: 11, color: AppColors.textLow.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record});
  final _GameRecord record;

  @override
  Widget build(BuildContext context) {
    final v = Records.instance.best(record.id);
    final has = v > 0;
    final value = record.isTime
        ? '${v ~/ 60}:${(v % 60).toString().padLeft(2, '0')}'
        : '$v';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: Surfaces.tile(radius: 16),
      child: Row(
        children: [
          Opacity(
            opacity: has ? 1 : 0.5,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: record.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: record.accent.withValues(alpha: 0.4)),
              ),
              child: Icon(record.icon, color: record.accent, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.title, style: AppText.display(15)),
                const SizedBox(height: 2),
                Text(
                  has ? (record.isTime ? 'En iyi süre' : 'En yüksek skor') : 'Henüz oynanmadı',
                  style: AppText.body(11, color: AppColors.textLow),
                ),
              ],
            ),
          ),
          if (has) ...[
            Icon(
              record.isTime
                  ? Icons.timer_outlined
                  : Icons.emoji_events_rounded,
              size: 14,
              color: record.accent,
            ),
            const SizedBox(width: 6),
            Text(value, style: AppText.display(18, color: record.accent)),
          ] else
            Text('–', style: AppText.display(18, color: AppColors.textLow)),
        ],
      ),
    );
  }
}
