import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/design/widgets/confetti.dart';
import '../../../../core/design/widgets/game_result.dart';
import '../../../../core/design/widgets/game_scaffold.dart';
import '../../../../core/design/widgets/lives_chip.dart';
import '../../../../core/design/widgets/power_bar.dart';
import '../../../../core/design/widgets/record_chase.dart';
import '../../../../core/design/widgets/stat_pill.dart';
import '../../../../core/design/widgets/timer_chip.dart';
import '../../../../core/feedback/achievements.dart';
import '../../../../core/feedback/game_settings.dart';
import '../../../../core/feedback/records.dart';
import '../../../statistics/providers/statistics_provider.dart';
import '../controllers/peripheral_controller.dart';

const _accent = AppColors.visual;

class PeripheralVisionScreen extends StatefulWidget {
  const PeripheralVisionScreen({super.key});

  @override
  State<PeripheralVisionScreen> createState() => _PeripheralVisionScreenState();
}

class _PeripheralVisionScreenState extends State<PeripheralVisionScreen> {
  final PeripheralController _c = PeripheralController();
  bool _saved = false;
  bool _record = false;
  int _confetti = 0;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChange);
    _c.start();
  }

  void _onChange() {
    if (_c.isOver && !_saved) {
      _saved = true;
      _record = Records.instance.submit('peripheral', _c.score);
      if (_c.score > 0 && (_record || _c.accuracy >= 70)) _confetti++;
      context.read<StatisticsProvider>().addExerciseCompletion(
            PeripheralController.gameSeconds / 60,
          );
      reportAchievements(context,
          score: _c.score, maxCombo: _c.maxCombo, isRecord: _record);
    }
    setState(() {});
  }

  void _restart() {
    _saved = false;
    _c.start();
  }

  @override
  void dispose() {
    _c.removeListener(_onChange);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final survival = GameSettings.instance.survival;
    return GameScaffold(
      title: 'Çevresel Görüş',
      accent: _accent,
      trailing: survival
          ? LivesChip(lives: _c.lives, max: GameSettings.survivalLives)
          : TimerChip(seconds: _c.timeLeft),
      child: Stack(
        children: [
          Column(
            children: [
              _StatRow(c: _c),
              RecordChase(
                accent: _accent,
                best: Records.instance.best('peripheral'),
                current: _c.score,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Text(
                  _c.phase == PeriPhase.respond
                      ? 'Hangi nokta parladı?'
                      : 'Ortadaki noktaya odaklan',
                  style: AppText.body(13, color: AppColors.textLow),
                ),
              ),
              Expanded(child: _Ring(c: _c)),
              PowerBar(
                accent: _accent,
                onJoker: _c.useJoker,
                jokers: _c.jokers,
                onFreeze: survival ? null : _c.freeze,
                freezes: _c.freezes,
                frozen: _c.isFrozen,
              ),
            ],
          ),
          ConfettiBurst(trigger: _confetti),
          if (_c.isOver)
            GameResultOverlay(
              accent: _accent,
              title: survival ? 'Canın Bitti' : 'Süre Doldu',
              isRecord: _record,
              bigValue: '${_c.score}',
              bigLabel: 'PUAN',
              stats: [
                ResultStat('EN İYİ', '${Records.instance.best('peripheral')}'),
                ResultStat('DOĞRULUK', '%${_c.accuracy}'),
                ResultStat('SEVİYE', '${_c.level}'),
              ],
              onRestart: _restart,
              onExit: () => Navigator.of(context).maybePop(),
            ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.c});
  final PeripheralController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(child: StatPill(label: 'SKOR', value: '${c.score}')),
          const SizedBox(width: 10),
          Expanded(
            child: StatPill(
              label: 'KOMBO',
              value: c.combo >= 1 ? 'x${c.combo}' : '–',
              accent: _accent,
              emphasized: c.combo >= 3,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: StatPill(label: 'DOĞRULUK', value: '%${c.accuracy}')),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.c});
  final PeripheralController c;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cons) {
        final w = cons.maxWidth;
        final h = cons.maxHeight;
        final cx = w / 2;
        final cy = h / 2;
        final radius = (min(w, h) / 2) - 44;

        final children = <Widget>[
          // centre fixation
          Positioned(
            left: cx - 16,
            top: cy - 16,
            child: _Fixation(active: c.phase == PeriPhase.showing),
          ),
        ];

        for (var i = 0; i < PeripheralController.dots; i++) {
          final angle = -pi / 2 + i * (2 * pi / PeripheralController.dots);
          final dx = cx + radius * cos(angle);
          final dy = cy + radius * sin(angle);
          children.add(Positioned(
            left: dx - 30,
            top: dy - 30,
            width: 60,
            height: 60,
            child: _Dot(c: c, index: i),
          ));
        }

        return Stack(children: children);
      },
    );
  }
}

class _Fixation extends StatelessWidget {
  const _Fixation({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textLow.withValues(alpha: 0.25),
        border: Border.all(
          color: active ? _accent : AppColors.stroke,
          width: 2,
        ),
      ),
      child: const Icon(Icons.add_rounded, size: 18, color: AppColors.textMid),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.c, required this.index});
  final PeripheralController c;
  final int index;

  @override
  Widget build(BuildContext context) {
    final lit = c.phase == PeriPhase.showing && c.litIndex == index;
    final revealCorrect = c.phase == PeriPhase.feedback && c.litIndex == index;
    final revealWrong = c.phase == PeriPhase.feedback &&
        c.tappedIndex == index &&
        !c.lastCorrect;

    Color color;
    List<BoxShadow>? glow;
    if (lit) {
      color = _accent;
      glow = [BoxShadow(color: _accent.withValues(alpha: 0.7), blurRadius: 22)];
    } else if (revealCorrect) {
      color = AppColors.success;
      glow = [
        BoxShadow(color: AppColors.success.withValues(alpha: 0.6), blurRadius: 18)
      ];
    } else if (revealWrong) {
      color = AppColors.danger;
    } else {
      color = AppColors.surfaceHi;
    }

    return GestureDetector(
      onTap: () => c.tap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: AppColors.stroke),
          boxShadow: glow,
        ),
      ),
    );
  }
}
