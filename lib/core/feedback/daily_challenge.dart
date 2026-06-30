import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/route_constants.dart';
import '../design/app_colors.dart';

/// One day's featured game and the score to beat for it.
class DailyTask {
  const DailyTask(
      this.gameId, this.route, this.title, this.icon, this.accent, this.target);
  final String gameId;
  final String route;
  final String title;
  final IconData icon;
  final Color accent;
  final int target;
}

/// Günlük Meydan Okuma: each calendar day deterministically features one game
/// with a score target. Reaching that score in that game (however you got
/// there) completes the day and extends a daily streak. Detection is a single
/// hook in [Records.submit] — no per-game wiring.
class DailyChallenge {
  DailyChallenge._();
  static final DailyChallenge instance = DailyChallenge._();

  // Only "higher score is better" games (no time-based Schultz, no Speed
  // Reading which has no score).
  static const List<DailyTask> _rotation = [
    DailyTask('word_chain', RouteConstants.wordChain, 'Kelime Zinciri',
        Icons.link_rounded, AppColors.word, 80),
    DailyTask('anagram', RouteConstants.anagram, 'Karışık Harfler',
        Icons.shuffle_rounded, AppColors.word, 80),
    DailyTask('word_pairs', RouteConstants.wordPairs, 'Kelime Çiftleri',
        Icons.compare_arrows_rounded, AppColors.word, 80),
    DailyTask('word_search', RouteConstants.wordSearch, 'Kelime Bulma',
        Icons.grid_on_rounded, AppColors.word, 120),
    DailyTask('word_focus', RouteConstants.wordFocus, 'Kelime Odağı',
        Icons.hub_rounded, AppColors.word, 80),
    DailyTask('letter_search', RouteConstants.letterSearch, 'Harf Arama',
        Icons.search_rounded, AppColors.visual, 100),
    DailyTask('peripheral', RouteConstants.peripheralVision, 'Çevresel Görüş',
        Icons.blur_circular_rounded, AppColors.visual, 60),
    DailyTask('word_recognition', RouteConstants.wordRecognition,
        'Kelime Tanıma', Icons.flash_on_rounded, AppColors.word, 8),
  ];

  SharedPreferences? _prefs;
  int _lastDoneDay = -1; // day number of the last completed challenge
  int _streak = 0;

  /// Bumps when today's challenge is completed, so the UI can celebrate.
  int justCompletedTick = 0;

  static const _lastKey = 'daily_last_day';
  static const _streakKey = 'daily_streak';

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _lastDoneDay = _prefs!.getInt(_lastKey) ?? -1;
      _streak = _prefs!.getInt(_streakKey) ?? 0;
    } catch (_) {}
  }

  int get _dayNumber {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .difference(DateTime(2020, 1, 1))
        .inDays;
  }

  DailyTask get today => _rotation[_dayNumber % _rotation.length];

  bool get doneToday => _lastDoneDay == _dayNumber;

  /// Current streak, only counted as live if the last completion was today or
  /// yesterday (otherwise it has lapsed).
  int get streak =>
      (_lastDoneDay == _dayNumber || _lastDoneDay == _dayNumber - 1)
          ? _streak
          : 0;

  /// Called from Records.submit on every score game-over. Marks today's
  /// challenge done when the right game beats the target.
  void onScore(String gameId, int score) {
    if (doneToday) return;
    final t = today;
    if (gameId != t.gameId || score < t.target) return;
    _streak = (_lastDoneDay == _dayNumber - 1) ? _streak + 1 : 1;
    _lastDoneDay = _dayNumber;
    justCompletedTick++;
    _prefs?.setInt(_lastKey, _lastDoneDay);
    _prefs?.setInt(_streakKey, _streak);
  }
}
