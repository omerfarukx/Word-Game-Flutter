import 'dart:async';
import 'package:flutter/material.dart';
import '../models/eye_focus_exercise.dart';
import '../widgets/schultz_table.dart';

class EyeFocusExerciseScreen extends StatefulWidget {
  final EyeFocusExercise exercise;

  const EyeFocusExerciseScreen({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  State<EyeFocusExerciseScreen> createState() => _EyeFocusExerciseScreenState();
}

class _EyeFocusExerciseScreenState extends State<EyeFocusExerciseScreen> {
  late Timer _timer;
  int _remainingTime = 0;
  int _score = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.exercise.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _completeExercise();
        }
      });
    });
  }

  void _completeExercise() {
    _timer.cancel();
    setState(() {
      _isCompleted = true;
    });
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Egzersiz Tamamlandı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Skorunuz: $_score'),
            const SizedBox(height: 8),
            Text('Süre: ${widget.exercise.duration - _remainingTime} saniye'),
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
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _remainingTime = widget.exercise.duration;
                _score = 0;
                _isCompleted = false;
              });
              _startTimer();
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.title),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Süre: $_remainingTime',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        widget.exercise.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Skor: $_score',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: widget.exercise.type == EyeFocusType.schultz
                      ? SchultzTable(
                          exercise: widget.exercise,
                          onNumberFound: (number) {
                            setState(() {
                              _score += 10;
                            });
                          },
                          onCompleted: _completeExercise,
                        )
                      : const Text('Bu egzersiz türü henüz uygulanmadı'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
