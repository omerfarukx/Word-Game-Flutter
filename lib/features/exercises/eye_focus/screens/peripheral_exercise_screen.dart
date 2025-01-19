import 'package:flutter/material.dart';
import '../models/peripheral_exercise.dart';
import '../widgets/peripheral_exercise_widget.dart';

class PeripheralExerciseScreen extends StatelessWidget {
  final PeripheralExercise exercise;

  const PeripheralExerciseScreen({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  void _showCompletionDialog(
      BuildContext context, int score, int missedTargets) {
    final accuracy = score / ((score + missedTargets) * 10) * 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Süre: ${exercise.durationInSeconds} saniye'),
            const SizedBox(height: 8),
            Text('Skor: $score'),
            const SizedBox(height: 8),
            Text('İsabet Oranı: ${accuracy.toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(exercise.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      exercise.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '⚠️ Merkezdeki noktaya odaklanın ve çevrede beliren hedefleri fark ettiğinizde tıklayın.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PeripheralExerciseWidget(
                exercise: exercise,
                onComplete: () => _showCompletionDialog(context, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
