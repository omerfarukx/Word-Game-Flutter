import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../core/feedback/game_settings.dart';
import '../../../../core/feedback/juice.dart';
import '../../../../core/words/word_service.dart';

/// Kelime Karıştırma (anagram) game logic. A target word's letters are
/// scrambled into a tray of tiles; the player taps tiles to rebuild a real
/// word. Any valid dictionary permutation of the letters counts — not only the
/// original word — so the puzzle is fair when several anagrams exist.
///
/// Pure state + rules; the screen renders [letters]/[placement] and forwards
/// taps. Each tile is referenced by its index into [letters], so duplicate
/// letters stay unambiguous.
class AnagramController extends ChangeNotifier {
  AnagramController(this._dict, {Random? random})
      : _rng = random ?? Random();

  final WordService _dict;
  final Random _rng;

  static const int gameSeconds = 75;
  static const int minLen = 3;
  static const int maxLen = 7;

  /// Scrambled letters of the current target, fixed order (the tray).
  final List<String> letters = [];

  /// Tile indices (into [letters]) placed into the answer row, in order.
  final List<int> placement = [];

  /// One full valid assignment of tiles → target positions, used by hint/joker.
  final List<int> _solution = [];

  String _target = '';

  /// Number of leading answer slots locked by hints (immovable).
  int locked = 0;

  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  int solved = 0;
  int timeLeft = gameSeconds;
  int lives = 0; // survival mode only
  bool isActive = false;
  bool isOver = false;

  /// Brief window after a correct answer: the solved word flashes green before
  /// the next word slides in. Input is ignored while it lasts.
  bool celebrating = false;

  /// Increments only when a fresh word loads, so the screen's AnimatedSwitcher
  /// holds the solved word still during the celebration flash.
  int roundId = 0;
  Timer? _celebrateTimer;

  /// Bumps on a wrong full answer so the screen can shake.
  int rejectTick = 0;

  // Power-ups
  int hints = 2;
  int jokers = 1;
  int freezes = 1;
  int frozenTicks = 0;
  bool get isFrozen => frozenTicks > 0;

  Timer? _timer;

  String get target => _target;

  /// The word built so far from the placed tiles.
  String get answer => placement.map((i) => letters[i]).join();

  bool get isFull => placement.length == _target.length;

  /// True for tile [i] when it's currently sitting in the answer row.
  bool isPlaced(int i) => placement.contains(i);

