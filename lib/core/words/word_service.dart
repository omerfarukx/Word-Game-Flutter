import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../text/turkish.dart';

/// Loads the bundled Turkish word list once and answers the questions every
/// word game needs: is this a real word, and give me a word that fits a rule.
///
/// The list lives in `assets/data/tr_words.txt` (whitespace-separated). Swap in
/// a larger list there and every game gets richer without code changes.
class WordService {
  WordService._(this._words, this._byFirstLetter);

  final Set<String> _words;
  final Map<String, List<String>> _byFirstLetter;

  static WordService? _instance;
  static WordService get instance => _instance ??
      (throw StateError('WordService.load() must be awaited before use'));

  static bool get isReady => _instance != null;

  static Future<WordService> load() async {
    final raw = await rootBundle.loadString('assets/data/tr_words.txt');
    final words = <String>{};
    for (final line in const LineSplitter().convert(raw)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      for (final token in trimmed.split(RegExp(r'\s+'))) {
        final w = Tr.lower(token);
        if (w.length >= 2 && Tr.lettersOnly.hasMatch(w)) words.add(w);
      }
    }

    final byFirst = <String, List<String>>{};
    for (final w in words) {
      byFirst.putIfAbsent(Tr.firstLetter(w), () => <String>[]).add(w);
    }
    return _instance = WordService._(words, byFirst);
  }

  int get count => _words.length;

  /// Is [word] a real Turkish word in the dictionary?
  bool contains(String word) => _words.contains(Tr.lower(word.trim()));

  /// A random word starting with [letter], optionally excluding [exclude].
  /// Returns null when nothing fits.
  String? randomStartingWith(
    String letter, {
    Set<String> exclude = const {},
    Random? random,
  }) {
    final pool = _byFirstLetter[Tr.lower(letter)];
    if (pool == null || pool.isEmpty) return null;
    final candidates = pool.where((w) => !exclude.contains(w)).toList();
    if (candidates.isEmpty) return null;
    return candidates[(random ?? Random()).nextInt(candidates.length)];
  }

  /// A random word whose length is within [minLen]..[maxLen], excluding
  /// [exclude]. Returns null when nothing fits.
  String? randomWord({
    int minLen = 2,
    int maxLen = 40,
    Set<String> exclude = const {},
    Random? random,
  }) {
    final pool = _words
        .where((w) =>
            w.length >= minLen && w.length <= maxLen && !exclude.contains(w))
        .toList();
    if (pool.isEmpty) return null;
    return pool[(random ?? Random()).nextInt(pool.length)];
  }
}
