import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/design/decorations.dart';
import '../../../../core/design/widgets/confetti.dart';
import '../../../../core/design/widgets/game_result.dart';
import '../../../../core/design/widgets/game_scaffold.dart';
import '../../../../core/feedback/achievements.dart';
import '../../../../core/feedback/records.dart';
import '../../../statistics/providers/statistics_provider.dart';
import '../controllers/schultz_controller.dart';

const _accent = AppColors.visual;

class EyeFocusScreen extends StatefulWidget {
  const EyeFocusScreen({super.key});

  @override
  State<EyeFocusScreen> createState() => _EyeFocusScreenState();
}

class _EyeFocusScreenState extends State<EyeFocusScreen> {
  final SchultzController _c = SchultzController();
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
    if (_c.isComplete && !_saved) {
      _saved = true;
      _confetti++;
      _record = Records.instance
          .submit('schultz', _c.elapsedSeconds, lowerIsBetter: true);
      context.read<StatisticsProvider>().addExerciseCompletion(
            _c.elapsedSeconds / 60,
          );
      reportAchievements(context, isRecord: _record);
    }
    setState(() {});
  }

  void _restart() {
    _saved = false;
    _c.start();
  }

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Göz Odaklama',
      accent: _accent,
      trailing: _ElapsedChip(text: _fmt(_c.elapsedSeconds)),
      child: Stack(
        children: [
          Column(
            children: [
              _Banner(c: _c),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Ortaya odaklan, sayıları 1’den 36’ya sırayla bul.',
                  style: AppText.body(13, color: AppColors.textLow),
                ),
              ),
              Expanded(child: Center(child: _Grid(c: _c))),
              const SizedBox(height: 12),
            ],
          ),
          ConfettiBurst(trigger: _confetti),
          if (_c.isComplete)
            GameResultOverlay(
              accent: _accent,
              title: 'Tamamlandı! 🎯',
              isRecord: _record,
              bigValue: _fmt(_c.elapsedSeconds),
              bigLabel: 'SÜRE',
              stats: [
                ResultStat('EN İYİ', _fmt(Records.instance.best('schultz'))),
                ResultStat('YANLIŞ', '${_c.wrongCount}'),
                const ResultStat('TABLO', '6×6'),
              ],
              onRestart: _restart,
              onExit: () => Navigator.of(context).maybePop(),
            ),
        ],
      ),
    );
  }
}

class _ElapsedChip extends StatelessWidget {
  const _ElapsedChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: Surfaces.tile(radius: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 16, color: AppColors.textHi),
          const SizedBox(width: 6),
          Text(text, style: AppText.display(16)),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.c});
  final SchultzController c;

  @override
  Widget build(BuildContext context) {
    final next = c.currentTarget > SchultzController.total
        ? SchultzController.total
        : c.currentTarget;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: Surfaces.tile(radius: 18),
        child: Row(
          children: [
            Text('SIRADAKİ', style: AppText.label(11)),
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
              child: Text('$next',
                  style: AppText.display(22, color: Colors.white)),
            ),
            const Spacer(),
            Text('${c.found.length} / ${SchultzController.total}',
                style: AppText.display(18, color: _accent)),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.c});
  final SchultzController c;

  @override
  Widget build(BuildContext context) {
    const n = SchultzController.size;
    return LayoutBuilder(
      builder: (context, cons) {
        final side =
            (cons.maxWidth < cons.maxHeight ? cons.maxWidth : cons.maxHeight)
                .clamp(260.0, 440.0)
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
  final SchultzController c;
  final int index;

  @override
  Widget build(BuildContext context) {
    final value = c.numbers[index];
    final done = c.found.contains(value);
    final wrong = c.wrongCell == value;

    final deco = done
        ? Surfaces.accentTile(AppColors.success, radius: 12)
        : wrong
            ? Surfaces.accentTile(AppColors.danger, radius: 12)
            : Surfaces.tile(radius: 12);

    return GestureDetector(
      onTap: () => c.tapNumber(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.all(3),
        alignment: Alignment.center,
        decoration: deco,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$value',
            style: AppText.display(
              18,
              color: done
                  ? AppColors.success.withValues(alpha: 0.7)
                  : AppColors.textHi,
            ),
          ),
        ),
      ),
    );
  }
}
