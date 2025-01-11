import 'package:flutter/material.dart';

enum PeripheralDifficulty {
  easy, // Daha az hedef, daha uzun görünme süresi
  medium, // Orta sayıda hedef, orta görünme süresi
  hard, // Çok hedef, kısa görünme süresi
}

class PeripheralExercise {
  final String title;
  final String description;
  final int durationInSeconds;
  final PeripheralDifficulty difficulty;
  final int targetCount; // Aynı anda görünecek hedef sayısı
  final double targetShowTime; // Hedeflerin görünme süresi (saniye)
  final double targetSize; // Hedef boyutu
  final Color targetColor; // Hedef rengi
  final Color centerColor; // Merkez nokta rengi

  const PeripheralExercise({
    required this.title,
    required this.description,
    required this.durationInSeconds,
    required this.difficulty,
    required this.targetCount,
    required this.targetShowTime,
    required this.targetColor,
    required this.centerColor,
    this.targetSize = 20.0,
  });

  factory PeripheralExercise.easy() {
    return const PeripheralExercise(
      title: 'Temel Periferik Görüş',
      description:
          'Merkezdeki noktaya odaklanırken çevrede beliren hedefleri fark edin.',
      durationInSeconds: 30,
      difficulty: PeripheralDifficulty.easy,
      targetCount: 1,
      targetShowTime: 2.0,
      targetColor: Colors.green,
      centerColor: Colors.white,
    );
  }

  factory PeripheralExercise.medium() {
    return const PeripheralExercise(
      title: 'Orta Seviye Periferik Görüş',
      description:
          'Merkezdeki noktaya odaklanırken çevrede aynı anda beliren birden fazla hedefi fark edin.',
      durationInSeconds: 45,
      difficulty: PeripheralDifficulty.medium,
      targetCount: 2,
      targetShowTime: 1.5,
      targetColor: Colors.blue,
      centerColor: Colors.white,
    );
  }

  factory PeripheralExercise.hard() {
    return const PeripheralExercise(
      title: 'İleri Seviye Periferik Görüş',
      description:
          'Merkezdeki noktaya odaklanırken çevrede hızlıca beliren çok sayıda hedefi fark edin.',
      durationInSeconds: 60,
      difficulty: PeripheralDifficulty.hard,
      targetCount: 3,
      targetShowTime: 1.0,
      targetColor: Colors.red,
      centerColor: Colors.white,
    );
  }
}
