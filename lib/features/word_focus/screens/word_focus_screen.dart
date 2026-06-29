import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/design/decorations.dart';
import '../../../core/design/widgets/confetti.dart';
import '../../../core/design/widgets/game_result.dart';
import '../../../core/design/widgets/game_scaffold.dart';
import '../../../core/design/widgets/record_chase.dart';
import '../../../core/design/widgets/reveal.dart';
import '../../../core/design/widgets/stat_pill.dart';
import '../../../core/design/widgets/timer_chip.dart';
import '../../../core/feedback/achievements.dart';
import '../../../core/feedback/records.dart';
import '../../../core/text/turkish.dart';
import '../../../core/words/word_service.dart';
import '../../statistics/providers/statistics_provider.dart';
import '../controllers/word_focus_controller.dart';
import '../data/word_focus_data.dart';

const _accent = AppColors.word;

class WordFocusScreen extends StatefulWidget {
  const WordFocusScreen({super.key});

  @override
  State<WordFocusScreen> createState() => _WordFocusScreenState();
}

class _WordFocusScreenState extends State<WordFocusScreen> {
  late final WordFocusController _c =
      WordFocusController(WordService.instance)..addListener(_onChange);
  bool _saved = false;
  bool _record = false;
  int _confetti = 0;

  void _onChange() {
    if (_c.phase == FocusPhase.over && !_saved) {
      _saved = true;
      _record = Records.instance.submit('word_focus', _c.score);
      if (_c.score > 0 && (_record || _c.accuracy >= 70)) _confetti++;
      context.read<StatisticsProvider>().addExerciseCompletion(
            WordFocusController.gameSeconds / 60,
          );
      reportAchievements(context,
          score: _c.score, maxCombo: _c.maxCombo, isRecord: _record);
    }
    setState(() {});
  }

  void _restart() {
    _saved = false;
    _c.start(_c.type);
  }

  @override
  void dispose() {
    _c.removeListener(_onChange);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idle = _c.phase == FocusPhase.idle;
    return GameScaffold(
      title: 'Kelime Odağı',
      accent: _accent,
      trailing: idle ? null : TimerChip(seconds: _c.timeLeft),
      child: Stack(
        children: [
          idle ? _TypePicker(onPick: _c.start) : _play(),
          ConfettiBurst(trigger: _confetti),
          if (_c.phase == FocusPhase.over)
            GameResultOverlay(
              accent: _accent,
              title: 'Süre Doldu',
              isRecord: _record,
              bigValue: '${_c.score}',
              bigLabel: 'PUAN',
              stats: [
                ResultStat('EN İYİ', '${Records.instance.best('word_focus')}'),
                ResultStat('DOĞRULUK', '%${_c.accuracy}'),
                ResultStat('KOMBO', 'x${_c.maxCombo}'),
              ],
              onRestart: _restart,
              onExit: () => Navigator.of(context).maybePop(),
            ),
        ],
      ),
    );
  }

  Widget _play() {
    return Column(
      children: [
        _StatRow(c: _c),
        RecordChase(
          accent: _accent,
          best: Records.instance.best('word_focus'),
          current: _c.score,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(_c.type.blurb,
                    style: AppText.body(13, color: AppColors.textLow)),
              ),
              Text('${_c.found} / ${_c.correctCount}',
                  style: AppText.display(15, color: _accent)),
            ],
          ),
        ),
        Expanded(child: _Ring(c: _c)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.c});
  final WordFocusController c;

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

/// Responsive ring: centre word with options laid out on a circle computed
/// from the real available size (no fixed pixel offsets → no overflow).
class _Ring extends StatelessWidget {
  const _Ring({required this.c});
  final WordFocusController c;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cons) {
        final w = cons.maxWidth;
        final h = cons.maxHeight;
        final cx = w / 2;
        final cy = h / 2;
        final chipW = (w * 0.32).clamp(84.0, 132.0);
        const chipH = 52.0;
        final radius = (min(w, h) / 2) - chipH;

        final children = <Widget>[];
        for (var i = 0; i < c.options.length; i++) {
          final angle = -pi / 2 + i * (2 * pi / c.options.length);
          final dx = cx + radius * cos(angle) - chipW / 2;
          final dy = cy + radius * sin(angle) - chipH / 2;
          children.add(Positioned(
            left: dx,
            top: dy,
            width: chipW,
            height: chipH,
            child: Reveal(
              key: ValueKey('${c.center}_$i'),
              delay: Duration(milliseconds: i * 40),
              child: _OptionChip(
                option: c.options[i],
                onTap: () => c.tap(i),
              ),
            ),
          ));
        }

        // Centre word
        final centerW = (w * 0.4).clamp(110.0, 180.0);
        children.add(Positioned(
          left: cx - centerW / 2,
          top: cy - 36,
          width: centerW,
          child: _CenterWord(word: c.center),
        ));

        return Stack(children: children);
      },
    );
  }
}

class _CenterWord extends StatelessWidget {
  const _CenterWord({required this.word});
  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: Surfaces.accentTile(_accent, radius: 20),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(Tr.upper(word),
            style: AppText.display(24, color: Colors.white)),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({required this.option, required this.onTap});
  final FocusOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final deco = option.found
        ? Surfaces.accentTile(AppColors.success, radius: 16)
        : option.wrong
            ? Surfaces.accentTile(AppColors.danger, radius: 16)
            : Surfaces.tile(radius: 16);
    return GestureDetector(
      onTap: option.found ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: deco,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            Tr.upper(option.word),
            style: AppText.display(15,
                color: option.found ? AppColors.success : AppColors.textHi),
          ),
        ),
      ),
    );
  }
}

class _TypePicker extends StatelessWidget {
  const _TypePicker({required this.onPick});
  final void Function(FocusType) onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bir tür seç', style: AppText.display(22)),
          const SizedBox(height: 6),
          Text('Ortadaki kelimeyle ilişkili olanlara dokun.',
              style: AppText.body(14, color: AppColors.textLow)),
          const SizedBox(height: 24),
          for (var i = 0; i < FocusType.values.length; i++) ...[
            Reveal(
              delay: Duration(milliseconds: i * 60),
              child: _TypeCard(
                type: FocusType.values[i],
                onTap: () => onPick(FocusType.values[i]),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.type, required this.onTap});
  final FocusType type;
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.label, style: AppText.display(18)),
                      const SizedBox(height: 4),
                      Text(type.blurb,
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
