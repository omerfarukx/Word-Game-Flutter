import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/confetti.dart';
import '../../../../core/design/widgets/game_result.dart';
import '../../../../core/design/widgets/game_scaffold.dart';
import '../../../../core/design/widgets/record_chase.dart';
import '../../../../core/design/widgets/reveal.dart';
import '../../../../core/design/widgets/stat_pill.dart';
import '../../../../core/design/widgets/timer_chip.dart';
import '../../../../core/feedback/achievements.dart';
import '../../../../core/feedback/records.dart';
import '../../../../core/text/turkish.dart';
import '../../../../core/words/word_service.dart';
import '../../../statistics/providers/statistics_provider.dart';
import '../controllers/word_recognition_controller.dart';

const _accent = AppColors.word;

class WordRecognitionScreen extends StatefulWidget {
  const WordRecognitionScreen({super.key});

  @override
  State<WordRecognitionScreen> createState() => _WordRecognitionScreenState();
}

class _WordRecognitionScreenState extends State<WordRecognitionScreen> {
  late final WordRecognitionController _c =
      WordRecognitionController(WordService.instance)..addListener(_onChange);
  final _input = TextEditingController();
  final _focus = FocusNode();
  bool _saved = false;
  bool _record = false;
  int _confetti = 0;

  void _onChange() {
    if (_c.phase == RecogPhase.input) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
    if (_c.phase == RecogPhase.over && !_saved) {
      _saved = true;
      _record = Records.instance.submit('word_recognition', _c.score);
      if (_c.score > 0 && (_record || _c.accuracy >= 70)) _confetti++;
      context.read<StatisticsProvider>().addExerciseCompletion(
            WordRecognitionController.gameSeconds / 60,
          );
      reportAchievements(context, score: _c.score, isRecord: _record);
    }
    setState(() {});
  }

  void _submit() {
    _c.submit(_input.text);
    _input.clear();
  }

  void _restart() {
    _saved = false;
    _input.clear();
    _c.start(_c.difficulty);
  }

  @override
  void dispose() {
    _c.removeListener(_onChange);
    _c.dispose();
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idle = _c.phase == RecogPhase.idle;
    return GameScaffold(
      title: 'Kelime Tanıma',
      accent: _accent,
      trailing: idle ? null : TimerChip(seconds: _c.timeLeft),
      child: Stack(
        children: [
          idle ? _DifficultyPicker(onPick: _c.start) : _play(),
          ConfettiBurst(trigger: _confetti),
          if (_c.phase == RecogPhase.over)
            GameResultOverlay(
              accent: _accent,
              title: 'Süre Doldu',
              isRecord: _record,
              bigValue: '${_c.score}',
              bigLabel: 'DOĞRU',
              stats: [
                ResultStat('EN İYİ', '${Records.instance.best('word_recognition')}'),
                ResultStat('DOĞRULUK', '%${_c.accuracy}'),
                ResultStat('ZORLUK', _c.difficulty.label),
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
          best: Records.instance.best('word_recognition'),
          current: _c.score,
        ),
        Expanded(child: Center(child: _Stage(c: _c))),
        if (_c.phase == RecogPhase.input)
          _InputBar(input: _input, focus: _focus, onSubmit: _submit),
      ],
    );
  }
}

// ── Difficulty picker ────────────────────────────────────────────────────────
class _DifficultyPicker extends StatelessWidget {
  const _DifficultyPicker({required this.onPick});
  final void Function(RecogDifficulty) onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bir kelime kısa bir an belirir.', style: AppText.display(22)),
          const SizedBox(height: 6),
          Text('Kaybolmadan önce oku, sonra hatırladığını yaz.',
              style: AppText.body(14, color: AppColors.textLow)),
          const SizedBox(height: 24),
          for (var i = 0; i < RecogDifficulty.values.length; i++) ...[
            Reveal(
              delay: Duration(milliseconds: i * 70),
              child: _DifficultyCard(
                difficulty: RecogDifficulty.values[i],
                onTap: () => onPick(RecogDifficulty.values[i]),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({required this.difficulty, required this.onTap});
  final RecogDifficulty difficulty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(difficulty.label, style: AppText.display(18)),
                    const SizedBox(height: 4),
                    Text(difficulty.blurb,
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
    );
  }
}

// ── Playing ──────────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  const _StatRow({required this.c});
  final WordRecognitionController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(child: StatPill(label: 'DOĞRU', value: '${c.score}')),
          const SizedBox(width: 10),
          Expanded(child: StatPill(label: 'DOĞRULUK', value: '%${c.accuracy}')),
          const SizedBox(width: 10),
          Expanded(child: StatPill(label: 'ZORLUK', value: c.difficulty.label)),
        ],
      ),
    );
  }
}

/// The central card whose content depends on the round phase.
class _Stage extends StatelessWidget {
  const _Stage({required this.c});
  final WordRecognitionController c;

  @override
  Widget build(BuildContext context) {
    final (Color border, Widget child) = switch (c.phase) {
      RecogPhase.showing => (
          _accent,
          Text(Tr.upper(c.current),
              key: const ValueKey('show'),
              textAlign: TextAlign.center,
              style: AppText.display(34, color: AppColors.textHi)),
        ),
      RecogPhase.feedback => c.lastCorrect
          ? (
              AppColors.success,
              Column(
                key: const ValueKey('ok'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 40),
                  const SizedBox(height: 10),
                  Text('Doğru',
                      style:
                          AppText.display(22, color: AppColors.success)),
                ],
              ),
            )
          : (
              AppColors.danger,
              Column(
                key: const ValueKey('no'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cancel_rounded,
                      color: AppColors.danger, size: 36),
                  const SizedBox(height: 8),
                  Text('Doğrusu', style: AppText.label(11)),
                  const SizedBox(height: 2),
                  Text(Tr.upper(c.current),
                      style: AppText.display(26, color: AppColors.textHi)),
                ],
              ),
            ),
      _ => (
          AppColors.stroke,
          Text('?',
              key: const ValueKey('q'),
              style: AppText.display(48, color: AppColors.textLow)),
        ),
    };

    final glow = border == AppColors.stroke
        ? const Color(0x55000000)
        : border.withValues(alpha: 0.35);
    return Container(
      width: 260,
      height: 160,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceHi, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(color: glow, blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: child,
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.input,
    required this.focus,
    required this.onSubmit,
  });

  final TextEditingController input;
  final FocusNode focus;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.bgDeep,
        border: Border(top: BorderSide(color: AppColors.stroke)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: input,
              focusNode: focus,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              style: AppText.display(20),
              cursorColor: _accent,
              decoration: InputDecoration(
                hintText: 'gördüğün kelime…',
                hintStyle: AppText.body(16, color: AppColors.textLow),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _accent, width: 1.6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 54,
            child: PrimaryButton(
              label: '',
              icon: Icons.check_rounded,
              color: _accent,
              onTap: onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
