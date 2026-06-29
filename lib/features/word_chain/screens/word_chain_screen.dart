import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/design/decorations.dart';
import '../../../core/design/widgets/confetti.dart';
import '../../../core/design/widgets/game_scaffold.dart';
import '../../../core/design/widgets/reveal.dart';
import '../../../core/design/widgets/shaker.dart';
import '../../../core/design/widgets/stat_pill.dart';
import '../../../core/text/turkish.dart';
import '../../../core/words/word_service.dart';
import '../../statistics/providers/statistics_provider.dart';
import '../controllers/word_chain_controller.dart';

const _accent = AppColors.word;

class WordChainScreen extends StatefulWidget {
  const WordChainScreen({super.key});

  @override
  State<WordChainScreen> createState() => _WordChainScreenState();
}

class _WordChainScreenState extends State<WordChainScreen> {
  late final WordChainController _c =
      WordChainController(WordService.instance)..addListener(_onChange);
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();

  bool _saved = false;
  int _lastLen = 0;
  int _confetti = 0;

  @override
  void initState() {
    super.initState();
    _c.start();
  }

  void _onChange() {
    if (_c.chain.length != _lastLen) {
      _lastLen = _c.chain.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        }
      });
    }
    if (_c.isOver && !_saved) {
      _saved = true;
      final stats = context.read<StatisticsProvider>();
      if (_c.score > 0 && _c.score >= stats.bestWordChainScore) _confetti++;
      stats.saveWordChainScore(_c.score);
      stats.addExerciseCompletion(WordChainController.gameSeconds / 60);
    }
    setState(() {});
  }

  void _submit() {
    if (_input.text.trim().isEmpty) return;
    _c.submit(_input.text);
    _input.clear();
    _focus.requestFocus();
  }

  void _restart() {
    _saved = false;
    _lastLen = 0;
    _input.clear();
    _c.start();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _c.removeListener(_onChange);
    _c.dispose();
    _input.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Kelime Zinciri',
      accent: _accent,
      trailing: _TimerChip(seconds: _c.timeLeft),
      child: Stack(
        children: [
          Column(
            children: [
              _StatRow(c: _c),
              Expanded(
                child: _c.chain.isEmpty
                    ? const _EmptyHint()
                    : _ChainList(words: _c.chain, scroll: _scroll),
              ),
              _InputBar(
                controller: _c,
                input: _input,
                focus: _focus,
                onSubmit: _submit,
              ),
            ],
          ),
          ConfettiBurst(trigger: _confetti),
          if (_c.isOver)
            _GameOverCard(c: _c, onRestart: _restart, onExit: () => Navigator.of(context).maybePop()),
        ],
      ),
    );
  }
}

// ── Timer ──────────────────────────────────────────────────────────────────
class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.seconds});
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final low = seconds <= 15;
    final color = low ? AppColors.danger : AppColors.textHi;
    final mm = (seconds ~/ 60).toString();
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: low ? AppColors.danger.withValues(alpha: 0.14) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: low ? AppColors.danger.withValues(alpha: 0.5) : AppColors.stroke,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: color),
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
  final WordChainController c;

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
          Expanded(
            child: StatPill(
              label: 'EN UZUN',
              value: c.longestWord.isEmpty ? '–' : '${c.longestWord.length}',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chain (signature element) ────────────────────────────────────────────────
class _ChainList extends StatelessWidget {
  const _ChainList({required this.words, required this.scroll});
  final List<String> words;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      itemCount: words.length,
      itemBuilder: (context, i) => Reveal(
        key: ValueKey(i),
        child: _ChainTile(
          word: words[i],
          isFirst: i == 0,
          isLast: i == words.length - 1,
          order: i + 1,
        ),
      ),
    );
  }
}

class _ChainTile extends StatelessWidget {
  const _ChainTile({
    required this.word,
    required this.isFirst,
    required this.isLast,
    required this.order,
  });

  final String word;
  final bool isFirst;
  final bool isLast;
  final int order;

