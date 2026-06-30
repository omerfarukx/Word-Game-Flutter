import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/design/decorations.dart';
import '../../../core/design/widgets/aurora_background.dart';
import '../../../core/design/widgets/how_to_sheet.dart';
import '../../../core/design/widgets/reveal.dart';
import '../../../core/feedback/achievements.dart';
import '../../../core/feedback/daily_challenge.dart';
import '../../../core/feedback/game_settings.dart';
import '../../../core/feedback/music_service.dart';
import '../../../core/feedback/records.dart';
import '../../../core/feedback/sound_service.dart';
import '../../../core/onboarding/guides.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../statistics/providers/statistics_provider.dart';

class _Category {
  const _Category(this.label, this.accent, this.icon);
  final String label;
  final Color accent;
  final IconData icon;
}

class Exercise {
  const Exercise({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.category,
    this.recordId,
    this.recordIsTime = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final String category;

  /// Records key for this game's personal best, or null if it has none.
  final String? recordId;

  /// True when the best is a time (lower is better), shown as m:ss.
  final bool recordIsTime;
}

const _categories = <_Category>[
  _Category('Kelime Egzersizleri', AppColors.word, Icons.text_fields_rounded),
  _Category('Görsel Egzersizler', AppColors.visual, Icons.visibility_rounded),
  _Category('Okuma Egzersizleri', AppColors.reading, Icons.menu_book_rounded),
];

const _exercises = <Exercise>[
  Exercise(
    title: 'Kelime Çiftleri',
    subtitle: 'Aynı olmayan çiftleri bul',
    icon: Icons.compare_arrows_rounded,
    route: RouteConstants.wordPairs,
    recordId: 'word_pairs',
    category: 'Kelime Egzersizleri',
  ),
  Exercise(
    title: 'Kelime Tanıma',
    subtitle: 'Tanıma hızını artır',
    icon: Icons.flash_on_rounded,
    route: RouteConstants.wordRecognition,
    recordId: 'word_recognition',
    category: 'Kelime Egzersizleri',
  ),
  Exercise(
    title: 'Kelime Odağı',
    subtitle: 'İlişkili kelimeleri keşfet',
    icon: Icons.hub_rounded,
    route: RouteConstants.wordFocus,
    recordId: 'word_focus',
    category: 'Kelime Egzersizleri',
  ),
  Exercise(
    title: 'Kelime Bulma',
    subtitle: 'Gizli kelimeleri bul',
    icon: Icons.grid_on_rounded,
    route: RouteConstants.wordSearch,
    recordId: 'word_search',
    category: 'Kelime Egzersizleri',
  ),
  Exercise(
    title: 'Kelime Zinciri',
    subtitle: 'Son harften zincir kur',
    icon: Icons.link_rounded,
    route: RouteConstants.wordChain,
    recordId: 'word_chain',
    category: 'Kelime Egzersizleri',
  ),
  Exercise(
    title: 'Karışık Harfler',
    subtitle: 'Harflerden kelime kur',
    icon: Icons.shuffle_rounded,
    route: RouteConstants.anagram,
    recordId: 'anagram',
    category: 'Kelime Egzersizleri',
  ),
  Exercise(
    title: 'Harf Arama',
    subtitle: 'Harfleri bul ve seç',
    icon: Icons.search_rounded,
    route: RouteConstants.letterSearch,
    recordId: 'letter_search',
    category: 'Görsel Egzersizler',
  ),
  Exercise(
    title: 'Göz Odaklama',
    subtitle: 'Göz kaslarını güçlendir',
    icon: Icons.center_focus_strong_rounded,
    route: RouteConstants.eyeFocus,
    recordId: 'schultz',
    recordIsTime: true,
    category: 'Görsel Egzersizler',
  ),
  Exercise(
    title: 'Çevresel Görüş',
    subtitle: 'Çevreyi fark et',
    icon: Icons.blur_circular_rounded,
    route: RouteConstants.peripheralVision,
    recordId: 'peripheral',
    category: 'Görsel Egzersizler',
  ),
  Exercise(
    title: 'Hızlı Okuma',
    subtitle: 'Okuma hızını yükselt',
    icon: Icons.speed_rounded,
    route: RouteConstants.speedReadingExercise,
    category: 'Okuma Egzersizleri',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    MusicService.instance.play(MusicTrack.word);
    if (!Guides.instance.onboarded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOnboarding());
    }
  }

  void _showOnboarding() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => OnboardingScreen(
          onDone: () {
            Guides.instance.setOnboarded();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole home when stats change (e.g. after finishing a game),
    // so the daily-challenge card and record badges refresh on return.
    context.watch<StatisticsProvider>();
    var revealIndex = 0;
    Duration nextDelay() => Duration(milliseconds: (revealIndex++) * 45);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AuroraBackground(accent: AppColors.word)),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Reveal(delay: nextDelay(), child: const _Header()),
                const SizedBox(height: 20),
                Reveal(delay: nextDelay(), child: const _HeroStats()),
                const SizedBox(height: 12),
                Reveal(delay: nextDelay(), child: const _DailyCard()),
                const SizedBox(height: 12),
                Reveal(delay: nextDelay(), child: const _DifficultySelector()),
                const SizedBox(height: 4),
                for (final cat in _categories) ...[
                  const SizedBox(height: 18),
                  Reveal(delay: nextDelay(), child: _SectionHeader(cat)),
                  const SizedBox(height: 14),
                  _CategoryGrid(category: cat, nextDelay: nextDelay),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GÜNLÜK ANTRENMAN', style: AppText.label(11)),
              const SizedBox(height: 6),
              ShaderMask(
                shaderCallback: (r) => AppGradients.word.createShader(r),
                child: Text('Kelime Atölyesi',
                    style: AppText.display(36, color: Colors.white)),
              ),
            ],
          ),
        ),
        _HeaderButton(
          icon: Icons.bar_chart_rounded,
          color: AppColors.word,
          onTap: () => Navigator.pushNamed(context, RouteConstants.statistics),
        ),
        const SizedBox(width: 10),
        const _MuteButton(),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.stroke),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _MuteButton extends StatefulWidget {
  const _MuteButton();

  @override
  State<_MuteButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<_MuteButton> {
  @override
  Widget build(BuildContext context) {
    final muted = SoundService.instance.muted;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.stroke),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final next = !muted;
          await SoundService.instance.setMuted(next);
          await MusicService.instance.setMuted(next);
          if (mounted) setState(() {});
        },
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: muted ? AppColors.textLow : AppColors.word,
            size: 22,
          ),
        ),
      ),
    );
  }
}

