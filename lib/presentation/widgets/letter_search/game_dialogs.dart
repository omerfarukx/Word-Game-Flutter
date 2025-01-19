import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class GameDialogs {
  static void showStartDialog(
      BuildContext context, int countDown, VoidCallback onStart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: countDown < 3
            ? Text(
                countDown > 0 ? '$countDown' : 'BAŞLA!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              )
            : const Text(
                'Oyunu Başlat',
                textAlign: TextAlign.center,
              ),
        content: countDown == 3
            ? const Text(
                'Hazır olduğunuzda başlayabilirsiniz!',
                textAlign: TextAlign.center,
              )
            : null,
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (countDown == 3)
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 24,
                ),
              ),
              child: const Text(
                'BAŞLAT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static void showGameOverDialog(
    BuildContext context, {
    required int score,
    required VoidCallback onRestart,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Color(0xFF1A237E).withOpacity(0.95),
                        Color(0xFF0D47A1).withOpacity(0.95),
                      ]
                    : [
                        Color(0xFFE3F2FD).withOpacity(0.95),
                        Color(0xFFBBDEFB).withOpacity(0.95),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.1),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.timer_off_rounded,
                          size: 40,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Süre Doldu!',
                        style: GoogleFonts.nunito(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              color: Colors.amber,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Puanınız: $score',
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: onRestart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.white12 : Colors.black12,
                          foregroundColor:
                              isDark ? Colors.white : Colors.black87,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded),
                            const SizedBox(width: 8),
                            Text(
                              'Yeniden Başla',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nasıl Oynanır?'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Yukarıda verilen kelimeleri bulmaya çalışın.'),
              SizedBox(height: 8),
              Text(
                  '2. Kelimeleri fare ile sürükleyerek veya harflere tıklayarak seçin.'),
              SizedBox(height: 8),
              Text('3. Harfler yan yana, alt alta veya çapraz olabilir.'),
              SizedBox(height: 8),
              Text('4. Doğru kelimeyi bulduğunuzda +10 puan kazanırsınız.'),
              SizedBox(height: 8),
              Text('5. Yanlış kelime seçtiğinizde -10 puan kaybedersiniz.'),
              SizedBox(height: 8),
              Text('6. İpucu kullandığınızda -5 puan kaybedersiniz.'),
              SizedBox(height: 8),
              Text(
                  '7. Her 3 kelimeyi bulduğunuzda yeni kelimeler gelir ve süre yenilenir.'),
              SizedBox(height: 8),
              Text('8. Süre bitmeden önce kelimeleri bulmaya çalışın!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anladım'),
            ),
          ],
        );
      },
    );
  }
}
