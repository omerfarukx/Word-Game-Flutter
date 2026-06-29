import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../core/feedback/juice.dart';

/// What the round is doing right now.
enum PeriPhase { showing, respond, feedback, over }

/// Çevresel Görüş: keep your eyes on the centre while one dot in the
/// surrounding ring flashes briefly; then tap which one lit up. Trains
/// peripheral attention. Rebuilt with real scoring + accuracy (the old screen
/// had none) and a responsive ring laid out by the screen.
class PeripheralController extends ChangeNotifier {
  PeripheralController();

  static const int dots = 8;
  static const int gameSeconds = 60;

  final Random _rand = Random();

  PeriPhase phase = PeriPhase.showing;
  int litIndex = 0;
  int tappedIndex = -1;
  bool lastCorrect = false;

  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  int attempts = 0;
  int correctTaps = 0;
  int timeLeft = gameSeconds;
  int level = 1;
  bool isActive = false;
  bool isOver = false;

  // Power-ups (no hint — it's a reaction game)
  int jokers = 2;
  int freezes = 1;
  int frozenTicks = 0;
  bool get isFrozen => frozenTicks > 0;

  Timer? _gameTimer;
  Timer? _phaseTimer;

  /// Flash window shrinks as you level up.
  int get flashMs => (760 - level * 40).clamp(280, 760);
  int get accuracy =>
      attempts == 0 ? 0 : ((correctTaps / attempts) * 100).round();

  void start() {
    score = 0;
    combo = 0;
    maxCombo = 0;
    attempts = 0;
    correctTaps = 0;
    level = 1;
    timeLeft = gameSeconds;
    isActive = true;
    isOver = false;
    jokers = 2;
    freezes = 1;
    frozenTicks = 0;
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (frozenTicks > 0) {
        frozenTicks--;
        notifyListeners();
        return;
      }
      timeLeft--;
      if (timeLeft <= 0) {
        timeLeft = 0;
        _end();
      }
      notifyListeners();
    });
    _nextRound();
  }

  void freeze() {
    if (!isActive || freezes <= 0 || frozenTicks > 0) return;
    freezes--;
    frozenTicks = 5;
    notifyListeners();
  }

  void useJoker() {
    if (jokers <= 0 || phase != PeriPhase.respond) return;
    jokers--;
    tap(litIndex); // auto-answer this round correctly
  }

  void _nextRound() {
    litIndex = _rand.nextInt(dots);
    tappedIndex = -1;
    phase = PeriPhase.showing;
    notifyListeners();
    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(milliseconds: flashMs), () {
      if (phase != PeriPhase.showing) return;
      phase = PeriPhase.respond;
      notifyListeners();
    });
  }

  void tap(int index) {
    if (phase != PeriPhase.respond) return;
    attempts++;
    tappedIndex = index;
    lastCorrect = index == litIndex;
    if (lastCorrect) {
      correctTaps++;
      combo++;
      if (combo > maxCombo) maxCombo = combo;
      score += 15 + (combo >= 3 ? 8 : 0);
      timeLeft += 1;
      if (correctTaps % 5 == 0) {
        level++;
        Juice.levelUp();
      } else {
        combo >= 3 ? Juice.combo() : Juice.correct();
      }
    } else {
      combo = 0;
      score = max(0, score - 5);
      timeLeft = max(1, timeLeft - 2);
      Juice.wrong();
    }
    phase = PeriPhase.feedback;
    notifyListeners();
    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(milliseconds: 700), () {
      if (phase == PeriPhase.over) return;
      _nextRound();
    });
  }

  void _end() {
    _gameTimer?.cancel();
    _phaseTimer?.cancel();
    phase = PeriPhase.over;
    isActive = false;
    isOver = true;
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }
}
