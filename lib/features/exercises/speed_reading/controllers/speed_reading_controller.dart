import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../data/speed_reading_data.dart';

enum ReadSpeed { slow, medium, fast }

extension ReadSpeedX on ReadSpeed {
  String get label => switch (this) {
        ReadSpeed.slow => 'Rahat',
        ReadSpeed.medium => 'Orta',
        ReadSpeed.fast => 'Hızlı',
      };
  int get wpm => switch (this) {
        ReadSpeed.slow => 250,
        ReadSpeed.medium => 400,
        ReadSpeed.fast => 550,
      };
  String get blurb => '$wpm kelime/dakika';
}

enum ReadPhase { idle, countdown, reading, done }

/// Hızlı Okuma: RSVP — words flashed one at a time at a chosen pace, then a
/// summary. One clean screen (the app had two conflicting ones); word
/// splitting fixed to collapse all whitespace.
class SpeedReadingController extends ChangeNotifier {
  SpeedReadingController();

  final Random _rand = Random();

  ReadPhase phase = ReadPhase.idle;
  ReadSpeed speed = ReadSpeed.medium;
  List<String> words = [];
  int index = 0;
  int countdown = 3;

  final List<int> _recent = [];
  Timer? _timer;

  String get currentWord =>
      (index >= 0 && index < words.length) ? words[index] : '';
  int get wordCount => words.length;
  double get progress => words.isEmpty ? 0 : (index + 1) / words.length;
  int get durationSeconds =>
      words.isEmpty ? 0 : (words.length / speed.wpm * 60).round();

  void start(ReadSpeed s) {
    speed = s;
    const texts = SpeedReadingData.texts;
    var pick = _rand.nextInt(texts.length);
    var guard = 0;
    while (_recent.contains(pick) && guard++ < 8) {
      pick = _rand.nextInt(texts.length);
    }
    _recent.add(pick);
    if (_recent.length > 5) _recent.removeAt(0);

    words = texts[pick]
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();
    index = 0;
    countdown = 3;
    phase = ReadPhase.countdown;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      countdown--;
      if (countdown <= 0) {
        t.cancel();
        _startReading();
      }
      notifyListeners();
    });
  }

  void _startReading() {
    phase = ReadPhase.reading;
    index = 0;
    notifyListeners();
    final intervalMs = (60000 / speed.wpm).round();
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (t) {
      if (index >= words.length - 1) {
        t.cancel();
        phase = ReadPhase.done;
      } else {
        index++;
      }
      notifyListeners();
    });
  }

  void backToMenu() {
    _timer?.cancel();
    phase = ReadPhase.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
