import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/feedback/juice.dart';

/// Göz Odaklama — Schultz table: a 6x6 grid of the numbers 1..36 shuffled.
/// Keep your eyes on the centre and find them in order. Rebuilt to fix the
/// divide-by-zero score and to time the run with a proper stopwatch.
class SchultzController extends ChangeNotifier {
  SchultzController();

  static const int size = 6;
  static const int total = size * size;

  List<int> numbers = []; // length 36, value at each cell
  int currentTarget = 1;
  int wrongCount = 0;
  int wrongCell = -1; // transient flash
  final Set<int> found = {}; // numbers already tapped
  bool isComplete = false;

  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;

  int get elapsedSeconds => _watch.elapsed.inSeconds;

  void start() {
    numbers = List.generate(total, (i) => i + 1)..shuffle();
    currentTarget = 1;
    wrongCount = 0;
    wrongCell = -1;
    found.clear();
    isComplete = false;
    _watch
      ..reset()
      ..start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isComplete) notifyListeners();
    });
    notifyListeners();
  }

  void tapNumber(int value) {
    if (isComplete) return;
    if (value == currentTarget) {
      found.add(value);
      currentTarget++;
      if (currentTarget > total) {
        _complete();
        Juice.achievement();
      } else {
        Juice.correct();
      }
    } else {
      wrongCount++;
      wrongCell = value;
      Juice.wrong();
      notifyListeners();
      Timer(const Duration(milliseconds: 300), () {
        if (wrongCell == value) wrongCell = -1;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void _complete() {
    _watch.stop();
    _ticker?.cancel();
    isComplete = true;
  }

  @override
  void dispose() {
    _watch.stop();
    _ticker?.cancel();
    super.dispose();
  }
}
