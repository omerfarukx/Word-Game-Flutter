import 'package:flutter/material.dart';

import '../../feedback/juice.dart';
import '../app_colors.dart';
import '../app_typography.dart';

/// A row of power-up buttons shown during play. Each button shows its icon and
/// a remaining-count badge, dims to disabled at zero, and fires a tap haptic.
/// A game only passes the power-ups it supports.
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
  });

  final Color accent;
  final VoidCallback? onHint;
  final int hints;
  final VoidCallback? onJoker;
  final int jokers;
  final VoidCallback? onFreeze;
  final int freezes;
  final bool frozen;

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
                count: hints,
                accent: accent,
                onTap: onHint,
              ),
            ),
          if (onHint != null && (onJoker != null || onFreeze != null))
            const SizedBox(width: 10),
          if (onJoker != null)
            Expanded(
              child: _PowerButton(
                icon: Icons.auto_fix_high_rounded,
                label: 'Joker',
                count: jokers,
                accent: accent,
                onTap: onJoker,
              ),
            ),
          if (onJoker != null && onFreeze != null) const SizedBox(width: 10),
          if (onFreeze != null)
            Expanded(
              child: _PowerButton(
                icon: Icons.ac_unit_rounded,
                label: frozen ? 'Donduruldu' : 'Dondur',
                count: freezes,
                accent: frozen ? AppColors.visual : accent,
                onTap: onFreeze,
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
    required this.count,
    required this.accent,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color accent;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final enabled = count > 0 && onTap != null;
    return Opacity(
      opacity: enabled || active ? 1 : 0.4,
      child: Material(
        color: active
            ? accent.withValues(alpha: 0.18)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled
              ? () {
                  Juice.tap();
                  onTap!();
                }
              : null,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? accent.withValues(alpha: 0.6)
                    : AppColors.stroke,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: enabled ? accent : AppColors.textLow),
                const SizedBox(width: 7),
                Text(label,
                    style: AppText.body(13,
                        weight: FontWeight.w600,
                        color: enabled ? AppColors.textHi : AppColors.textLow)),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.bgDeep.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text('$count', style: AppText.label(11, color: accent)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
