import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Two intentional faces: Space Grotesk carries every headline and the big
/// game words (its quirky geometric letterforms suit a game *about* letters);
/// Inter handles body, labels and data. Both have full Turkish glyphs.
class AppText {
  const AppText._();

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color? color,
    double letterSpacing = -0.5,
    double height = 1.04,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textHi,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double letterSpacing = 0,
    double height = 1.35,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textMid,
        letterSpacing: letterSpacing,
        height: height,
      );

  /// Small all-caps utility label for eyebrows and stat captions.
  static TextStyle label(double size, {Color? color}) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textLow,
        letterSpacing: 1.4,
      );
}
