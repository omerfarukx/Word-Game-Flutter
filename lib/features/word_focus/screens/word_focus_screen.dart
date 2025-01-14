import 'package:flutter/material.dart';
import '../models/word_focus_game.dart';
import '../models/word_pair.dart';
import '../widgets/word_focus_widget.dart';

class WordFocusScreen extends StatelessWidget {
  final WordFocusGame game;
  final WordPair wordPair;

  const WordFocusScreen({
    Key? key,
    required this.game,
    required this.wordPair,
  }) : super(key: key);

  void _showCompletionDialog(BuildContext context, int score, double accuracy) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skorunuz: $score'),
            Text('Doğruluk: ${accuracy.toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dialog'u kapat
              Navigator.of(context).pop(); // Ekranı kapat
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(game.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: WordFocusWidget(
        game: game,
        wordPair: wordPair,
        onComplete: (score, accuracy) =>
            _showCompletionDialog(context, score, accuracy),
      ),
    );
  }
}
