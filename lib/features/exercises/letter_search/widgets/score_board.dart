import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  final int score;
  final int foundWordsCount;
  final int totalWords;
  final int timeLeft;

  const ScoreBoard({
    super.key,
    required this.score,
    required this.foundWordsCount,
    required this.totalWords,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Puan: $score',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          Text(
            'Süre: $timeLeft',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          Text(
            'Bulunan: $foundWordsCount/$totalWords',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }
}