  @override
  Widget build(BuildContext context) {
    final upper = Tr.upper(word);
    final link = upper.substring(0, 1); // the connecting letter

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rail: continuous line + node carrying the link letter.
          SizedBox(
            width: 46,
            child: Column(
              children: [
                _Rail(visible: !isFirst),
                _Node(letter: link, glow: isLast),
                _Rail(visible: !isLast),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: _WordChip(upper: upper),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Center(
          child: Container(
            width: 2,
            color: visible ? AppColors.stroke : Colors.transparent,
          ),
        ),
      );
}

class _Node extends StatelessWidget {
  const _Node({required this.letter, required this.glow});
  final String letter;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: glow ? AppGradients.word : null,
        color: glow ? null : AppColors.surfaceHi,
        border: Border.all(
          color: glow ? Colors.transparent : AppColors.stroke,
          width: 1.5,
        ),
        boxShadow: glow
            ? [BoxShadow(color: _accent.withValues(alpha: 0.6), blurRadius: 20)]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppText.display(
          16,
          color: glow ? Colors.white : AppColors.wordSoft,
        ),
      ),
    );
  }
}

/// The word, with its first and last letters tinted to show what it links from
/// and what the next word must link to.
class _WordChip extends StatelessWidget {
  const _WordChip({required this.upper});
  final String upper;

  @override
  Widget build(BuildContext context) {
    final chars = upper.split('');
    final spans = <TextSpan>[];
    for (var i = 0; i < chars.length; i++) {
      final color = i == 0
          ? _accent
          : (i == chars.length - 1 ? AppColors.wordSoft : AppColors.textHi);
      spans.add(TextSpan(text: chars[i], style: AppText.display(20, color: color)));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: Surfaces.tile(radius: 14),
      child: Row(
        children: [
          Expanded(child: Text.rich(TextSpan(children: spans))),
          Text('${chars.length}', style: AppText.label(12)),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_rounded, size: 56, color: _accent.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text('Zinciri başlat', style: AppText.display(22)),
            const SizedBox(height: 8),
            Text(
              'Bir kelime yaz. Sonraki kelime onun son harfiyle başlasın.',
              textAlign: TextAlign.center,
              style: AppText.body(14, color: AppColors.textLow),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Input ────────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.input,
    required this.focus,
    required this.onSubmit,
  });

  final WordChainController controller;
  final TextEditingController input;
  final FocusNode focus;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final req = controller.requiredLetter;
    final reject = controller.reject;
    final prompt = req == null
        ? 'İstediğin kelimeyle başla'
        : '“${Tr.upper(req)}” ile başlayan bir kelime';

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgDeep,
        border: Border(top: BorderSide(color: AppColors.stroke)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: reject != null
                ? Padding(
                    key: ValueKey(controller.rejectTick),
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 15, color: AppColors.danger),
                        const SizedBox(width: 6),
                        Text(controller.rejectMessage(reject),
                            style: AppText.body(13, color: AppColors.danger)),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(prompt,
                        style: AppText.body(13, color: AppColors.textLow)),
                  ),
          ),
          Shaker(
            trigger: controller.rejectTick,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    focusNode: focus,
                    autofocus: true,
                    enabled: controller.isActive,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => onSubmit(),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-ZçğıöşüÇĞİÖŞÜ]')),
                    ],
                    style: AppText.display(20),
                    cursorColor: _accent,
                    decoration: InputDecoration(
                      hintText: 'kelime yaz…',
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
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.stroke),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _SendButton(
                  enabled: controller.isActive,
                  onTap: onSubmit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.word,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [BoxShadow(color: _accent.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 5))]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onTap : null,
            child: const SizedBox(
              width: 54,
              height: 52,
              child: Icon(Icons.arrow_upward_rounded, color: Colors.white),
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
    required this.onRestart,
    required this.onExit,
  });

  final WordChainController c;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final best = context.watch<StatisticsProvider>().bestWordChainScore;
    final isRecord = c.score >= best && c.score > 0;

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
                    style: AppText.display(24, color: isRecord ? AppColors.reading : AppColors.textHi)),
                const SizedBox(height: 4),
                Text('${c.chain.length} kelimelik zincir',
                    style: AppText.body(14, color: AppColors.textLow)),
                const SizedBox(height: 20),
                Text('${c.score}',
                    style: AppText.display(56, color: _accent)),
                Text('PUAN', style: AppText.label(11)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _MiniStat(label: 'EN İYİ', value: '$best')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _MiniStat(
                            label: 'EN UZUN',
                            value: c.longestWord.isEmpty
                                ? '–'
                                : Tr.upper(c.longestWord))),
                    const SizedBox(width: 10),
                    Expanded(child: _MiniStat(label: 'KOMBO', value: 'x${c.maxCombo}')),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineButton(label: 'Çıkış', onTap: onExit),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FilledButton(label: 'Tekrar Oyna', onTap: onRestart),
                    ),
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
