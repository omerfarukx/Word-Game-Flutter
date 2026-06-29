import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';

/// Shared shell for every game screen: ink gradient, one soft accent glow,
/// and a quiet top bar (back + title + optional trailing). Games only supply
/// their accent and content, so they all feel like one app.
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
          const _InkBackground(),
          Positioned(
              top: -170,
              left: -90,
              child: _Glow(color: accent, size: 400, opacity: 0.26)),
          const Positioned(
              bottom: -210,
              right: -130,
              child: _Glow(color: AppColors.visual, size: 440, opacity: 0.10)),
          const Positioned.fill(child: _Vignette()),
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

class _InkBackground extends StatelessWidget {
  const _InkBackground();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bg, AppColors.bgDeep],
          ),
        ),
        child: SizedBox.expand(),
      );
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, this.size = 340, this.opacity = 0.22});
  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: opacity), Colors.transparent],
            ),
          ),
        ),
      );
}

/// Darkens the screen edges so content floats in the middle.
class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.1,
              colors: [Colors.transparent, AppColors.bgDeep.withValues(alpha: 0.6)],
              stops: const [0.62, 1.0],
            ),
          ),
        ),
      );
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
            child: Text(
              title,
              style: AppText.display(20),
              overflow: TextOverflow.ellipsis,
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
