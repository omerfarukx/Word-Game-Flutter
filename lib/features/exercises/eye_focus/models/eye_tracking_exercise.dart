import 'package:flutter/material.dart';

enum TrackingPattern {
  horizontal,
  vertical,
  diagonal,
  circular,
  random,
}

class EyeTrackingExercise {
  final String title;
  final String description;
  final int durationInSeconds;
  final TrackingPattern pattern;
  final double speed;
  final Color targetColor;
  final double targetSize;

  const EyeTrackingExercise({
    required this.title,
    required this.description,
    required this.durationInSeconds,
    required this.pattern,
    required this.speed,
    required this.targetColor,
    this.targetSize = 20.0,
  });

  factory EyeTrackingExercise.beginner() {
    return const EyeTrackingExercise(
      title: 'Temel Göz Takibi',
      description: 'Yatay hareket eden hedefi gözlerinizle takip edin.',
      durationInSeconds: 30,
      pattern: TrackingPattern.horizontal,
      speed: 100.0,
      targetColor: Colors.green,
    );
  }

  factory EyeTrackingExercise.intermediate() {
    return const EyeTrackingExercise(
      title: 'Orta Seviye Göz Takibi',
      description: 'Dairesel hareket eden hedefi gözlerinizle takip edin.',
      durationInSeconds: 45,
      pattern: TrackingPattern.circular,
      speed: 150.0,
      targetColor: Colors.blue,
    );
  }

  factory EyeTrackingExercise.advanced() {
    return const EyeTrackingExercise(
      title: 'İleri Seviye Göz Takibi',
      description: 'Rastgele hareket eden hedefi gözlerinizle takip edin.',
      durationInSeconds: 60,
      pattern: TrackingPattern.random,
      speed: 200.0,
      targetColor: Colors.red,
    );
  }
}
