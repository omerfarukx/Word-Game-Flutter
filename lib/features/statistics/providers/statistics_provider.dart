import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class StatisticsProvider with ChangeNotifier {
  String _readingLevel = 'Başlangıç';
  int _completedExercises = 0;
  double _duration = 0.0;
  int _streakDays = 0;
  DateTime? _lastExerciseDate;

  // Kelime zinciri oyunu skorları
  final List<int> _wordChainScores = [];
  List<int> get wordChainScores => List.unmodifiable(_wordChainScores);

  // Günlük hedef takibi
  String _todayKey = '';
  int _todayCount = 0;

  /// Bir günde tamamlanması hedeflenen egzersiz sayısı.
  static const int dailyGoal = 3;

  String get readingLevel => _readingLevel;
  int get completedExercises => _completedExercises;
  double get duration => _duration;
  int get streakDays => _streakDays;

  /// Bugün tamamlanan egzersiz sayısı (gün değişince sıfırlanır).
  int get todayCount => _todayKey == _dayKey(DateTime.now()) ? _todayCount : 0;

  /// Günlük hedef tamamlandı mı?
  bool get dailyGoalMet => todayCount >= dailyGoal;

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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

    // Kelime zinciri skorlarını yükle
    final scores = prefs.getStringList('wordChainScores');
    if (scores != null) {
      _wordChainScores.clear();
      _wordChainScores.addAll(scores.map((s) => int.parse(s)));
    }

    _todayKey = prefs.getString('todayKey') ?? '';
    _todayCount = prefs.getInt('todayCount') ?? 0;

    _refreshReadingLevel();
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

    // Kelime zinciri skorlarını kaydet
    await prefs.setStringList(
        'wordChainScores', _wordChainScores.map((s) => s.toString()).toList());

    await prefs.setString('todayKey', _todayKey);
    await prefs.setInt('todayCount', _todayCount);
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

    // Günlük hedef sayacı — gün değiştiyse sıfırdan başla.
    final today = _dayKey(now);
    if (_todayKey != today) {
      _todayKey = today;
      _todayCount = 0;
    }
    _todayCount++;

    _lastExerciseDate = now;
    _refreshReadingLevel();
    _saveStatistics();
    notifyListeners();
  }

  void resetDailyProgress() {
    _completedExercises = 0;
    _duration = 0.0;
    _saveStatistics();
    notifyListeners();
  }

  /// Okuma düzeyini tamamlanan egzersiz sayısından türetir (yan etkisiz).
  void _refreshReadingLevel() {
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
  }

  // Okuma düzeyini hesapla + kalıcılaştır.
  void calculateReadingLevel() {
    _refreshReadingLevel();
    _saveStatistics();
    notifyListeners();
  }

  void saveWordChainScore(int score) {
    _wordChainScores.add(score);
    _saveStatistics();
    notifyListeners();
  }

  int get bestWordChainScore {
    if (_wordChainScores.isEmpty) return 0;
    return _wordChainScores.reduce((max, score) => score > max ? score : max);
  }

  double get averageWordChainScore {
    if (_wordChainScores.isEmpty) return 0;
    return _wordChainScores.reduce((sum, score) => sum + score) /
        _wordChainScores.length;
  }
}
