import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../core/feedback/game_settings.dart';
import '../../../../core/feedback/juice.dart';
import '../../../../core/words/word_service.dart';

/// One grid card showing two stacked words. On a "different" card the two words
/// differ by a single letter; the player's job is to spot those.
class PairCard {
  PairCard({required this.top, required this.bottom, required this.isDifferent});

  final String top;
  final String bottom;
  final bool isDifferent;

  bool found = false;
  bool wrong = false;
}

/// Kelime Çiftleri: spot the cards whose two words don't match. Cards are
/// generated from the dictionary so every level has exactly N targets — the
/// old hand-authored data could produce unsolvable rounds that locked the game.
class WordPairsController extends ChangeNotifier {
  WordPairsController(this._dict);

  final WordService _dict;

  static const int gameSeconds = 50;
  static const int columns = 3;
  static const int rows = 4;
  static const int _cardCount = columns * rows;

  static const String _alphabet = 'abcçdefgğhıijklmnoöprsştuüvyz';

  final Random _rand = Random();

  List<PairCard> cards = [];
  int level = 1;
  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  int found = 0;
  int targets = 0;
  int timeLeft = gameSeconds;
  int lives = 0; // survival mode only
  bool isActive = false;
  bool isOver = false;

  /// Bumps on a wrong tap so the screen can flash/shake.
  int wrongTick = 0;

  // Power-ups (per game)
  int hints = 2;
  int jokers = 1;
  int freezes = 1;
  int frozenTicks = 0;
  int? hintIndex;
  bool get isFrozen => frozenTicks > 0;

  Timer? _timer;
  Timer? _hintTimer;
  Timer? _wrongTimer;

  void start() {
    score = 0;
    combo = 0;
    maxCombo = 0;
    level = 1;
    timeLeft = GameSettings.instance.seconds(gameSeconds);
    lives = GameSettings.survivalLives;
    isActive = true;
    isOver = false;
    hints = 2;
    jokers = 1;
    freezes = 1;
    frozenTicks = 0;
    hintIndex = null;
    _buildLevel();
    _hintTimer?.cancel();
    _wrongTimer?.cancel();
    _timer?.cancel();
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
          _end();
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void freeze() {
    if (GameSettings.instance.survival) return; // no clock to freeze
    if (!isActive || freezes <= 0 || frozenTicks > 0) return;
    freezes--;
    frozenTicks = 5;
    notifyListeners();
  }

  void useHint() {
    if (!isActive || hints <= 0) return;
    final i = cards.indexWhere((c) => c.isDifferent && !c.found);
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
    if (!isActive || jokers <= 0) return;
    final i = cards.indexWhere((c) => c.isDifferent && !c.found);
    if (i < 0) return;
    jokers--;
    final card = cards[i];
    card.found = true;
    found++;
    score += 20;
    if (found >= targets) {
      level++;
      Juice.levelUp();
      _buildLevel();
    } else {
      Juice.correct();
    }
    notifyListeners();
  }

  void _buildLevel() {
    found = 0;
    hintIndex = null;
    targets = (2 + (level + 1) ~/ 2).clamp(2, _cardCount - 2);
    final minLen = (4 + (level - 1) ~/ 2).clamp(4, 7);
    final maxLen = minLen + 1;

    // Distinct words for each card.
    final used = <String>{};
    final words = <String>[];
    while (words.length < _cardCount) {
      final w = _dict.randomWord(minLen: minLen, maxLen: maxLen, exclude: used);
      if (w == null) break;
      used.add(w);
      words.add(w);
    }
    while (words.length < _cardCount) {
      words.add('kelime');
    }

    final targetIndexes = <int>{};
    while (targetIndexes.length < targets) {
      targetIndexes.add(_rand.nextInt(_cardCount));
    }

    cards = [
      for (var i = 0; i < _cardCount; i++)
        targetIndexes.contains(i)
            ? PairCard(top: words[i], bottom: _variant(words[i]), isDifferent: true)
            : PairCard(top: words[i], bottom: words[i], isDifferent: false),
    ];
  }

  /// A copy of [word] with one letter swapped for a different one.
  String _variant(String word) {
    final chars = word.split('');
    final idx = _rand.nextInt(chars.length);
    String repl;
    do {
      repl = _alphabet[_rand.nextInt(_alphabet.length)];
    } while (repl == chars[idx]);
    chars[idx] = repl;
    return chars.join();
  }

  void tapCard(int index) {
    if (!isActive) return;
    final card = cards[index];
    if (card.found) return;

    if (card.isDifferent) {
      card.found = true;
      found++;
      combo++;
      if (combo > maxCombo) maxCombo = combo;
      final bonus = combo >= 3 ? 10 : 0;
      score += 20 + bonus;
      timeLeft += 2;
      if (found >= targets) {
        level++;
        Juice.levelUp();
        _buildLevel();
      } else {
        combo >= 3 ? Juice.combo() : Juice.correct();
      }
    } else {
      card.wrong = true;
      wrongTick++;
      combo = 0;
      Juice.wrong();
      score = max(0, score - 10);
      timeLeft = max(1, timeLeft - 3);
      if (GameSettings.instance.survival) {
        lives--;
        if (lives <= 0) {
          lives = 0;
          _end();
        }
      }
      _wrongTimer?.cancel();
      _wrongTimer = Timer(const Duration(milliseconds: 350), () {
        card.wrong = false;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void _end() {
    _timer?.cancel();
    isActive = false;
    isOver = true;
  }

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

  void revive() {
    if (!isOver) return;
    isOver = false;
    isActive = true;
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
          _end();
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hintTimer?.cancel();
    _wrongTimer?.cancel();
    super.dispose();
  }
}
