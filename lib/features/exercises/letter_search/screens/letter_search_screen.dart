import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/design/decorations.dart';
import '../../../../core/design/widgets/confetti.dart';
import '../../../../core/design/widgets/game_result.dart';
import '../../../../core/design/widgets/game_scaffold.dart';
import '../../../../core/design/widgets/record_chase.dart';
import '../../../../core/design/widgets/stat_pill.dart';
import '../../../../core/design/widgets/timer_chip.dart';
import '../../../../core/feedback/records.dart';
import '../../../statistics/providers/statistics_provider.dart';
import '../controllers/letter_search_controller.dart';

const _accent = AppColors.visual;

class LetterSearchScreen extends StatefulWidget {
  const LetterSearchScreen({super.key});

  @override
  State<LetterSearchScreen> createState() => _LetterSearchScreenState();
}

class _LetterSearchScreenState extends State<LetterSearchScreen> {
  final LetterSearchController _c = LetterSearchController();
  bool _saved = false;
  bool _record = false;
  int _prevLevel = 1;
  int _confetti = 0;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChange);
    _c.start();
  }

  void _onChange() {
    if (_c.level != _prevLevel) {
      _prevLevel = _c.level;
      _confetti++;
    }
    if (_c.isOver && !_saved) {
      _saved = true;
      _record = Records.instance.submit('letter_search', _c.score);
      context.read<StatisticsProvider>().addExerciseCompletion(
            LetterSearchController.gameSeconds / 60,
          );
    }
    setState(() {});
  }

  void _restart() {
    _saved = false;
    _prevLevel = 1;
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
    return GameScaffold(
      title: 'Harf Arama',
      accent: _accent,
      trailing: TimerChip(seconds: _c.timeLeft),
      child: Stack(
        children: [
          Column(
            children: [
              _StatRow(c: _c),
              RecordChase(
                accent: _accent,
                best: Records.instance.best('letter_search'),
                current: _c.score,
              ),
              _TargetBanner(c: _c),
              Expanded(child: Center(child: _Grid(c: _c))),
              const SizedBox(height: 12),
            ],
          ),
          ConfettiBurst(trigger: _confetti),
          if (_c.isOver)
            GameResultOverlay(
              accent: _accent,
              title: 'Süre Doldu',
              isRecord: _record,
              bigValue: '${_c.score}',
              bigLabel: 'PUAN',
              stats: [
                ResultStat('EN İYİ', '${Records.instance.best('letter_search')}'),
                ResultStat('SEVİYE', '${_c.level}'),
                ResultStat('DOĞRULUK', '%${_c.accuracy}'),
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
  final LetterSearchController c;

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

/// The "find this letter" banner: big target glyph + progress.
class _TargetBanner extends StatelessWidget {
  const _TargetBanner({required this.c});
  final LetterSearchController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: Surfaces.tile(radius: 18),
        child: Row(
          children: [
            Text('BUL', style: AppText.label(11)),
            const SizedBox(width: 14),
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppGradients.visual,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: _accent.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: Text(c.target,
                  style: AppText.display(26, color: Colors.white)),
            ),
            const Spacer(),
            Text('${c.found} / ${c.occurrences}',
                style: AppText.display(20, color: _accent)),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.c});
  final LetterSearchController c;

  @override
  Widget build(BuildContext context) {
    const n = LetterSearchController.size;
    return LayoutBuilder(
      builder: (context, cons) {
        final side =
            (cons.maxWidth < cons.maxHeight ? cons.maxWidth : cons.maxHeight)
                .clamp(240.0, 440.0)
                .toDouble();
        return SizedBox(
          width: side,
          height: side,
          child: Column(
            children: [
              for (var r = 0; r < n; r++)
                Expanded(
                  child: Row(
                    children: [
                      for (var col = 0; col < n; col++)
                        Expanded(child: _Cell(c: c, index: r * n + col)),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.c, required this.index});
  final LetterSearchController c;
  final int index;

  @override
  Widget build(BuildContext context) {
    final found = c.foundCells.contains(index);
    final wrong = c.wrongCell == index;
    final deco = found
        ? Surfaces.accentTile(AppColors.success, radius: 12)
        : wrong
            ? Surfaces.accentTile(AppColors.danger, radius: 12)
            : Surfaces.tile(radius: 12);

    return GestureDetector(
      onTap: () => c.tap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.all(3),
        alignment: Alignment.center,
        decoration: deco,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            c.grid[index],
            style: AppText.display(
              20,
              color: found ? AppColors.success : AppColors.textMid,
            ),
          ),
        ),
      ),
    );
  }
}
