import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/design/decorations.dart';
import '../../../../core/design/widgets/confetti.dart';
import '../../../../core/design/widgets/count_up.dart';
import '../../../../core/design/widgets/game_scaffold.dart';
import '../../../../core/design/widgets/power_bar.dart';
import '../../../../core/design/widgets/record_chase.dart';
import '../../../../core/design/widgets/shaker.dart';
import '../../../../core/design/widgets/stat_pill.dart';
import '../../../../core/feedback/achievements.dart';
import '../../../../core/feedback/records.dart';
import '../../../../core/text/turkish.dart';
import '../../../../core/words/word_service.dart';
import '../../../statistics/providers/statistics_provider.dart';
import '../controllers/anagram_controller.dart';

const _accent = AppColors.word;
const _recordId = 'anagram';

class AnagramScreen extends StatefulWidget {
  const AnagramScreen({super.key});

  @override
  State<AnagramScreen> createState() => _AnagramScreenState();
}

class _AnagramScreenState extends State<AnagramScreen> {
  late final AnagramController _c =
      AnagramController(WordService.instance)..addListener(_onChange);

  bool _saved = false;
  bool _isRecord = false;
  int _confetti = 0;

  @override
  void initState() {
    super.initState();
    _c.start();
  }

  void _onChange() {
    if (_c.isOver && !_saved) {
      _saved = true;
      _isRecord = Records.instance.submit(_recordId, _c.score) && _c.score > 0;
      if (_isRecord) _confetti++;
      final stats = context.read<StatisticsProvider>();
      stats.addExerciseCompletion(AnagramController.gameSeconds / 60);
      reportAchievements(context,
          score: _c.score, maxCombo: _c.maxCombo, isRecord: _isRecord);
    }
    setState(() {});
  }

  void _restart() {
    _saved = false;
    _isRecord = false;
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
      title: 'Karışık Harfler',
      accent: _accent,
      trailing: _TimerChip(seconds: _c.timeLeft, frozen: _c.isFrozen),
      child: Stack(
        children: [
          Column(
            children: [
              _StatRow(c: _c),
              RecordChase(
                accent: _accent,
                best: Records.instance.best(_recordId),
                current: _c.score,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _Puzzle(
                    key: ValueKey(_c.roundId),
                    c: _c,
                  ),
                ),
              ),
              PowerBar(
                accent: _accent,
                onHint: _c.useHint,
                hints: _c.hints,
                onJoker: _c.useJoker,
                jokers: _c.jokers,
                onFreeze: _c.freeze,
                freezes: _c.freezes,
                frozen: _c.isFrozen,
              ),
            ],
          ),
          ConfettiBurst(trigger: _confetti),
          if (_c.isOver)
            _GameOverCard(
              c: _c,
              isRecord: _isRecord,
              onRestart: _restart,
              onExit: () => Navigator.of(context).maybePop(),
            ),
        ],
      ),
    );
  }
}

// ── Timer ────────────────────────────────────────────────────────────────────
class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.seconds, required this.frozen});
  final int seconds;
  final bool frozen;

  @override
  Widget build(BuildContext context) {
    final low = seconds <= 12 && !frozen;
    final color =
        frozen ? AppColors.visual : (low ? AppColors.danger : AppColors.textHi);
    final mm = (seconds ~/ 60).toString();
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: low
            ? AppColors.danger.withValues(alpha: 0.14)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: frozen
              ? AppColors.visual.withValues(alpha: 0.5)
              : (low ? AppColors.danger.withValues(alpha: 0.5) : AppColors.stroke),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(frozen ? Icons.ac_unit_rounded : Icons.timer_outlined,
              size: 16, color: color),
          const SizedBox(width: 6),
          Text('$mm:$ss', style: AppText.display(16, color: color)),
        ],
      ),
    );
  }
}

// ── Stat row ─────────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  const _StatRow({required this.c});
  final AnagramController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
          Expanded(child: StatPill(label: 'ÇÖZÜLEN', value: '${c.solved}')),
        ],
      ),
    );
  }
}

