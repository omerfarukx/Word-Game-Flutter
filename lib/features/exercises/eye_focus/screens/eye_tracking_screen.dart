import 'package:flutter/material.dart';
import '../models/eye_tracking_exercise.dart';
import '../widgets/eye_tracking_widget.dart';

class EyeTrackingScreen extends StatelessWidget {
  final EyeTrackingExercise exercise;

  const EyeTrackingScreen({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tebrikler!'),
        content: Text(
            '${exercise.durationInSeconds} saniyelik egzersizi tamamladınız.'),
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
                child: Text(
                  exercise.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: EyeTrackingWidget(
                exercise: exercise,
                onComplete: () => _showCompletionDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
