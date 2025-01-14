import 'package:flutter/material.dart';

enum WordGameType {
  synonyms, // Eş anlamlılar
  antonyms, // Zıt anlamlılar
  wordFamily, // Kelime ailesi
  category // Kategori eşleştirme
}

class WordFocusGame {
  final String id;
  final String title;
  final String description;
  final WordGameType type;
  final int difficultyLevel;
  final int duration; // saniye cinsinden
  final int wordCount; // çevredeki kelime sayısı
  final Map<String, dynamic> settings;

  const WordFocusGame({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficultyLevel,
    this.duration = 60,
    this.wordCount = 8,
    this.settings = const {},
  });

  factory WordFocusGame.synonyms({
    required String id,
    required int difficultyLevel,
  }) {
    return WordFocusGame(
      id: id,
      title: 'Eş Anlamlı Kelimeler',
      description: 'Ortadaki kelimenin eş anlamlısını çevreden bulun',
      type: WordGameType.synonyms,
      difficultyLevel: difficultyLevel,
      settings: {
        'showHints': true,
        'showTimer': true,
        'highlightCorrect': true,
      },
    );
  }

  factory WordFocusGame.antonyms({
    required String id,
    required int difficultyLevel,
  }) {
    return WordFocusGame(
      id: id,
      title: 'Zıt Anlamlı Kelimeler',
      description: 'Ortadaki kelimenin zıt anlamlısını çevreden bulun',
      type: WordGameType.antonyms,
      difficultyLevel: difficultyLevel,
      settings: {
        'showHints': true,
        'showTimer': true,
        'highlightCorrect': true,
      },
    );
  }

  factory WordFocusGame.wordFamily({
    required String id,
    required int difficultyLevel,
  }) {
    return WordFocusGame(
      id: id,
      title: 'Kelime Ailesi',
      description: 'Ortadaki kelime ile aynı kökten türeyen kelimeleri bulun',
      type: WordGameType.wordFamily,
      difficultyLevel: difficultyLevel,
      settings: {
        'showHints': true,
        'showTimer': true,
        'highlightCorrect': true,
      },
    );
  }

  factory WordFocusGame.category({
    required String id,
    required int difficultyLevel,
  }) {
    return WordFocusGame(
      id: id,
      title: 'Kategori Eşleştirme',
      description: 'Ortadaki kelime ile aynı kategoriden kelimeleri bulun',
      type: WordGameType.category,
      difficultyLevel: difficultyLevel,
      settings: {
        'showHints': true,
        'showTimer': true,
        'highlightCorrect': true,
      },
    );
  }
}
