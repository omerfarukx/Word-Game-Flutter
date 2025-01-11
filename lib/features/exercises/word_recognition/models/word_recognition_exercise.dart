import 'package:flutter/material.dart';

enum WordDifficulty {
  easy, // Kısa ve basit kelimeler
  medium, // Orta uzunlukta kelimeler
  hard, // Uzun ve karmaşık kelimeler
}

class WordRecognitionExercise {
  final String title;
  final String description;
  final WordDifficulty difficulty;
  final int durationInSeconds;
  final double
      initialShowDuration; // Kelimenin başlangıçta gösterilme süresi (milisaniye)
  final double minShowDuration; // Minimum gösterim süresi
  final double showDurationDecrease; // Her adımda azalacak süre
  final int wordsPerRound; // Her turda gösterilecek kelime sayısı
  final Color textColor;

  const WordRecognitionExercise({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.durationInSeconds,
    required this.initialShowDuration,
    required this.minShowDuration,
    required this.showDurationDecrease,
    required this.wordsPerRound,
    required this.textColor,
  });

  factory WordRecognitionExercise.easy() {
    return const WordRecognitionExercise(
      title: 'Temel Kelime Tanıma',
      description:
          'Ekranda kısa süreliğine gösterilen basit kelimeleri hatırlayın.',
      difficulty: WordDifficulty.easy,
      durationInSeconds: 60,
      initialShowDuration: 1000, // 1 saniye
      minShowDuration: 300, // 300 milisaniye
      showDurationDecrease: 100, // Her başarıda 100ms azalt
      wordsPerRound: 1,
      textColor: Colors.green,
    );
  }

  factory WordRecognitionExercise.medium() {
    return const WordRecognitionExercise(
      title: 'Orta Seviye Kelime Tanıma',
      description:
          'Ekranda daha kısa süreliğine gösterilen orta seviye kelimeleri hatırlayın.',
      difficulty: WordDifficulty.medium,
      durationInSeconds: 90,
      initialShowDuration: 800, // 800 milisaniye
      minShowDuration: 200, // 200 milisaniye
      showDurationDecrease: 100, // Her başarıda 100ms azalt
      wordsPerRound: 2,
      textColor: Colors.blue,
    );
  }

  factory WordRecognitionExercise.hard() {
    return const WordRecognitionExercise(
      title: 'İleri Seviye Kelime Tanıma',
      description:
          'Ekranda çok kısa süreliğine gösterilen karmaşık kelimeleri hatırlayın.',
      difficulty: WordDifficulty.hard,
      durationInSeconds: 120,
      initialShowDuration: 500, // 500 milisaniye
      minShowDuration: 100, // 100 milisaniye
      showDurationDecrease: 50, // Her başarıda 50ms azalt
      wordsPerRound: 3,
      textColor: Colors.red,
    );
  }
}
