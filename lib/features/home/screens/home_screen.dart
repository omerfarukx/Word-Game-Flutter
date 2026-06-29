import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/design/decorations.dart';
import '../../../core/design/widgets/aurora_background.dart';
import '../../../core/design/widgets/reveal.dart';
import '../../../core/feedback/music_service.dart';
import '../../../core/feedback/sound_service.dart';
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
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final String category;
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
    category: 'Kelime Egzersizleri',
  ),
  Exercise(
    title: 'Kelime Tanıma',
    subtitle: 'Tanıma hızını artır',
    icon: Icons.flash_on_rounded,
    route: RouteConstants.wordRecognition,
    category: 'Kelime Egzersizleri',
  ),
  Exercise(
    title: 'Kelime Odağı',
    subtitle: 'İlişkili kelimeleri keşfet',
    icon: Icons.hub_rounded,
    route: RouteConstants.wordFocus,
    category: 'Kelime Egzersizleri',
  ),
  Exercise(
    title: 'Kelime Bulma',
    subtitle: 'Gizli kelimeleri bul',
    icon: Icons.grid_on_rounded,
    route: RouteConstants.wordSearch,
    category: 'Kelime Egzersizleri',
  ),
  Exercise(
    title: 'Kelime Zinciri',
    subtitle: 'Son harften zincir kur',
    icon: Icons.link_rounded,
    route: RouteConstants.wordChain,
    category: 'Kelime Egzersizleri',
  ),
  Exercise(
    title: 'Harf Arama',
    subtitle: 'Harfleri bul ve seç',
    icon: Icons.search_rounded,
    route: RouteConstants.letterSearch,
    category: 'Görsel Egzersizler',
  ),
  Exercise(
    title: 'Göz Odaklama',
    subtitle: 'Göz kaslarını güçlendir',
    icon: Icons.center_focus_strong_rounded,
    route: RouteConstants.eyeFocus,
    category: 'Görsel Egzersizler',
  ),
  Exercise(
    title: 'Çevresel Görüş',
    subtitle: 'Çevreyi fark et',
    icon: Icons.blur_circular_rounded,
    route: RouteConstants.peripheralVision,
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
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 8),
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
                child: Text('Hızlı Okuma',
                    style: AppText.display(40, color: Colors.white)),
              ),
            ],
          ),
        ),
        const _MuteButton(),
      ],
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

class _HeroStats extends StatelessWidget {
  const _HeroStats();

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticsProvider>();
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OKUMA DÜZEYİ', style: AppText.label(10)),
                  const SizedBox(height: 2),
                  Text(stats.readingLevel, style: AppText.display(22)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
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
                child: _MiniStat(
                  icon: Icons.timer_rounded,
                  color: AppColors.visual,
                  value: '${stats.duration.toStringAsFixed(1)} sa',
                  label: 'SÜRE',
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

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: Surfaces.tile(radius: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, exercise.route),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Icon(exercise.icon, color: Colors.white, size: 24),
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
