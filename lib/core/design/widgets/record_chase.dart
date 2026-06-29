import 'package:flutter/material.dart';

import '../../feedback/juice.dart';
import '../app_colors.dart';
import '../app_typography.dart';

/// Live "chasing your best" strip shown during play. Below your record it
/// shows how far away you are with a progress bar; the moment you pass it, it
/// flips to a glowing "YENİ REKOR!" and fires a cue. Hidden until a record
/// exists so first-time players aren't nagged.
class RecordChase extends StatefulWidget {
  const RecordChase({
    super.key,
    required this.accent,
    required this.best,
    required this.current,
  });

  final Color accent;
  final int best;
  final int current;

  @override
  State<RecordChase> createState() => _RecordChaseState();
}

class _RecordChaseState extends State<RecordChase> {
  @override
  void didUpdateWidget(RecordChase old) {
    super.didUpdateWidget(old);
    if (widget.best > 0 &&
        old.current <= widget.best &&
        widget.current > widget.best) {
      Juice.levelUp(); // just beat your personal best mid-game
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.best <= 0) return const SizedBox(height: 4);
    final passed = widget.current > widget.best;
    final accent = widget.accent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: passed
          ? Row(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    size: 16, color: accent),
                const SizedBox(width: 6),
                Text('YENİ REKOR!',
                    style: AppText.label(12, color: accent)),
                const Spacer(),
                Text('${widget.current}', style: AppText.display(14, color: accent)),
              ],
            )
          : Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    size: 14, color: AppColors.textLow),
                const SizedBox(width: 6),
                Text('REKORA ${widget.best - widget.current}',
                    style: AppText.label(10)),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value:
                          (widget.current / widget.best).clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: AppColors.surface,
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
