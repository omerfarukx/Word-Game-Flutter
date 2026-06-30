import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/feedback/game_settings.dart';
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

  // Power-ups
  int hints = 2;
  int jokers = 1;
  int freezes = 1;
  int frozenTicks = 0;
  int? hintIndex;
  bool get isFrozen => frozenTicks > 0;

  final List<String> _recent = [];
  Timer? _timer;
  Timer? _hintTimer;
  Timer? _wrongTimer;

  int get accuracy =>
      attempts == 0 ? 0 : ((correctTaps / attempts) * 100).round();

  void start(FocusType t) {
    type = t;
    score = 0;
    combo = 0;
    maxCombo = 0;
    attempts = 0;
    correctTaps = 0;
    timeLeft = GameSettings.instance.seconds(gameSeconds);
    _recent.clear();
    hints = 2;
    jokers = 1;
    freezes = 1;
    frozenTicks = 0;
    hintIndex = null;
    phase = FocusPhase.playing;
    _nextRound();
    _hintTimer?.cancel();
    _wrongTimer?.cancel();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
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
    notifyListeners();
  }

  void freeze() {
    if (phase != FocusPhase.playing || freezes <= 0 || frozenTicks > 0) return;
    freezes--;
    frozenTicks = 5;
    notifyListeners();
  }

  void useHint() {
    if (phase != FocusPhase.playing || hints <= 0) return;
    final i = options.indexWhere((o) => o.isMatch && !o.found);
    if (i < 0) return;
    hints--;
    hintIndex = i;
    notifyListeners();
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 1500), () {
      if (hintIndex == i) hintIndex = null;
      notifyListeners();
    });
  }

  void useJoker() {
    if (phase != FocusPhase.playing || jokers <= 0) return;
    final i = options.indexWhere((o) => o.isMatch && !o.found);
    if (i < 0) return;
    jokers--;
    final opt = options[i];
    opt.found = true;
    found++;
    attempts++;
    correctTaps++;
    score += 15;
    Juice.correct();
    if (found >= correctCount) _nextRound();
    notifyListeners();
  }

  void _nextRound() {
    hintIndex = null;
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
      _wrongTimer?.cancel();
      _wrongTimer = Timer(const Duration(milliseconds: 350), () {
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
    _hintTimer?.cancel();
    _wrongTimer?.cancel();
    super.dispose();
  }
}