/// One progression tier: the exercise count where it unlocks and its name.
class _Level {
  const _Level(this.floor, this.name);
  final int floor;
  final String name;
}

const _levels = <_Level>[
  _Level(0, 'Başlangıç'),
  _Level(5, 'Orta'),
  _Level(15, 'İleri'),
  _Level(30, 'Uzman'),
  _Level(50, 'Şampiyon'),
];

/// Current tier and the next one (null at the top) for a given completed count.
(_Level current, _Level? next) _levelFor(int completed) {
  var current = _levels.first;
  for (final l in _levels) {
    if (completed >= l.floor) current = l;
  }
  final idx = _levels.indexOf(current);
  final next = idx + 1 < _levels.length ? _levels[idx + 1] : null;
  return (current, next);
}

class _HeroStats extends StatelessWidget {
  const _HeroStats();

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticsProvider>();
    final (level, next) = _levelFor(stats.completedExercises);
    final progress = next == null
        ? 1.0
        : ((stats.completedExercises - level.floor) / (next.floor - level.floor))
            .clamp(0.0, 1.0);
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
          _LevelBar(
            progress: progress,
            caption: next == null
                ? 'En üst seviyedesin 🏆'
                : 'Sonraki: ${next.name} • ${next.floor - stats.completedExercises} egzersiz',
          ),
          const SizedBox(height: 16),
          _DailyGoal(
            done: stats.todayCount,
            goal: StatisticsProvider.dailyGoal,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.reading,
                  value: '${stats.streakDays}',
                  label: 'GÜN SERİ',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  value: '${stats.completedExercises}',
                  label: 'EGZERSİZ',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, RouteConstants.achievements),
                  child: _MiniStat(
                    icon: Icons.military_tech_rounded,
                    color: AppColors.visual,
                    value:
                        '${Achievements.instance.unlockedCount}/${Achievements.instance.total}',
                    label: 'ROZET',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
              style: AppText.display(16)),
          const SizedBox(height: 2),
          Text(label, style: AppText.label(8)),
        ],
      ),
    );
  }
}

/// Gradient XP bar showing how far into the current level the player is.
class _LevelBar extends StatelessWidget {
  const _LevelBar({required this.progress, required this.caption});
  final double progress;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 9,
                color: AppColors.bgDeep.withValues(alpha: 0.6),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress == 0 ? 0.0 : progress.clamp(0.04, 1.0),
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
        Text(caption, style: AppText.body(11, color: AppColors.textLow)),
      ],
    );
  }
}

