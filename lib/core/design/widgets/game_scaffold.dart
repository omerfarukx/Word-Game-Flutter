import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../decorations.dart';
import 'aurora_background.dart';

/// Shared shell for every game screen: a living aurora backdrop and a quiet top
/// bar (back + gradient title + optional trailing). Games supply their accent
/// and content, so they all feel like one app.
class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.title,
    required this.accent,
    required this.child,
    this.trailing,
    this.onBack,
  });

  final String title;
  final Color accent;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: AuroraBackground(accent: accent)),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  title: title,
                  accent: accent,
                  trailing: trailing,
                  onBack: onBack,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.accent,
    this.trailing,
    this.onBack,
  });

  final String title;
  final Color accent;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          _IconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ShaderMask(
              shaderCallback: (r) =>
                  AppGradients.forAccent(accent).createShader(r),
              child: Text(
                title,
                style: AppText.display(22, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.stroke),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.textHi, size: 22),
        ),
      ),
    );
  }
}
