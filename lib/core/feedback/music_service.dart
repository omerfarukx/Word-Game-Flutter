import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../design/app_colors.dart';

enum MusicTrack { word, visual, reading }

extension on MusicTrack {
  String get asset => switch (this) {
        MusicTrack.word => 'music/word.mp3',
        MusicTrack.visual => 'music/visual.mp3',
        MusicTrack.reading => 'music/reading.mp3',
      };
}

/// Looping background music. One track plays at a time; screens request the
/// track that matches their category and the service crossfades by simply
/// switching. Volume sits low so it never fights the reading exercises.
class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  final AudioPlayer _player = AudioPlayer();
  MusicTrack? _current;
  bool _muted = false;
  bool get muted => _muted;

  static const _prefKey = 'music_muted';
  static const double _volume = 0.32;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _muted = prefs.getBool(_prefKey) ?? false;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_volume);
    } catch (e) {
      debugPrint('MusicService init error: $e');
    }
  }

  /// Pick the track for a game's accent colour.
  static MusicTrack trackForAccent(Color accent) {
    if (accent == AppColors.visual) return MusicTrack.visual;
    if (accent == AppColors.reading) return MusicTrack.reading;
    return MusicTrack.word;
  }

  Future<void> play(MusicTrack track) async {
    _current = track;
    if (_muted) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(track.asset), volume: _volume);
    } catch (e) {
      debugPrint('MusicService play error: $e');
    }
  }

  Future<void> setMuted(bool value) async {
    _muted = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, value);
      if (value) {
        await _player.pause();
      } else if (_current != null) {
        await play(_current!);
      }
    } catch (_) {}
  }
}
