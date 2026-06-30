import 'package:flutter/material.dart';

import '../../feedback/juice.dart';
import '../app_colors.dart';
import '../app_typography.dart';

/// A row of power-up buttons shown during play. Each button shows its icon and
/// a remaining-count badge. When a power-up hits zero and [onRefill] is given,
/// the button turns into a "watch ad for +1" action (shows a ▶ badge) instead
/// of just dimming out. A game only passes the power-ups it supports.
class PowerBar extends StatelessWidget {
  const PowerBar({
    super.key,
    required this.accent,
    this.onHint,
    this.hints = 0,
    this.onJoker,
    this.jokers = 0,
    this.onFreeze,
    this.freezes = 0,
    this.frozen = false,
    this.onRefill,
  });

  final Color accent;
  final VoidCallback? onHint;
  final int hints;
  final VoidCallback? onJoker;
  final int jokers;
  final VoidCallback? onFreeze;
  final int freezes;
  final bool frozen;

  /// Called with 'hint' | 'joker' | 'freeze' when an empty power-up's
  /// watch-ad-to-refill action is tapped. Null disables refill (no ads).
  final void Function(String type)? onRefill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, 12 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          if (onHint != null)
            Expanded(
              child: _PowerButton(
                icon: Icons.lightbulb_rounded,
                label: 'İpucu',
                type: 'hint',
                count: hints,
                accent: accent,
                onTap: onHint,
                onRefill: onRefill,
              ),
            ),
          if (onHint != null && (onJoker != null || onFreeze != null))
            const SizedBox(width: 10),
          if (onJoker != null)
            Expanded(
              child: _PowerButton(
                icon: Icons.auto_fix_high_rounded,
                label: 'Joker',
                type: 'joker',
                count: jokers,
                accent: accent,
                onTap: onJoker,
                onRefill: onRefill,
              ),
            ),
          if (onJoker != null && onFreeze != null) const SizedBox(width: 10),
          if (onFreeze != null)
            Expanded(
              child: _PowerButton(
                icon: Icons.ac_unit_rounded,
                label: frozen ? 'Donduruldu' : 'Dondur',
                type: 'freeze',
                count: freezes,
                accent: frozen ? AppColors.visual : accent,
                onTap: onFreeze,
                onRefill: onRefill,
                active: frozen,
              ),
            ),
        ],
      ),
    );
  }
}

class _PowerButton extends StatelessWidget {
  const _PowerButton({
    required this.icon,
    required this.label,
    required this.type,
    required this.count,
    required this.accent,
    required this.onTap,
    this.onRefill,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final String type;
  final int count;
  final Color accent;
  final VoidCallback? onTap;
  final void Function(String type)? onRefill;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final hasUses = count > 0 && onTap != null;
    // When empty, offer a rewarded-ad refill instead of a dead button.
    final canRefill = count <= 0 && onRefill != null;
    final enabled = hasUses || canRefill;
    return Opacity(
      opacity: enabled || active ? 1 : 0.4,
      child: Material(
        color: active ? accent.withValues(alpha: 0.18) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: !enabled
              ? null
              : () {
                  Juice.tap();
                  if (hasUses) {
                    onTap!();
                  } else {
                    onRefill!(type);
                  }
                },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? accent.withValues(alpha: 0.6) : AppColors.stroke,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18,
                    color: hasUses || active ? accent : AppColors.textLow),
                const SizedBox(width: 7),
                Text(label,
                    style: AppText.body(13,
                        weight: FontWeight.w600,
                        color: enabled ? AppColors.textHi : AppColors.textLow)),
                const SizedBox(width: 6),
                canRefill && !hasUses
                    ? Icon(Icons.play_circle_fill_rounded,
                        size: 18, color: accent)
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.bgDeep.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text('$count',
                            style: AppText.label(11, color: accent)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
