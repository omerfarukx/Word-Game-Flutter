import 'package:flutter/material.dart';

enum PeripheralDifficulty {
  easy, // Az sayıda, büyük şekiller
  medium, // Orta sayıda, orta boy şekiller
  hard, // Çok sayıda, küçük şekiller
}

class PeripheralVisionExercise {
  final String title;
  final String description;
  final PeripheralDifficulty difficulty;
  final int durationInSeconds;
  final int itemCount; // Ekranda gösterilecek şekil/kelime sayısı
  final double itemSize; // Şekil/kelime boyutu
  final double radius; // Merkeze olan maksimum uzaklık
  final Duration showDuration; // Gösterim süresi
  final Color targetColor;

  const PeripheralVisionExercise({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.durationInSeconds,
    required this.itemCount,
    required this.itemSize,
    required this.radius,
    required this.showDuration,
    required this.targetColor,
  });

  factory PeripheralVisionExercise.easy() {
    return const PeripheralVisionExercise(
      title: 'Temel Çevresel Görüş',
      description: 'Merkeze odaklanırken çevredeki büyük şekilleri fark edin.',
      difficulty: PeripheralDifficulty.easy,
      durationInSeconds: 60,
      itemCount: 4,
      itemSize: 60,
      radius: 150,
      showDuration: Duration(milliseconds: 2000),
      targetColor: Colors.green,
    );
  }

  factory PeripheralVisionExercise.medium() {
    return const PeripheralVisionExercise(
      title: 'Orta Seviye Çevresel Görüş',
      description:
          'Merkeze odaklanırken çevredeki orta boy şekilleri fark edin.',
      difficulty: PeripheralDifficulty.medium,
      durationInSeconds: 90,
      itemCount: 6,
      itemSize: 40,
      radius: 180,
      showDuration: Duration(milliseconds: 1500),
      targetColor: Colors.blue,
    );
  }

  factory PeripheralVisionExercise.hard() {
    return const PeripheralVisionExercise(
      title: 'İleri Seviye Çevresel Görüş',
      description: 'Merkeze odaklanırken çevredeki küçük şekilleri fark edin.',
      difficulty: PeripheralDifficulty.hard,
      durationInSeconds: 120,
      itemCount: 8,
      itemSize: 30,
      radius: 200,
      showDuration: Duration(milliseconds: 1000),
      targetColor: Colors.red,
    );
  }
}
