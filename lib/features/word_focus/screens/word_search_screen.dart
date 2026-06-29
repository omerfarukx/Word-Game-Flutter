import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/design/decorations.dart';
import '../../../core/design/widgets/confetti.dart';
import '../../../core/design/widgets/game_result.dart';
import '../../../core/design/widgets/game_scaffold.dart';
import '../../../core/design/widgets/stat_pill.dart';
import '../../../core/design/widgets/timer_chip.dart';
import '../../../core/feedback/records.dart';
import '../../../core/words/word_service.dart';
import '../../statistics/providers/statistics_provider.dart';
import '../controllers/word_search_controller.dart';

const _accent = AppColors.word;

class WordSearchScreen extends StatefulWidget {
  const WordSearchScreen({super.key});

  @override
  State<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  final WordSearchController _c = WordSearchController();
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
      _record = Records.instance.submit('word_search', _c.score);
      context.read<StatisticsProvider>().addExerciseCompletion(
            WordSearchController.gameSeconds / 60,
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
    // WordService kept loaded app-wide; not required here but ensures parity.
    assert(WordService.isReady);
    return GameScaffold(
      title: 'Kelime Bulma',
      accent: _accent,
      trailing: TimerChip(seconds: _c.timeLeft),
      child: Stack(
        children: [
          Column(
            children: [
              _StatRow(c: _c),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Text('TEMA', style: AppText.label(10)),
                    const SizedBox(width: 8),
                    Text(_c.themeName, style: AppText.display(15, color: _accent)),
                    const Spacer(),
                    Text('${_c.foundCount} / ${_c.targets.length}',
                        style: AppText.display(15)),
                  ],
                ),
              ),
              Expanded(child: Center(child: _Grid(c: _c))),
              _WordBank(c: _c),
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
                ResultStat('EN İYİ', '${Records.instance.best('word_search')}'),
                ResultStat('SEVİYE', '${_c.level}'),
                ResultStat('TEMA', _c.themeName),
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
  final WordSearchController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(child: StatPill(label: 'SKOR', value: '${c.score}')),
          const SizedBox(width: 10),
          Expanded(child: StatPill(label: 'SEVİYE', value: '${c.level}')),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.c});
  final WordSearchController c;

  @override
  Widget build(BuildContext context) {
    const n = WordSearchController.size;
    return LayoutBuilder(
      builder: (context, cons) {
        final side = cons.maxWidth < cons.maxHeight
            ? cons.maxWidth
            : cons.maxHeight;
        final dim = side.clamp(240.0, 420.0).toDouble();
        final cell = dim / n;

        int? rc(Offset o) {
          final r = (o.dy / cell).floor();
          final col = (o.dx / cell).floor();
          if (r < 0 || r >= n || col < 0 || col >= n) return null;
          return r * n + col;
        }

        return GestureDetector(
          onPanStart: (d) {
            final id = rc(d.localPosition);
            if (id != null) c.selectStart(id ~/ n, id % n);
          },
          onPanUpdate: (d) {
            final id = rc(d.localPosition);
            if (id != null) c.selectUpdate(id ~/ n, id % n);
          },
          onPanEnd: (_) => c.selectEnd(),
          child: Container(
            width: dim,
            height: dim,
            decoration: Surfaces.tile(radius: 18),
            child: Column(
              children: [
                for (var r = 0; r < n; r++)
                  Expanded(
                    child: Row(
                      children: [
                        for (var col = 0; col < n; col++)
                          Expanded(child: _Cell(c: c, id: r * n + col)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.c, required this.id});
  final WordSearchController c;
  final int id;

  @override
  Widget build(BuildContext context) {
    const n = WordSearchController.size;
    final found = c.foundCells.contains(id);
    final selected = c.selection.contains(id);
    final letter = c.grid[id ~/ n][id % n];

    final (Color bg, Color fg) = found
        ? (AppColors.success.withValues(alpha: 0.30), Colors.white)
        : selected
            ? (_accent, Colors.white)
            : (Colors.transparent, AppColors.textMid);

    return Container(
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(letter, style: AppText.display(18, color: fg)),
      ),
    );
  }
}

class _WordBank extends StatelessWidget {
  const _WordBank({required this.c});
  final WordSearchController c;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (final t in c.targets)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: t.found
                    ? AppColors.success.withValues(alpha: 0.16)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: t.found
                      ? AppColors.success.withValues(alpha: 0.5)
                      : AppColors.stroke,
                ),
              ),
              child: Text(
                t.word,
                style: AppText.body(
                  13,
                  weight: FontWeight.w600,
                  color: t.found ? AppColors.success : AppColors.textMid,
                ).copyWith(
                  decoration: t.found ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
