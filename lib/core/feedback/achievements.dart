import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../design/app_colors.dart';
import '../design/app_typography.dart';
import '../design/decorations.dart';
import '../../features/statistics/providers/statistics_provider.dart';
import 'juice.dart';

/// A snapshot of the player's state used to test achievement conditions.
class AchProgress {
  const AchProgress({
    required this.completed,
    required this.streak,
    required this.score,
    required this.maxCombo,
    required this.isRecord,
  });

  final int completed;
  final int streak;
  final int score;
  final int maxCombo;
  final bool isRecord;
}

class Achievement {
  const Achievement(this.id, this.title, this.desc, this.icon, this.met);
  final String id;
  final String title;
  final String desc;
  final IconData icon;
  final bool Function(AchProgress p) met;
}

/// Unlockable badges that span every game. Conditions are tested at game-over
/// from shared stats (no per-game bookkeeping). Unlocks persist.
class Achievements {
  Achievements._();
  static final Achievements instance = Achievements._();

  static const List<Achievement> all = [
    Achievement('first', 'İlk Adım', 'İlk egzersizini tamamla',
        Icons.flag_rounded, _firstMet),
    Achievement('ten', 'Çalışkan', '10 egzersiz tamamla',
        Icons.fitness_center_rounded, _tenMet),
    Achievement('fifty', 'Azimli', '50 egzersiz tamamla',
        Icons.workspace_premium_rounded, _fiftyMet),
    Achievement('streak3', 'Seri Başladı', '3 gün üst üste çalış',
        Icons.local_fire_department_rounded, _streak3Met),
    Achievement('streak7', 'Haftalık Disiplin', '7 gün üst üste çalış',
        Icons.bolt_rounded, _streak7Met),
    Achievement('combo5', 'Kombocu', 'Bir oyunda x5 kombo yap',
        Icons.auto_awesome_rounded, _combo5Met),
    Achievement('combo10', 'Kombo Canavarı', 'Bir oyunda x10 kombo yap',
        Icons.whatshot_rounded, _combo10Met),
    Achievement('record', 'Rekortmen', 'İlk kişisel rekorunu kır',
        Icons.emoji_events_rounded, _recordMet),
    Achievement('score300', 'Usta', 'Tek oyunda 300 puan',
        Icons.military_tech_rounded, _score300Met),
    Achievement('score600', 'Efsane', 'Tek oyunda 600 puan',
        Icons.star_rounded, _score600Met),
  ];

  static bool _firstMet(AchProgress p) => p.completed >= 1;
  static bool _tenMet(AchProgress p) => p.completed >= 10;
  static bool _fiftyMet(AchProgress p) => p.completed >= 50;
  static bool _streak3Met(AchProgress p) => p.streak >= 3;
  static bool _streak7Met(AchProgress p) => p.streak >= 7;
  static bool _combo5Met(AchProgress p) => p.maxCombo >= 5;
  static bool _combo10Met(AchProgress p) => p.maxCombo >= 10;
  static bool _recordMet(AchProgress p) => p.isRecord;
  static bool _score300Met(AchProgress p) => p.score >= 300;
  static bool _score600Met(AchProgress p) => p.score >= 600;

  final Set<String> _unlocked = {};
  SharedPreferences? _prefs;
  static const _key = 'achievements';

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _unlocked.addAll(_prefs!.getStringList(_key) ?? const []);
    } catch (_) {}
  }

  int get unlockedCount => _unlocked.length;
  int get total => all.length;
  bool isUnlocked(String id) => _unlocked.contains(id);

  /// Unlocks any newly-earned achievements and returns them.
  List<Achievement> evaluate(AchProgress p) {
    final newly = <Achievement>[];
    for (final a in all) {
      if (!_unlocked.contains(a.id) && a.met(p)) {
        _unlocked.add(a.id);
        newly.add(a);
      }
    }
    if (newly.isNotEmpty) _prefs?.setStringList(_key, _unlocked.toList());
    return newly;
  }
}

/// Reads shared stats, unlocks achievements, and shows a toast for each new
/// one. Call from a game's game-over handler (after recording completion).
void reportAchievements(
  BuildContext context, {
  int score = 0,
  int maxCombo = 0,
  bool isRecord = false,
}) {
  final stats = context.read<StatisticsProvider>();
  final newly = Achievements.instance.evaluate(AchProgress(
    completed: stats.completedExercises,
    streak: stats.streakDays,
    score: score,
    maxCombo: maxCombo,
    isRecord: isRecord,
  ));
  if (newly.isEmpty) return;
  Juice.achievement();
  for (var i = 0; i < newly.length; i++) {
    Future.delayed(Duration(milliseconds: i * 400), () {
      if (context.mounted) _showToast(context, newly[i]);
    });
  }
}

void _showToast(BuildContext context, Achievement a) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.all(14),
        decoration: Surfaces.tile(radius: 16, border: AppColors.reading),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppGradients.reading,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(a.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🏅 Başarım: ${a.title}',
                      style: AppText.body(14,
                          weight: FontWeight.w700, color: AppColors.textHi)),
                  Text(a.desc,
                      style: AppText.body(12, color: AppColors.textLow)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
