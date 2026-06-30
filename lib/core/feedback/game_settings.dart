import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameDifficulty { easy, normal, hard }

enum GameMode { normal, survival }

extension GameModeX on GameMode {
  String get label => switch (this) {
        GameMode.normal => 'Normal',
        GameMode.survival => 'Hayatta Kalma',
      };
}

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
  GameMode mode = GameMode.normal;
  static const _key = 'difficulty';
  static const _modeKey = 'game_mode';

  /// Lives the player starts with in Survival mode.
  static const int survivalLives = 3;

  bool get survival => mode == GameMode.survival;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final i = prefs.getInt(_key);
      if (i != null && i >= 0 && i < GameDifficulty.values.length) {
        difficulty = GameDifficulty.values[i];
      }
      final m = prefs.getInt(_modeKey);
      if (m != null && m >= 0 && m < GameMode.values.length) {
        mode = GameMode.values[m];
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

  Future<void> setMode(GameMode m) async {
    mode = m;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_modeKey, m.index);
    } catch (_) {}
  }

  /// Base seconds adjusted for the current difficulty.
  int seconds(int base) => (base * difficulty.timeFactor).round();
}
