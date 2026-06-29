import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../core/feedback/juice.dart';

/// Harf Arama: a grid of letters with one target letter highlighted; tap every
/// copy of it as fast as you can. A visual-scanning exercise (Görsel category),
/// deliberately distinct from the Kelime Bulma word search.
class LetterSearchController extends ChangeNotifier {
  LetterSearchController();

  static const int size = 8;
  static const int gameSeconds = 60;
  static const String _alphabet = 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ';

  final Random _rand = Random();

  List<String> grid = []; // size*size
  String target = '';
  int occurrences = 0;
  int found = 0;
  final Set<int> foundCells = {};
  int wrongCell = -1; // transient, for flash

  int level = 1;
  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  int attempts = 0;
  int correctTaps = 0;
  int timeLeft = gameSeconds;
  bool isActive = false;
  bool isOver = false;
  int wrongTick = 0;

  Timer? _timer;

  int get accuracy =>
      attempts == 0 ? 0 : ((correctTaps / attempts) * 100).round();

  void start() {
    level = 1;
    score = 0;
    combo = 0;
    maxCombo = 0;
    attempts = 0;
    correctTaps = 0;
    timeLeft = gameSeconds;
    isActive = true;
    isOver = false;
    _buildRound();
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

  void _buildRound() {
    found = 0;
    foundCells.clear();
    wrongCell = -1;
    target = _alphabet[_rand.nextInt(_alphabet.length)];
    occurrences = (4 + level).clamp(4, 9);

    const total = size * size;
    final cells = List.generate(total, (i) => i)..shuffle(_rand);
    final targetCells = cells.take(occurrences).toSet();

    grid = List.generate(total, (i) {
      if (targetCells.contains(i)) return target;
      String ch;
      do {
        ch = _alphabet[_rand.nextInt(_alphabet.length)];
      } while (ch == target);
      return ch;
    });
  }

  void tap(int index) {
    if (!isActive) return;
    if (foundCells.contains(index)) return;
    attempts++;

    if (grid[index] == target) {
      found++;
      correctTaps++;
      foundCells.add(index);
      combo++;
      if (combo > maxCombo) maxCombo = combo;
      score += 10 + (combo >= 3 ? 5 : 0);
      if (found >= occurrences) {
        level++;
        timeLeft += 5;
        Juice.levelUp();
        _buildRound();
      } else {
        combo >= 3 ? Juice.combo() : Juice.correct();
      }
    } else {
      combo = 0;
      score = max(0, score - 5);
      timeLeft = max(1, timeLeft - 2);
      wrongCell = index;
      wrongTick++;
      Juice.wrong();
      Timer(const Duration(milliseconds: 300), () {
        if (wrongCell == index) wrongCell = -1;
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
