import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/feedback/game_settings.dart';
import '../../../core/feedback/juice.dart';
import '../../../core/text/turkish.dart';
import '../../../core/words/word_service.dart';

/// Why a word was rejected — drives the inline error message.
enum ChainReject { tooShort, notLetters, wrongStart, alreadyUsed, notInDict }

/// Kelime Zinciri game logic. Each word must start with the previous word's
/// last letter, be a real Turkish word, and not repeat. Pure state + rules;
/// the screen only renders and forwards input.
class WordChainController extends ChangeNotifier {
  WordChainController(this._dict);

  final WordService _dict;

  static const int gameSeconds = 90;
  static const int minWordLength = 2;

  final List<String> chain = []; // validated, lowercased
  final Set<String> _used = {};

  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  String longestWord = '';
  int timeLeft = gameSeconds;
  bool isActive = false;
  bool isOver = false;

  /// Last rejection, with a counter so the screen can re-trigger the shake
  /// even when the same reason repeats.
  ChainReject? reject;
  int rejectTick = 0;

  // Power-ups
  int jokers = 2;
  int freezes = 1;
  int frozenTicks = 0;
  bool get isFrozen => frozenTicks > 0;

  Timer? _timer;

  /// Letter the next word must start with, or null for the free first move.
  String? get requiredLetter =>
      chain.isEmpty ? null : Tr.lastLetter(chain.last);

  void start() {
    chain.clear();
    _used.clear();
    score = 0;
    combo = 0;
    maxCombo = 0;
    longestWord = '';
    timeLeft = GameSettings.instance.seconds(gameSeconds);
    isActive = true;
    isOver = false;
    reject = null;
    jokers = 2;
    freezes = 1;
    frozenTicks = 0;
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
    notifyListeners();
  }

  void freeze() {
    if (!isActive || freezes <= 0 || frozenTicks > 0) return;
    freezes--;
    frozenTicks = 5;
    notifyListeners();
  }

  /// Auto-plays a valid next word from the dictionary.
  void useJoker() {
    if (!isActive || jokers <= 0) return;
    final req = requiredLetter;
    final word = req == null
        ? _dict.randomWord(minLen: minWordLength, exclude: _used)
        : _dict.randomStartingWith(req, exclude: _used);
    if (word == null) return;
    jokers--;
    submit(word);
  }

  /// Returns true if the word was accepted.
  bool submit(String raw) {
    if (!isActive) return false;
    final word = Tr.lower(raw.trim());

    final problem = _check(word);
    if (problem != null) {
      reject = problem;
      rejectTick++;
      combo = 0;
      Juice.wrong();
      notifyListeners();
      return false;
    }

    reject = null;
    chain.add(word);
    _used.add(word);
    combo++;
    if (combo > maxCombo) maxCombo = combo;

    final base = word.length * 10;
    final bonus = combo >= 3 ? (base * 0.5).round() : 0;
    score += base + bonus;

    if (word.length > longestWord.length) longestWord = word;
    combo >= 3 ? Juice.combo() : Juice.correct();
    notifyListeners();
    return true;
  }

  ChainReject? _check(String word) {
    if (word.length < minWordLength) return ChainReject.tooShort;
    if (!Tr.lettersOnly.hasMatch(word)) return ChainReject.notLetters;
    final req = requiredLetter;
    if (req != null && Tr.firstLetter(word) != req) {
      return ChainReject.wrongStart;
    }
    if (_used.contains(word)) return ChainReject.alreadyUsed;
    if (!_dict.contains(word)) return ChainReject.notInDict;
    return null;
  }

  String rejectMessage(ChainReject r) => switch (r) {
        ChainReject.tooShort => 'En az $minWordLength harfli bir kelime yaz',
        ChainReject.notLetters => 'Sadece harf kullan',
        ChainReject.wrongStart =>
          '“${Tr.upper(requiredLetter ?? '')}” harfiyle başlamalı',
        ChainReject.alreadyUsed => 'Bu kelime zaten kullanıldı',
        ChainReject.notInDict => 'Bu kelime sözlükte yok',
      };

  void giveUp() => _finish();

  void _finish() {
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