  void start() {
    score = 0;
    combo = 0;
    maxCombo = 0;
    solved = 0;
    timeLeft = GameSettings.instance.seconds(gameSeconds);
    lives = GameSettings.survivalLives;
    isActive = true;
    isOver = false;
    rejectTick = 0;
    celebrating = false;
    _celebrateTimer?.cancel();
    hints = 2;
    jokers = 1;
    freezes = 1;
    frozenTicks = 0;
    _loadWord();
    _timer?.cancel();
    // Survival mode swaps the clock for lives — no countdown.
    if (!GameSettings.instance.survival) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (frozenTicks > 0) {
          frozenTicks--;
          notifyListeners();
          return;
        }
        timeLeft--;
        if (timeLeft <= 0) {
          timeLeft = 0;
          _finish();
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  /// Word length grows as the player solves more, capped at [maxLen].
  int get _lenForSolved => (minLen + solved ~/ 3).clamp(minLen, maxLen);

  void _loadWord() {
    final len = _lenForSolved;
    // Find a word whose letters have a scramble that differs from the original.
    String? word;
    List<String>? scrambled;
    for (var attempt = 0; attempt < 30; attempt++) {
      final candidate = _dict.randomWord(minLen: len, maxLen: len, random: _rng);
      if (candidate == null) break;
      final chars = candidate.split('');
      final shuffled = _scramble(chars);
      if (shuffled.join() != candidate) {
        word = candidate;
        scrambled = shuffled;
        break;
      }
    }
    // Fallback: any word in range, scramble best-effort.
    if (word == null) {
      word = _dict.randomWord(minLen: minLen, maxLen: maxLen, random: _rng) ??
          'kelime';
      scrambled = _scramble(word.split(''));
    }

    _target = word;
    letters
      ..clear()
      ..addAll(scrambled!);
    placement.clear();
    locked = 0;
    roundId++;
    _buildSolution();
  }

  List<String> _scramble(List<String> chars) {
    final copy = List<String>.from(chars);
    for (var i = copy.length - 1; i > 0; i--) {
      final j = _rng.nextInt(i + 1);
      final tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy;
  }

  /// Greedily map each target position to an available tile of the same letter.
  void _buildSolution() {
    _solution.clear();
    final used = <int>{};
    for (final ch in _target.split('')) {
      for (var i = 0; i < letters.length; i++) {
        if (!used.contains(i) && letters[i] == ch) {
          used.add(i);
          _solution.add(i);
          break;
        }
      }
    }
  }

  /// Tap a tray tile: append it to the answer row.
  void place(int tileIndex) {
    if (!isActive || celebrating || isFull || placement.contains(tileIndex)) {
      return;
    }
    placement.add(tileIndex);
    Juice.tap();
    if (isFull) {
      _evaluate();
    } else {
      notifyListeners();
    }
  }

  /// Tap a placed tile to pull it (and nothing else) back to the tray. Locked
  /// hint letters can't be removed.
  void unplace(int tileIndex) {
    if (!isActive) return;
    final pos = placement.indexOf(tileIndex);
    if (pos < 0 || pos < locked) return;
    placement.removeAt(pos);
    Juice.tap();
    notifyListeners();
  }

  void clearAnswer() {
    if (!isActive) return;
    placement.removeRange(locked, placement.length);
    notifyListeners();
  }

  void _evaluate() {
    final word = answer;
    if (_dict.contains(word)) {
      solved++;
      combo++;
      if (combo > maxCombo) maxCombo = combo;
      final base = word.length * 12;
      final bonus = combo >= 3 ? (base * 0.5).round() : 0;
      score += base + bonus;
      combo >= 3 ? Juice.combo() : Juice.correct();
      // Flash the solved word green, then bring in the next one.
      celebrating = true;
      notifyListeners();
      _celebrateTimer?.cancel();
      _celebrateTimer = Timer(const Duration(milliseconds: 440), () {
        celebrating = false;
        if (isActive) _loadWord();
        notifyListeners();
      });
    } else {
      combo = 0;
      rejectTick++;
      Juice.wrong();
      // Return the player's tiles (keep any locked prefix) after the shake.
      placement.removeRange(locked, placement.length);
      if (GameSettings.instance.survival) {
        lives--;
        if (lives <= 0) {
          lives = 0;
          _finish();
        }
      }
      notifyListeners();
    }
  }

  /// Lock the next correct letter into the answer row.
  void useHint() {
    if (!isActive || celebrating || hints <= 0 || locked >= _target.length) {
      return;
    }
    hints--;
    locked++;
    placement
      ..clear()
      ..addAll(_solution.sublist(0, locked));
    notifyListeners();
  }

  /// Auto-solve the current word (no combo bonus); advances to the next.
  void useJoker() {
    if (!isActive || celebrating || jokers <= 0) return;
    jokers--;
    placement
      ..clear()
      ..addAll(_solution);
    solved++;
    combo = 0;
    score += _target.length * 12;
    Juice.levelUp();
    _loadWord();
    notifyListeners();
  }

  void freeze() {
    if (GameSettings.instance.survival) return; // no clock to freeze
    if (!isActive || celebrating || freezes <= 0 || frozenTicks > 0) return;
    freezes--;
    frozenTicks = 5;
    notifyListeners();
  }

  void giveUp() {
    _finish();
    notifyListeners();
  }

  /// Reward: add one of the named power-up.
  void grant(String type) {
    switch (type) {
      case 'hint':
        hints++;
      case 'joker':
        jokers++;
      case 'freeze':
        freezes++;
    }
    notifyListeners();
  }

  /// Reward: continue after game over — more time (or refilled lives in
  /// survival) and resume play, keeping the score.
  void revive() {
    if (!isOver) return;
    isOver = false;
    isActive = true;
    celebrating = false;
    if (GameSettings.instance.survival) {
      lives = GameSettings.survivalLives;
    } else {
      timeLeft += 25;
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
          _finish();
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void _finish() {
    _timer?.cancel();
    isActive = false;
    isOver = true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _celebrateTimer?.cancel();
    super.dispose();
  }
}
