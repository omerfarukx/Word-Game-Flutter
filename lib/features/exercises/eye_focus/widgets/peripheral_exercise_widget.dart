import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/peripheral_exercise.dart';

class PeripheralExerciseWidget extends StatefulWidget {
  final PeripheralExercise exercise;
  final VoidCallback onComplete;

  const PeripheralExerciseWidget({
    Key? key,
    required this.exercise,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<PeripheralExerciseWidget> createState() =>
      _PeripheralExerciseWidgetState();
}

class _PeripheralExerciseWidgetState extends State<PeripheralExerciseWidget> {
  Timer? _timer;
  Timer? _targetTimer;
  int _remainingSeconds = 0;
  List<Offset> _targetPositions = [];
  int _score = 0;
  int _missedTargets = 0;

  @override
  void initState() {
    super.initState();
    _startExercise();
  }

  void _startExercise() {
    _remainingSeconds = widget.exercise.durationInSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _targetTimer?.cancel();
          widget.onComplete();
        }
      });
    });
    _showNewTargets();
  }

  void _showNewTargets() {
    _targetTimer?.cancel();
    _targetTimer = Timer.periodic(
      Duration(milliseconds: (widget.exercise.targetShowTime * 1000).toInt()),
      (timer) {
        setState(() {
          // Önceki hedefler kaçırıldı sayılır
          _missedTargets += _targetPositions.length;

          // Yeni hedef pozisyonları oluştur
          _targetPositions = List.generate(
            widget.exercise.targetCount,
            (index) => _getRandomPosition(),
          );
        });
      },
    );
  }

  Offset _getRandomPosition() {
    final random = Random();
    // Ekranın kenarlarından uzak dur
    const margin = 0.2;
    const maxDistance = 0.8;

    double x, y;
    do {
      x = -maxDistance + random.nextDouble() * (maxDistance * 2);
      y = -maxDistance + random.nextDouble() * (maxDistance * 2);
    } while (x.abs() < margin && y.abs() < margin); // Merkeze çok yakın olmasın

    return Offset(x, y);
  }

  void _handleTargetTap(Offset position) {
    setState(() {
      _targetPositions.remove(position);
      _score += 10;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _targetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Süre: $_remainingSeconds',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                'Skor: $_score',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Merkez nokta
              Center(
                child: Container(
                  width: widget.exercise.targetSize,
                  height: widget.exercise.targetSize,
                  decoration: BoxDecoration(
                    color: widget.exercise.centerColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Hedefler
              ..._targetPositions.map((position) {
                return Align(
                  alignment: Alignment(position.dx, position.dy),
                  child: GestureDetector(
                    onTap: () => _handleTargetTap(position),
                    child: Container(
                      width: widget.exercise.targetSize,
                      height: widget.exercise.targetSize,
                      decoration: BoxDecoration(
                        color: widget.exercise.targetColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
