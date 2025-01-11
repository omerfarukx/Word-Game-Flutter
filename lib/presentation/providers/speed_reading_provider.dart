import 'package:flutter/foundation.dart';
import '../../data/speed_reading_data.dart';
import 'dart:math';

class SpeedReadingProvider with ChangeNotifier {
  bool _isInitialized = false;
  final Random _random = Random();

  bool get isInitialized => _isInitialized;

  void initialize() {
    _isInitialized = true;
    notifyListeners();
  }

  String getRandomTextWithWordLimit() {
    if (!_isInitialized) return '';

    try {
      final texts = SpeedReadingData.texts;
      if (texts.isEmpty) return '';

      final randomIndex = _random.nextInt(texts.length);
      return texts[randomIndex];
    } catch (e) {
      debugPrint('Metin seçme hatası: $e');
      return '';
    }
  }
}
