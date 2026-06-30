import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/feedback/game_settings.dart';
import '../../../core/feedback/juice.dart';
import '../../../core/text/turkish.dart';
import '../data/word_search_data.dart';

class SearchTarget {
  SearchTarget(this.word);
  final String word; // uppercase
  bool found = false;
  List<int> cells = []; // encoded grid positions
}

/// Kelime Bulma: a themed word-search grid. Drag across a straight line of
/// letters to claim a word (forward or backward). Rebuilt to fix the broken
/// drag, double-scored words and the unbounded placement loop.
class WordSearchController extends ChangeNotifier {
  WordSearchController();

  static const int size = 9;
  static const int wordsPerPuzzle = 6;
  static const int gameSeconds = 120;
  static const String _alphabet = 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ';
  static const List<List<int>> _dirs = [
    [0, 1], [0, -1], [1, 0], [-1, 0],
    [1, 1], [1, -1], [-1, 1], [-1, -1],
  ];

  final Random _rand = Random();

  List<List<String>> grid = [];
  List<SearchTarget> targets = [];
  final Set<int> foundCells = {};
  List<int> selection = []; // encoded r*size+c
  int _selStartR = -1;
  int _selStartC = -1;

  String themeName = '';
  int level = 1;
  int score = 0;
  int timeLeft = gameSeconds;
  bool isActive = false;
  bool isOver = false;

  // Power-ups
  int hints = 2;
  int jokers = 1;
  int freezes = 1;
  int frozenTicks = 0;
  final Set<int> hintCells = {};
  bool get isFrozen => frozenTicks > 0;

  final List<String> _recentThemes = [];
  Timer? _timer;
  Timer? _hintTimer;

  int get foundCount => targets.where((t) => t.found).length;

  void start() {
    level = 1;
    score = 0;
    timeLeft = GameSettings.instance.seconds(gameSeconds);
    isActive = true;
    isOver = false;
    hints = 2;
    jokers = 1;
    freezes = 1;
    frozenTicks = 0;
    hintCells.clear();
    _recentThemes.clear();
    _buildPuzzle();
    _hintTimer?.cancel();
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
    if (!isActive || freezes <= 0 || frozenTicks > 0) return;
    freezes--;
    frozenTicks = 5;
    notifyListeners();
  }

  void useHint() {
    if (!isActive || hints <= 0) return;
    final t = targets.firstWhere((t) => !t.found, orElse: () => SearchTarget(''));
    if (t.cells.isEmpty) return;
    hints--;
    hintCells
      ..clear()
      ..add(t.cells.first);
    notifyListeners();
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 1600), () {
      hintCells.clear();
      notifyListeners();
    });
  }

  void useJoker() {
    if (!isActive || jokers <= 0) return;
    final t = targets.firstWhere((t) => !t.found, orElse: () => SearchTarget(''));
    if (t.cells.isEmpty) return;
    jokers--;
    t.found = true;
    foundCells.addAll(t.cells);
    score += t.word.length * 10;
    timeLeft += 5;
    if (foundCount >= targets.length) {
      level++;
      timeLeft += 15;
      Juice.levelUp();
      _buildPuzzle();
    } else {
      Juice.correct();
    }
    notifyListeners();
  }

  void _buildPuzzle() {
    foundCells.clear();
    selection = [];

    var theme = WordSearchData.themes[_rand.nextInt(WordSearchData.themes.length)];
    var guard = 0;
    while (_recentThemes.contains(theme.name) && guard++ < 8) {
      theme = WordSearchData.themes[_rand.nextInt(WordSearchData.themes.length)];
    }
    _recentThemes.add(theme.name);
    if (_recentThemes.length > 3) _recentThemes.removeAt(0);
    themeName = theme.name;

    grid = List.generate(size, (_) => List.filled(size, ''));

    final candidates = theme.words
        .map(Tr.upper)
        .where((w) => w.length <= size)
        .toList()
      ..shuffle(_rand);
    candidates.sort((a, b) => b.length.compareTo(a.length));

    final placed = <SearchTarget>[];
    for (final word in candidates) {
      if (placed.length >= wordsPerPuzzle) break;
      final cells = _tryPlace(word);
      if (cells != null) placed.add(SearchTarget(word)..cells = cells);
    }
    targets = placed;

    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (grid[r][c].isEmpty) {
          grid[r][c] = _alphabet[_rand.nextInt(_alphabet.length)];
        }
      }
    }
  }

  List<int>? _tryPlace(String word) {
    for (var attempt = 0; attempt < 80; attempt++) {
      final dir = _dirs[_rand.nextInt(_dirs.length)];
      final sr = _rand.nextInt(size);
      final sc = _rand.nextInt(size);
      final er = sr + dir[0] * (word.length - 1);
      final ec = sc + dir[1] * (word.length - 1);
      if (er < 0 || er >= size || ec < 0 || ec >= size) continue;

      var ok = true;
      for (var i = 0; i < word.length; i++) {
        final cell = grid[sr + dir[0] * i][sc + dir[1] * i];
        if (cell.isNotEmpty && cell != word[i]) {
          ok = false;
          break;
        }
      }
      if (!ok) continue;

      final cells = <int>[];
      for (var i = 0; i < word.length; i++) {
        final r = sr + dir[0] * i;
        final c = sc + dir[1] * i;
        grid[r][c] = word[i];
        cells.add(r * size + c);
      }
      return cells;
    }
    return null;
  }

  // ── Drag selection ─────────────────────────────────────────────────────────
  void selectStart(int r, int c) {
    if (!isActive) return;
    _selStartR = r;
    _selStartC = c;
    selection = [r * size + c];
    notifyListeners();
  }

  void selectUpdate(int r, int c) {
    if (!isActive || _selStartR < 0) return;
    final dr = r - _selStartR;
    final dc = c - _selStartC;
    if (!(dr == 0 || dc == 0 || dr.abs() == dc.abs())) return; // not a line
    final steps = max(dr.abs(), dc.abs());
    final sr = dr == 0 ? 0 : dr ~/ dr.abs();
    final sc = dc == 0 ? 0 : dc ~/ dc.abs();
    selection = [
      for (var i = 0; i <= steps; i++)
        (_selStartR + sr * i) * size + (_selStartC + sc * i),
    ];
    notifyListeners();
  }

  void selectEnd() {
    if (!isActive || selection.isEmpty) {
      selection = [];
      _selStartR = -1;
      return;
    }
    final word = selection.map((id) => grid[id ~/ size][id % size]).join();
    final reversed = word.split('').reversed.join();
    for (final t in targets) {
      if (!t.found && (t.word == word || t.word == reversed)) {
        t.found = true;
        foundCells.addAll(selection);
        score += t.word.length * 10;
        timeLeft += 5;
        if (foundCount >= targets.length) {
          level++;
          timeLeft += 15;
          Juice.levelUp();
          _buildPuzzle();
        } else {
          Juice.correct();
        }
        break;
      }
    }
    selection = [];
    _selStartR = -1;
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
    _hintTimer?.cancel();
    super.dispose();
  }
}
