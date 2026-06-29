import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

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
  bool isActive = false;
  bool isOver = false;

  /// Bumps on a wrong tap so the screen can flash/shake.
  int wrongTick = 0;

  Timer? _timer;

  void start() {
    score = 0;
    combo = 0;
    maxCombo = 0;
    level = 1;
    timeLeft = gameSeconds;
    isActive = true;
    isOver = false;
    _buildLevel();
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

  void _buildLevel() {
    found = 0;
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
        _buildLevel();
      }
    } else {
      card.wrong = true;
      wrongTick++;
      combo = 0;
      score = max(0, score - 10);
      timeLeft = max(1, timeLeft - 3);
      Timer(const Duration(milliseconds: 350), () {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
