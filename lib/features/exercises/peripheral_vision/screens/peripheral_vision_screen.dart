import 'package:flutter/material.dart';
import '../models/peripheral_vision_exercise.dart';
import '../widgets/peripheral_vision_widget.dart';

class PeripheralVisionScreen extends StatelessWidget {
  final PeripheralVisionExercise exercise;

  const PeripheralVisionScreen({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  void _showCompletionDialog(BuildContext context, int score, double accuracy) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).cardColor.withOpacity(0.9),
        title: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: exercise.targetColor,
              size: 30,
            ),
            const SizedBox(width: 10),
            const Text('Egzersiz Tamamlandı!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow(
              Icons.score,
              'Toplam Skor',
              score.toString(),
              exercise.targetColor,
            ),
            const SizedBox(height: 12),
            _buildResultRow(
              Icons.percent,
              'Doğruluk Oranı',
              '${accuracy.toStringAsFixed(1)}%',
              exercise.targetColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: exercise.targetColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('TAMAM'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: exercise.title,
      child: Scaffold(
        appBar: AppBar(
          title: Text(exercise.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: exercise.targetColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      exercise.description,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: PeripheralVisionWidget(
                        exercise: exercise,
                        onComplete: (score, accuracy) => _showCompletionDialog(
                          context,
                          score,
                          accuracy,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
