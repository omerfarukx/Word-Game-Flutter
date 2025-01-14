import 'package:flutter/material.dart';

class PeripheralVisionExercise {
  final String id;
  final String title;
  final String description;
  final Color targetColor;
  final int difficulty; // 1: Kolay, 2: Orta, 3: Zor
  final int durationInSeconds;

  const PeripheralVisionExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.targetColor,
    required this.difficulty,
    this.durationInSeconds = 60,
  });

  factory PeripheralVisionExercise.basic() {
    return const PeripheralVisionExercise(
      id: 'basic_peripheral',
      title: 'Temel Çevresel Görüş',
      description: 'Merkeze odaklanırken çevredeki büyük şekilleri fark edin.',
      targetColor: Color(0xFF4CAF50),
      difficulty: 1,
    );
  }

  factory PeripheralVisionExercise.intermediate() {
    return const PeripheralVisionExercise(
      id: 'intermediate_peripheral',
      title: 'Orta Seviye Çevresel Görüş',
      description:
          'Merkeze odaklanırken çevredeki şekilleri daha hızlı algılayın.',
      targetColor: Color(0xFF2196F3),
      difficulty: 2,
      durationInSeconds: 45,
    );
  }

  factory PeripheralVisionExercise.advanced() {
    return const PeripheralVisionExercise(
      id: 'advanced_peripheral',
      title: 'İleri Seviye Çevresel Görüş',
      description:
          'Merkeze odaklanırken çevredeki şekilleri çok hızlı algılayın.',
      targetColor: Color(0xFFF44336),
      difficulty: 3,
      durationInSeconds: 30,
    );
  }
}
