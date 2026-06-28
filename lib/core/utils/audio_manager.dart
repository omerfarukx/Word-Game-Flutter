import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playSound(String soundName) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$soundName.mp3'));
    } catch (e) {
      debugPrint('Ses çalma hatası: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