// ── Puzzle (signature element) ───────────────────────────────────────────────
class _Puzzle extends StatelessWidget {
  const _Puzzle({super.key, required this.c});
  final AnagramController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${c.target.length} HARF',
            style: AppText.label(11, color: _accent),
          ),
          const SizedBox(height: 14),
          Shaker(trigger: c.rejectTick, child: _AnswerRow(c: c)),
          const SizedBox(height: 12),
          _ClearButton(onTap: c.clearAnswer, enabled: c.placement.length > c.locked),
          const SizedBox(height: 28),
          _Tray(c: c),
          const SizedBox(height: 6),
          Text(
            'Harflere dokunarak gerçek bir kelime kur',
            textAlign: TextAlign.center,
            style: AppText.body(13, color: AppColors.textLow),
          ),
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({required this.c});
  final AnagramController c;

  @override
  Widget build(BuildContext context) {
    final slots = List.generate(c.target.length, (s) {
      if (s < c.placement.length) {
        final tileIndex = c.placement[s];
        final isLocked = s < c.locked;
        return _AnswerTile(
          letter: c.letters[tileIndex],
          locked: isLocked,
          correct: c.celebrating,
          onTap: isLocked || c.celebrating ? null : () => c.unplace(tileIndex),
        );
      }
      return const _EmptySlot();
    });
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: slots,
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.letter,
    required this.locked,
    this.correct = false,
    this.onTap,
  });
  final String letter;
  final bool locked;
  final bool correct;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration;
    final Color textColor;
    if (correct) {
      decoration = BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF49E6AC), Color(0xFF1FB985)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.6),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      );
      textColor = Colors.white;
    } else if (locked) {
      decoration = Surfaces.accentTile(_accent, radius: 12);
      textColor = Colors.white;
    } else {
      decoration =
          Surfaces.tile(radius: 12, border: _accent.withValues(alpha: 0.4));
      textColor = _accent;
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: correct ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Container(
          width: 46,
          height: 56,
          alignment: Alignment.center,
          decoration: decoration,
          child: Text(
            Tr.upper(letter),
            style: AppText.display(26, color: textColor),
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.bgDeep.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.stroke,
          width: 1.4,
        ),
      ),
    );
  }
}

class _Tray extends StatelessWidget {
  const _Tray({required this.c});
  final AnagramController c;

  @override
  Widget build(BuildContext context) {
    final tiles = List.generate(c.letters.length, (i) {
      final placed = c.isPlaced(i);
      return _TrayTile(
        letter: c.letters[i],
        placed: placed,
        onTap: placed ? null : () => c.place(i),
      );
    });
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: tiles,
    );
  }
}

class _TrayTile extends StatelessWidget {
  const _TrayTile({required this.letter, required this.placed, this.onTap});
  final String letter;
  final bool placed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (placed) {
      return Container(
        width: 54,
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.bgDeep.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.stroke.withValues(alpha: 0.5)),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 62,
        alignment: Alignment.center,
        decoration: Surfaces.tile(radius: 14),
        child: Text(Tr.upper(letter), style: AppText.display(30)),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap, required this.enabled});
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.backspace_outlined,
                    size: 15, color: AppColors.textLow),
                const SizedBox(width: 6),
                Text('Temizle', style: AppText.label(11)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Game over ────────────────────────────────────────────────────────────────
class _GameOverCard extends StatelessWidget {
  const _GameOverCard({
    required this.c,
    required this.isRecord,
    required this.onRestart,
    required this.onExit,
  });

  final AnagramController c;
  final bool isRecord;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final best = Records.instance.best(_recordId);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isRecord ? '🏆 Yeni Rekor!' : 'Süre Doldu',
                    style: AppText.display(24,
                        color:
                            isRecord ? AppColors.reading : AppColors.textHi)),
                const SizedBox(height: 4),
                Text('${c.solved} kelime çözdün',
                    style: AppText.body(14, color: AppColors.textLow)),
                const SizedBox(height: 20),
                CountUp('${c.score}',
                    style: AppText.display(56, color: _accent)),
                Text('PUAN', style: AppText.label(11)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _MiniStat(label: 'EN İYİ', value: '$best')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _MiniStat(
                            label: 'ÇÖZÜLEN', value: '${c.solved}')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _MiniStat(
                            label: 'KOMBO', value: 'x${c.maxCombo}')),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _OutlineButton(label: 'Çıkış', onTap: onExit)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _FilledButton(
                            label: 'Tekrar Oyna', onTap: onRestart)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHi,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.display(16)),
          const SizedBox(height: 4),
          Text(label, style: AppText.label(9)),
        ],
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  const _FilledButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _accent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(label,
                style: AppText.body(15,
                    weight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.stroke),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(label,
                style: AppText.body(15,
                    weight: FontWeight.w600, color: AppColors.textMid)),
          ),
        ),
      ),
    );
  }
}