/// Compact daily-goal strip: a segment per target exercise, filled as the
/// player completes them, flipping to a success state once the goal is met.
class _DailyGoal extends StatelessWidget {
  const _DailyGoal({required this.done, required this.goal});
  final int done;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final met = done >= goal;
    final accent = met ? AppColors.success : AppColors.word;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: met ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: met ? 0.5 : 0.25)),
      ),
      child: Row(
        children: [
          Icon(met ? Icons.check_circle_rounded : Icons.flag_rounded,
              size: 18, color: accent),
          const SizedBox(width: 8),
          Text('GÜNLÜK HEDEF', style: AppText.label(10, color: AppColors.textMid)),
          const Spacer(),
          for (var i = 0; i < goal; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            Container(
              width: 18,
              height: 6,
              decoration: BoxDecoration(
                color: i < done ? accent : AppColors.stroke,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
          const SizedBox(width: 10),
          Text(
            met ? 'Tamam!' : '$done/$goal',
            style: AppText.body(12, weight: FontWeight.w700, color: accent),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.category);
  final _Category category;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: category.accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: category.accent.withValues(alpha: 0.4)),
          ),
          child: Icon(category.icon, color: category.accent, size: 18),
        ),
        const SizedBox(width: 10),
        Text(category.label.toUpperCase(),
            style: AppText.label(12, color: AppColors.textMid)),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.category, required this.nextDelay});
  final _Category category;
  final Duration Function() nextDelay;

  @override
  Widget build(BuildContext context) {
    final items =
        _exercises.where((e) => e.category == category.label).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.02,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => Reveal(
        delay: nextDelay(),
        child: _ExerciseCard(exercise: items[i], accent: category.accent),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.accent});
  final Exercise exercise;
  final Color accent;

  /// First time a game is opened we show its rules with a "Play" button; after
  /// that we go straight in. (Long-press always re-opens the rules.)
  void _open(BuildContext context) {
    final route = exercise.route;
    final guide = Guides.instance.forRoute(route);
    if (guide != null && !Guides.instance.isSeen(route)) {
      showHowTo(context,
          guide: guide,
          primaryLabel: 'Oyna',
          onPrimary: () {
            Guides.instance.markSeen(route);
            Navigator.pushNamed(context, route);
          });
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  void _showGuide(BuildContext context) {
    final guide = Guides.instance.forRoute(exercise.route);
    if (guide != null) showHowTo(context, guide: guide, primaryLabel: 'Kapat');
  }

  @override
  Widget build(BuildContext context) {
    final id = exercise.recordId;
    String? best;
    if (id != null) {
      final v = Records.instance.best(id);
      if (v > 0) {
        best = exercise.recordIsTime
            ? '${v ~/ 60}:${(v % 60).toString().padLeft(2, '0')}'
            : '$v';
      }
    }
    return DecoratedBox(
      decoration: Surfaces.tile(radius: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _open(context),
          onLongPress: () => _showGuide(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: AppGradients.forAccent(accent),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: accent.withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 5)),
                        ],
                      ),
                      child:
                          Icon(exercise.icon, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    if (best != null) _BestBadge(text: best, accent: accent),
                  ],
                ),
                const Spacer(),
                Text(exercise.title, style: AppText.display(16)),
                const SizedBox(height: 3),
                Text(
                  exercise.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(12, color: AppColors.textLow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard();

  @override
  Widget build(BuildContext context) {
    final task = DailyChallenge.instance.today;
    final done = DailyChallenge.instance.doneToday;
    final streak = DailyChallenge.instance.streak;
    final accent = task.accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, task.route),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.22),
                accent.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppGradients.forAccent(accent),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: accent.withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: Icon(done ? Icons.check_rounded : task.icon,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('GÜNLÜK MEYDAN OKUMA',
                            style: AppText.label(10, color: accent)),
                        if (streak > 0) ...[
                          const SizedBox(width: 8),
                          Text('🔥 $streak',
                              style: AppText.label(10, color: AppColors.reading)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(task.title, style: AppText.display(18)),
                    const SizedBox(height: 2),
                    Text(
                      done
                          ? 'Tamamlandı! Yarın yeni meydan okuma.'
                          : 'Hedef: ${task.target} puan',
                      style: AppText.body(12,
                          color: done ? AppColors.success : AppColors.textLow),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              done
                  ? const Icon(Icons.verified_rounded,
                      color: AppColors.success, size: 26)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppGradients.forAccent(accent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Oyna',
                          style: AppText.body(13,
                              weight: FontWeight.w700, color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultySelector extends StatefulWidget {
  const _DifficultySelector();

  @override
  State<_DifficultySelector> createState() => _DifficultySelectorState();
}

class _DifficultySelectorState extends State<_DifficultySelector> {
  @override
  Widget build(BuildContext context) {
    final cur = GameSettings.instance.difficulty;
    return Row(
      children: [
        Text('ZORLUK', style: AppText.label(10)),
        const SizedBox(width: 12),
        for (var i = 0; i < GameDifficulty.values.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _chip(GameDifficulty.values[i], cur)),
        ],
      ],
    );
  }

  Widget _chip(GameDifficulty d, GameDifficulty cur) {
    final sel = d == cur;
    return GestureDetector(
      onTap: () async {
        await GameSettings.instance.set(d);
        if (mounted) setState(() {});
      },
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: sel
            ? Surfaces.accentTile(AppColors.word, radius: 12)
            : Surfaces.tile(radius: 12),
        child: Text(
          d.label,
          style: AppText.body(13,
              weight: FontWeight.w600,
              color: sel ? AppColors.word : AppColors.textMid),
        ),
      ),
    );
  }
}

class _BestBadge extends StatelessWidget {
  const _BestBadge({required this.text, required this.accent});
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 12, color: accent),
          const SizedBox(width: 4),
          Text(text,
              style: AppText.body(11, weight: FontWeight.w700, color: accent)),
        ],
      ),
    );
  }
}
