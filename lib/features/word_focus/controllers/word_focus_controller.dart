import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/feedback/juice.dart';
import '../../../core/words/word_service.dart';
import '../data/word_focus_data.dart';

class FocusOption {
  FocusOption(this.word, this.isMatch);
  final String word;
  final bool isMatch;
  bool found = false;
  bool wrong = false;
}

enum FocusPhase { idle, playing, over }

/// Kelime Odağı: a centre word with related words and distractors around it;
/// tap the related ones. Rebuilt to fix the old single-round flow, the
/// %1000 accuracy bug (now correct-taps / total-taps), wrong-tap feedback and
/// a responsive ring (the screen lays the ring out from real size).
class WordFocusController extends ChangeNotifier {
  WordFocusController(this._dict);

  final WordService _dict;

  static const int gameSeconds = 60;
  static const int ringSize = 6;
  static const int maxMatches = 4;

  final Random _rand = Random();

  FocusType type = FocusType.synonym;
  FocusPhase phase = FocusPhase.idle;

  String center = '';
  List<FocusOption> options = [];
  int correctCount = 0;
  int found = 0;

  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  int attempts = 0;
  int correctTaps = 0;
  int timeLeft = gameSeconds;
  int wrongTick = 0;

  final List<String> _recent = [];
  Timer? _timer;

  int get accuracy =>
      attempts == 0 ? 0 : ((correctTaps / attempts) * 100).round();

  void start(FocusType t) {
    type = t;
    score = 0;
    combo = 0;
    maxCombo = 0;
    attempts = 0;
    correctTaps = 0;
    timeLeft = gameSeconds;
    _recent.clear();
    phase = FocusPhase.playing;
    _nextRound();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      timeLeft--;
      if (timeLeft <= 0) {
        timeLeft = 0;
        _end();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void _nextRound() {
    final pool = WordFocusData.entries[type]!;
    var entry = pool[_rand.nextInt(pool.length)];
    var guard = 0;
    while (_recent.contains(entry.center) && guard++ < 8) {
      entry = pool[_rand.nextInt(pool.length)];
    }
    _recent.add(entry.center);
    if (_recent.length > 4) _recent.removeAt(0);

    center = entry.center;
    final matches = entry.matches.take(maxMatches).toList();
    correctCount = matches.length;
    found = 0;

    final exclude = <String>{center, ...matches};
    final opts = matches.map((w) => FocusOption(w, true)).toList();
    while (opts.length < ringSize) {
      final d = _dict.randomWord(minLen: 3, maxLen: 8, exclude: exclude);
      if (d == null) break;
      exclude.add(d);
      opts.add(FocusOption(d, false));
    }
    opts.shuffle(_rand);
    options = opts;
  }

  void tap(int index) {
    if (phase != FocusPhase.playing) return;
    final opt = options[index];
    if (opt.found) return;
    attempts++;

    if (opt.isMatch) {
      opt.found = true;
      found++;
      correctTaps++;
      combo++;
      if (combo > maxCombo) maxCombo = combo;
      score += 15 + (combo >= 3 ? 8 : 0);
      timeLeft += 2;
      combo >= 3 ? Juice.combo() : Juice.correct();
      if (found >= correctCount) {
        _nextRound();
      }
    } else {
      opt.wrong = true;
      wrongTick++;
      combo = 0;
      Juice.wrong();
      score = max(0, score - 8);
      timeLeft = max(1, timeLeft - 3);
      Timer(const Duration(milliseconds: 350), () {
        opt.wrong = false;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void _end() {
    _timer?.cancel();
    phase = FocusPhase.over;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
