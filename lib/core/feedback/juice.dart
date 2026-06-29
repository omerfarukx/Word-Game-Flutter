import 'package:flutter/services.dart';

import 'sound_service.dart';

/// One-call game feel: sound + matching haptic for each game event. Controllers
/// call these at the moment an event happens, so every game feels alive.
class Juice {
  const Juice._();

  static void correct() {
    SoundService.instance.play(Sfx.correct);
    HapticFeedback.lightImpact();
  }

  static void combo() {
    SoundService.instance.play(Sfx.combo);
    HapticFeedback.mediumImpact();
  }

  static void wrong() {
    SoundService.instance.play(Sfx.wrong);
    HapticFeedback.mediumImpact();
  }

  static void levelUp() {
    SoundService.instance.play(Sfx.levelUp);
    HapticFeedback.heavyImpact();
  }

  static void achievement() {
    SoundService.instance.play(Sfx.achievement);
    HapticFeedback.heavyImpact();
  }

  /// Neutral tap (selection) — for light interactions.
  static void tap() => HapticFeedback.selectionClick();
}
