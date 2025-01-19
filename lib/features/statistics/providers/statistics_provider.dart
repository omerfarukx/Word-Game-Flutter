import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsProvider with ChangeNotifier {
  String _readingLevel = 'Başlangıç';
  int _completedExercises = 0;
  double _duration = 0.0;
  int _streakDays = 0;
  DateTime? _lastExerciseDate;

  String get readingLevel => _readingLevel;
  int get completedExercises => _completedExercises;
  double get duration => _duration;
  int get streakDays => _streakDays;

  StatisticsProvider() {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();

    _readingLevel = prefs.getString('readingLevel') ?? 'Başlangıç';
    _completedExercises = prefs.getInt('completedExercises') ?? 0;
    _duration = prefs.getDouble('duration') ?? 0.0;
    _streakDays = prefs.getInt('streakDays') ?? 0;

    final lastExerciseDateStr = prefs.getString('lastExerciseDate');
    if (lastExerciseDateStr != null) {
      _lastExerciseDate = DateTime.parse(lastExerciseDateStr);
    }

    notifyListeners();
  }

  Future<void> _saveStatistics() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('readingLevel', _readingLevel);
    await prefs.setInt('completedExercises', _completedExercises);
    await prefs.setDouble('duration', _duration);
    await prefs.setInt('streakDays', _streakDays);

    if (_lastExerciseDate != null) {
      await prefs.setString(
          'lastExerciseDate', _lastExerciseDate!.toIso8601String());
    }
  }

  void updateReadingLevel(String level) {
    _readingLevel = level;
    _saveStatistics();
    notifyListeners();
  }

  void addExerciseCompletion(double exerciseDuration) {
    _completedExercises++;
    _duration += exerciseDuration;

    final now = DateTime.now();
    if (_lastExerciseDate != null) {
      final difference = now.difference(_lastExerciseDate!).inDays;
      if (difference == 1) {
        // Ardışık gün
        _streakDays++;
      } else if (difference > 1) {
        // Seri bozuldu
        _streakDays = 1;
      }
    } else {
      // İlk egzersiz
      _streakDays = 1;
    }

    _lastExerciseDate = now;
    _saveStatistics();
    notifyListeners();
  }

  void resetDailyProgress() {
    _completedExercises = 0;
    _duration = 0.0;
    _saveStatistics();
    notifyListeners();
  }

  // Okuma düzeyini hesapla
  void calculateReadingLevel() {
    if (_completedExercises >= 50) {
      _readingLevel = 'Şampiyon';
    } else if (_completedExercises >= 30) {
      _readingLevel = 'Uzman';
    } else if (_completedExercises >= 15) {
      _readingLevel = 'İleri';
    } else if (_completedExercises >= 5) {
      _readingLevel = 'Orta';
    } else {
      _readingLevel = 'Başlangıç';
    }
    _saveStatistics();
    notifyListeners();
  }
}
