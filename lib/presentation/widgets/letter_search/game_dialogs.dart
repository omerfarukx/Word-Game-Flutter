import 'package:flutter/material.dart';

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Süre Doldu!'),
        content: Text('Puanınız: $score'),
        actions: [
          TextButton(
            onPressed: onRestart,
            child: const Text('Yeniden Başla'),
          ),
        ],
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
