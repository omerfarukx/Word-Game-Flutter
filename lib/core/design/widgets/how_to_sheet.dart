import 'package:flutter/material.dart';

import '../../onboarding/guides.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../decorations.dart';

/// Shows a game's "how to play" as a modal bottom sheet. [primaryLabel] is the
/// action button; [onPrimary] runs after the sheet closes (e.g. start playing).
Future<void> showHowTo(
  BuildContext context, {
  required GameGuide guide,
  String primaryLabel = 'Anladım',
  VoidCallback? onPrimary,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _HowToSheet(
      guide: guide,
      primaryLabel: primaryLabel,
      onPrimary: onPrimary,
    ),
  );
}

class _HowToSheet extends StatelessWidget {
  const _HowToSheet({
    required this.guide,
    required this.primaryLabel,
    this.onPrimary,
  });

  final GameGuide guide;
  final String primaryLabel;
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    final accent = guide.accent;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.stroke),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 14, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppGradients.forAccent(accent),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: Icon(guide.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NASIL OYNANIR', style: AppText.label(10)),
                    const SizedBox(height: 2),
                    Text(guide.title, style: AppText.display(22)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          for (var i = 0; i < guide.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(9),
                      border:
                          Border.all(color: accent.withValues(alpha: 0.4)),
                    ),
                    child: Text('${i + 1}',
                        style: AppText.display(13, color: accent)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(guide.steps[i],
                          style: AppText.body(14, color: AppColors.textMid)),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.forAccent(accent),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).pop();
                    onPrimary?.call();
                  },
                  child: SizedBox(
                    height: 52,
                    child: Center(
                      child: Text(primaryLabel,
                          style: AppText.body(16,
                              weight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
