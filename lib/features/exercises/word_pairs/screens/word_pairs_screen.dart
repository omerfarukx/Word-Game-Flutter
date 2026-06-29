import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/design/decorations.dart';
import '../../../../core/design/widgets/game_result.dart';
import '../../../../core/design/widgets/game_scaffold.dart';
import '../../../../core/design/widgets/shaker.dart';
import '../../../../core/design/widgets/stat_pill.dart';
import '../../../../core/design/widgets/timer_chip.dart';
import '../../../../core/text/turkish.dart';
import '../../../../core/words/word_service.dart';
import '../../../statistics/providers/statistics_provider.dart';
import '../controllers/word_pairs_controller.dart';

const _accent = AppColors.word;

class WordPairsScreen extends StatefulWidget {
  const WordPairsScreen({super.key});

  @override
  State<WordPairsScreen> createState() => _WordPairsScreenState();
}

class _WordPairsScreenState extends State<WordPairsScreen> {
  late final WordPairsController _c =
      WordPairsController(WordService.instance)..addListener(_onChange);
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _c.start();
  }

  void _onChange() {
    if (_c.isOver && !_saved) {
      _saved = true;
      context.read<StatisticsProvider>().addExerciseCompletion(
            WordPairsController.gameSeconds / 60,
          );
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
    return GameScaffold(
      title: 'Kelime Çiftleri',
      accent: _accent,
      trailing: TimerChip(seconds: _c.timeLeft),
      child: Stack(
        children: [
          Column(
            children: [
              _StatRow(c: _c),
              _Prompt(found: _c.found, targets: _c.targets),
              Expanded(
                child: Shaker(
                  trigger: _c.wrongTick,
                  child: _Grid(c: _c),
                ),
              ),
            ],
          ),
          if (_c.isOver)
            GameResultOverlay(
              accent: _accent,
              title: 'Süre Doldu',
              bigValue: '${_c.score}',
              bigLabel: 'PUAN',
              stats: [
                ResultStat('SEVİYE', '${_c.level}'),
                ResultStat('KOMBO', 'x${_c.maxCombo}'),
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
  final WordPairsController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
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
          Expanded(child: StatPill(label: 'SEVİYE', value: '${c.level}')),
        ],
      ),
    );
  }
}

class _Prompt extends StatelessWidget {
  const _Prompt({required this.found, required this.targets});
  final int found;
  final int targets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'İki satırı farklı olan kartları bul',
              style: AppText.body(13, color: AppColors.textLow),
            ),
          ),
          Text('$found / $targets',
              style: AppText.display(15, color: _accent)),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.c});
  final WordPairsController c;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      crossAxisCount: WordPairsController.columns,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.82,
      children: [
        for (var i = 0; i < c.cards.length; i++)
          _Card(card: c.cards[i], onTap: () => c.tapCard(i)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.card, required this.onTap});
  final PairCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration deco = card.found
        ? Surfaces.accentTile(AppColors.success, radius: 16)
        : card.wrong
            ? Surfaces.accentTile(AppColors.danger, radius: 16)
            : Surfaces.tile(radius: 16);

    return GestureDetector(
      onTap: card.found ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: deco,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _Word(card.top)),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              color: AppColors.stroke,
            ),
            Expanded(child: _Word(card.bottom)),
            if (card.found)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _Word extends StatelessWidget {
  const _Word(this.word);
  final String word;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          Tr.upper(word),
          maxLines: 1,
          style: AppText.display(16, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
