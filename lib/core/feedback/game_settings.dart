import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameDifficulty { easy, normal, hard }

extension GameDifficultyX on GameDifficulty {
  String get label => switch (this) {
        GameDifficulty.easy => 'Kolay',
        GameDifficulty.normal => 'Orta',
        GameDifficulty.hard => 'Zor',
      };

  /// Multiplies each game's base duration — more time when easier.
  double get timeFactor => switch (this) {
        GameDifficulty.easy => 1.35,
        GameDifficulty.normal => 1.0,
        GameDifficulty.hard => 0.7,
      };
}

/// One global difficulty applied to every timed game (scales the clock).
/// Persisted; read by controllers via [seconds].
class GameSettings extends ChangeNotifier {
  GameSettings._();
  static final GameSettings instance = GameSettings._();

  GameDifficulty difficulty = GameDifficulty.normal;
  static const _key = 'difficulty';

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final i = prefs.getInt(_key);
      if (i != null && i >= 0 && i < GameDifficulty.values.length) {
        difficulty = GameDifficulty.values[i];
      }
    } catch (_) {}
  }

  Future<void> set(GameDifficulty d) async {
    difficulty = d;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, d.index);
    } catch (_) {}
  }

  /// Base seconds adjusted for the current difficulty.
  int seconds(int base) => (base * difficulty.timeFactor).round();
}
