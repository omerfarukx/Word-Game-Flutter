import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/design/decorations.dart';
import '../../../../core/design/widgets/game_result.dart';
import '../../../../core/design/widgets/game_scaffold.dart';
import '../../../../core/design/widgets/reveal.dart';
import '../../../../core/feedback/achievements.dart';
import '../../../statistics/providers/statistics_provider.dart';
import '../controllers/speed_reading_controller.dart';

const _accent = AppColors.reading;

class SpeedReadingScreen extends StatefulWidget {
  const SpeedReadingScreen({super.key});

  @override
  State<SpeedReadingScreen> createState() => _SpeedReadingScreenState();
}

class _SpeedReadingScreenState extends State<SpeedReadingScreen> {
  final SpeedReadingController _c = SpeedReadingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChange);
  }

  void _onChange() {
    if (_c.phase == ReadPhase.done && !_saved) {
      _saved = true;
      context.read<StatisticsProvider>().addExerciseCompletion(
            _c.durationSeconds / 60,
          );
      reportAchievements(context);
    } else if (_c.phase != ReadPhase.done) {
      _saved = false;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _c.removeListener(_onChange);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Hızlı Okuma',
      accent: _accent,
      child: Stack(
        children: [
          switch (_c.phase) {
            ReadPhase.idle => _SpeedPicker(onPick: _c.start),
            ReadPhase.countdown => _Countdown(value: _c.countdown),
            ReadPhase.reading => _Reader(c: _c),
            ReadPhase.done => const SizedBox.expand(),
          },
          if (_c.phase == ReadPhase.done)
            GameResultOverlay(
              accent: _accent,
              title: 'Bitti! 📖',
              bigValue: '${_c.speed.wpm}',
              bigLabel: 'KELİME/DK',
              stats: [
                ResultStat('KELİME', '${_c.wordCount}'),
                ResultStat('SÜRE', '${_c.durationSeconds} sn'),
                ResultStat('TEMPO', _c.speed.label),
              ],
              restartLabel: 'Yeni Metin',
              onRestart: () => _c.start(_c.speed),
              onExit: () => Navigator.of(context).maybePop(),
            ),
        ],
      ),
    );
  }
}

class _SpeedPicker extends StatelessWidget {
  const _SpeedPicker({required this.onPick});
  final void Function(ReadSpeed) onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Temponu seç', style: AppText.display(22)),
          const SizedBox(height: 6),
          Text('Kelimeler tek tek, seçtiğin hızda akacak. Sadece oku.',
              style: AppText.body(14, color: AppColors.textLow)),
          const SizedBox(height: 24),
          for (var i = 0; i < ReadSpeed.values.length; i++) ...[
            Reveal(
              delay: Duration(milliseconds: i * 70),
              child: _SpeedCard(
                speed: ReadSpeed.values[i],
                onTap: () => onPick(ReadSpeed.values[i]),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SpeedCard extends StatelessWidget {
  const _SpeedCard({required this.speed, required this.onTap});
  final ReadSpeed speed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: Surfaces.tile(radius: 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppGradients.reading,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: _accent.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 5)),
                    ],
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(speed.label, style: AppText.display(18)),
                      const SizedBox(height: 4),
                      Text(speed.blurb,
                          style: AppText.body(13, color: AppColors.textLow)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: _accent.withValues(alpha: 0.8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ShaderMask(
        shaderCallback: (r) => AppGradients.reading.createShader(r),
        child: Text('$value',
            key: ValueKey(value),
            style: AppText.display(96, color: Colors.white)),
      ),
    );
  }
}

class _Reader extends StatelessWidget {
  const _Reader({required this.c});
  final SpeedReadingController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: c.progress,
              minHeight: 6,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation(_accent),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              c.currentWord,
              textAlign: TextAlign.center,
              style: AppText.display(40, color: AppColors.textHi),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text('${c.speed.wpm} kelime/dk',
              style: AppText.label(12, color: AppColors.textLow)),
        ),
      ],
    );
  }
}
