import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Sfx { correct, wrong, combo, levelUp, achievement }

extension on Sfx {
  String get asset => switch (this) {
        Sfx.correct => 'sounds/correct.mp3',
        Sfx.wrong => 'sounds/wrong.mp3',
        Sfx.combo => 'sounds/combo.mp3',
        Sfx.levelUp => 'sounds/level_up.mp3',
        Sfx.achievement => 'sounds/achievement.mp3',
      };
}

/// Preloads the short sound effects and plays them with low latency. One
/// player per effect so rapid replays just restart that effect. Mute state is
/// persisted.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final Map<Sfx, AudioPlayer> _players = {};
  bool _muted = false;
  bool get muted => _muted;

  static const _prefKey = 'sfx_muted';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _muted = prefs.getBool(_prefKey) ?? false;
      for (final s in Sfx.values) {
        final p = AudioPlayer();
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setSource(AssetSource(s.asset));
        _players[s] = p;
      }
    } catch (e) {
      debugPrint('SoundService load error: $e');
    }
  }

  Future<void> setMuted(bool value) async {
    _muted = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, value);
    } catch (_) {}
  }

  void play(Sfx s) {
    if (_muted) return;
    final p = _players[s];
    if (p == null) return;
    // fire and forget
    p.seek(Duration.zero).then((_) => p.resume()).catchError((_) {});
  }
}
