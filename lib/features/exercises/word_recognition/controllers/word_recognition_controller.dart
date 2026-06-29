import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/text/turkish.dart';
import '../../../../core/words/word_service.dart';

enum RecogDifficulty { easy, medium, hard }

extension RecogDifficultyX on RecogDifficulty {
  String get label => switch (this) {
        RecogDifficulty.easy => 'Kolay',
        RecogDifficulty.medium => 'Orta',
        RecogDifficulty.hard => 'Zor',
      };

  String get blurb => switch (this) {
        RecogDifficulty.easy => '3–5 harf · kelime daha uzun görünür',
        RecogDifficulty.medium => '6–8 harf · daha kısa süre',
        RecogDifficulty.hard => '9+ harf · göz açıp kapayana kadar',
      };

  int get minLen => switch (this) {
        RecogDifficulty.easy => 3,
        RecogDifficulty.medium => 6,
        RecogDifficulty.hard => 9,
      };

  int get maxLen => switch (this) {
        RecogDifficulty.easy => 5,
        RecogDifficulty.medium => 8,
        RecogDifficulty.hard => 40,
      };

  int get baseFlashMs => switch (this) {
        RecogDifficulty.easy => 1200,
        RecogDifficulty.medium => 900,
        RecogDifficulty.hard => 700,
      };
}

/// What the player is doing right now.
enum RecogPhase { idle, showing, input, feedback, over }

/// Kelime Tanıma: a word flashes for a shrinking moment, then the player types
/// what they saw. Single word per round (the old multi-word path was broken);
/// difficulty sets word length + flash speed, and speed ramps with the score.
class WordRecognitionController extends ChangeNotifier {
  WordRecognitionController(this._dict);

  final WordService _dict;

  static const int gameSeconds = 60;

  RecogDifficulty difficulty = RecogDifficulty.easy;
  RecogPhase phase = RecogPhase.idle;

  String current = ''; // word to recognize (lowercased)
  bool lastCorrect = false;
  int score = 0;
  int attempts = 0;
  int timeLeft = gameSeconds;

  final Set<String> _used = {};
  Timer? _gameTimer;
  Timer? _phaseTimer;

  /// Flash window shrinks 60ms every 3 correct, down to 300ms.
  int get flashMs {
    final reduced = difficulty.baseFlashMs - (score ~/ 3) * 60;
    return reduced.clamp(300, difficulty.baseFlashMs);
  }

  int get accuracy => attempts == 0 ? 0 : ((score / attempts) * 100).round();

  void start(RecogDifficulty d) {
    difficulty = d;
    score = 0;
    attempts = 0;
    timeLeft = gameSeconds;
    _used.clear();
    _gameTimer?.cancel();
    _phaseTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      timeLeft--;
      if (timeLeft <= 0) {
        timeLeft = 0;
        _end();
      }
      notifyListeners();
    });
    _nextRound();
  }

  void _nextRound() {
    var word = _dict.randomWord(
      minLen: difficulty.minLen,
      maxLen: difficulty.maxLen,
      exclude: _used,
    );
    if (word == null) {
      _used.clear();
      word = _dict.randomWord(
            minLen: difficulty.minLen,
            maxLen: difficulty.maxLen,
          ) ??
          'kelime';
    }
    current = word;
    _used.add(current);
    phase = RecogPhase.showing;
    notifyListeners();

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(milliseconds: flashMs), () {
      if (phase != RecogPhase.showing) return;
      phase = RecogPhase.input;
      notifyListeners();
    });
  }

  void submit(String answer) {
    if (phase != RecogPhase.input) return;
    attempts++;
    lastCorrect = Tr.lower(answer.trim()) == current;
    if (lastCorrect) score++;
    phase = RecogPhase.feedback;
    notifyListeners();

    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(milliseconds: 850), () {
      if (phase == RecogPhase.over) return;
      _nextRound();
    });
  }

  void backToMenu() {
    _gameTimer?.cancel();
    _phaseTimer?.cancel();
    phase = RecogPhase.idle;
    notifyListeners();
  }

  void _end() {
    _gameTimer?.cancel();
    _phaseTimer?.cancel();
    phase = RecogPhase.over;
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }
}
