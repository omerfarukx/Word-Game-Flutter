import 'package:flutter/material.dart';

/// The single source of colour for the whole app: a deep ink-navy base with
/// one vivid accent per exercise category. No screen hard-codes hex anymore.
class AppColors {
  const AppColors._();

  // Base — deep ink navy, never pure black.
  static const bg = Color(0xFF0D1322);
  static const bgDeep = Color(0xFF080C17);
  static const surface = Color(0xFF161E33);
  static const surfaceHi = Color(0xFF1F2A45);
  static const stroke = Color(0xFF2A3553);

  // Text
  static const textHi = Color(0xFFEAEEF8);
  static const textMid = Color(0xFFB2BCD6);
  static const textLow = Color(0xFF76819F);

  // Category accents
  static const word = Color(0xFF8B5CF6); // Kelime — violet
  static const wordSoft = Color(0xFFB7A4FB);
  static const visual = Color(0xFF22D3EE); // Görsel — cyan
  static const reading = Color(0xFFF5A524); // Okuma — amber

  // Semantic
  static const success = Color(0xFF34D399);
  static const danger = Color(0xFFFB7185);
  static const warning = Color(0xFFFBBF24);
}

/// The three exercise families. Each owns an accent colour and label so a game
/// screen tints itself just by declaring which family it belongs to.
enum GameCategory { word, visual, reading }

extension GameCategoryX on GameCategory {
  Color get accent => switch (this) {
        GameCategory.word => AppColors.word,
        GameCategory.visual => AppColors.visual,
        GameCategory.reading => AppColors.reading,
      };

  Color get accentSoft => switch (this) {
        GameCategory.word => AppColors.wordSoft,
        GameCategory.visual => const Color(0xFF7DE9FB),
        GameCategory.reading => const Color(0xFFFBC97A),
      };

  String get label => switch (this) {
        GameCategory.word => 'Kelime',
        GameCategory.visual => 'Görsel',
        GameCategory.reading => 'Okuma',
      };
}
