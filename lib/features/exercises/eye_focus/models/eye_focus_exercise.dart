import 'package:flutter/material.dart';

enum EyeFocusType {
  schultz, // Schultz tabloları
  tracking, // Göz takip egzersizi
  peripheral // Periferik görüş
}

class EyeFocusExercise {
  final String id;
  final String title;
  final String description;
  final EyeFocusType type;
  final int difficultyLevel;
  final int gridSize; // Schultz tablosu için grid boyutu
  final int duration; // Saniye cinsinden süre
  final Map<String, dynamic> settings;

  const EyeFocusExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficultyLevel,
    this.gridSize = 5,
    this.duration = 60,
    this.settings = const {},
  });

  factory EyeFocusExercise.schultz({
    required String id,
    required int gridSize,
    required int difficultyLevel,
  }) {
    return EyeFocusExercise(
      id: id,
      title: 'Schultz Tablosu',
      description: 'Sayıları sırayla bulun ve odaklanın',
      type: EyeFocusType.schultz,
      difficultyLevel: difficultyLevel,
      gridSize: gridSize,
      settings: {
        'randomize': true,
        'showTimer': true,
        'highlightFound': true,
      },
    );
  }

  factory EyeFocusExercise.tracking({
    required String id,
    required int difficultyLevel,
  }) {
    return EyeFocusExercise(
      id: id,
      title: 'Göz Takip Egzersizi',
      description: 'Hareketli noktayı gözlerinizle takip edin',
      type: EyeFocusType.tracking,
      difficultyLevel: difficultyLevel,
      settings: {
        'speed': 1.0,
        'pattern': 'circular',
        'showGuides': true,
      },
    );
  }

  factory EyeFocusExercise.peripheral({
    required String id,
    required int difficultyLevel,
  }) {
    return EyeFocusExercise(
      id: id,
      title: 'Periferik Görüş Egzersizi',
      description: 'Merkeze odaklanırken çevredeki değişimleri fark edin',
      type: EyeFocusType.peripheral,
      difficultyLevel: difficultyLevel,
      settings: {
        'flashDuration': 500, // milisaniye
        'symbolSize': 24.0,
        'distance': 100.0,
      },
    );
  }
}
