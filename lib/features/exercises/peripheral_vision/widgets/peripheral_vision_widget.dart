import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/peripheral_vision_exercise.dart';

class PeripheralVisionWidget extends StatefulWidget {
  final PeripheralVisionExercise exercise;
  final Function(int score, double accuracy) onComplete;

  const PeripheralVisionWidget({
    Key? key,
    required this.exercise,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<PeripheralVisionWidget> createState() => _PeripheralVisionWidgetState();
}

class _PeripheralVisionWidgetState extends State<PeripheralVisionWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Timer _showItemsTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _remainingSeconds = 0;
  int _score = 0;
  int _totalAttempts = 0;
  bool _isShowingItems = false;
  bool _canAnswer = false;
  List<Offset> _itemPositions = [];
  int _currentTargetIndex = -1;
  final List<String> _shapes = ['●', '■', '▲', '◆'];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.exercise.durationInSeconds;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _startExercise();
  }

  @override
  void dispose() {
    _timer.cancel();
    if (_showItemsTimer.isActive) {
      _showItemsTimer.cancel();
    }
    _pulseController.dispose();
    super.dispose();
  }

  void _startExercise() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeExercise();
        }
      });
    });
    _showNextRound();
  }

  void _showNextRound() {
    if (_remainingSeconds <= 0) return;

    setState(() {
      _generateItemPositions();
      _currentTargetIndex = Random().nextInt(_shapes.length);
      _isShowingItems = true;
      _canAnswer = false;
    });

    _showItemsTimer = Timer(widget.exercise.showDuration, () {
      if (mounted) {
        setState(() {
          _isShowingItems = false;
          _canAnswer = true;
        });
      }
    });
  }

  void _generateItemPositions() {
    _itemPositions = [];
    final random = Random();

    for (int i = 0; i < widget.exercise.itemCount; i++) {
      final angle = 2 * pi * i / widget.exercise.itemCount;
      final radius = widget.exercise.radius * (0.8 + random.nextDouble() * 0.4);
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;
      _itemPositions.add(Offset(x, y));
    }
  }

  void _handleAnswer(int selectedIndex) {
    if (!_canAnswer || _currentTargetIndex == -1) return;

    setState(() {
      if (selectedIndex == _currentTargetIndex) {
        _score++;
      }
      _totalAttempts++;
      _canAnswer = false;
    });

    if (_remainingSeconds > 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showNextRound();
        }
      });
    } else {
      _completeExercise();
    }
  }

  void _completeExercise() {
    _timer.cancel();
    if (_showItemsTimer.isActive) {
      _showItemsTimer.cancel();
    }
    final double accuracy =
        _totalAttempts > 0 ? (_score / _totalAttempts) * 100 : 0;
    widget.onComplete(_score, accuracy);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.exercise.targetColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: widget.exercise.targetColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Kalan Süre: $_remainingSeconds saniye',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.exercise.targetColor,
                ),
              ),
            ],
          ),
        ),
        if (_isShowingItems)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.exercise.targetColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.remove_red_eye,
                  color: widget.exercise.targetColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hedef Şekil: ${_shapes[_currentTargetIndex]}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.exercise.targetColor,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.exercise.radius * 2.2,
                height: widget.exercise.radius * 2.2,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.exercise.targetColor.withOpacity(0.2),
                  ),
                ),
              ),
              if (_isShowingItems)
                ...List.generate(widget.exercise.itemCount, (index) {
                  return Positioned(
                    left: widget.exercise.radius + _itemPositions[index].dx,
                    top: widget.exercise.radius + _itemPositions[index].dy,
                    child: GestureDetector(
                      onTap: () => _handleAnswer(index),
                      child: Container(
                        width: widget.exercise.itemSize,
                        height: widget.exercise.itemSize,
                        alignment: Alignment.center,
                        child: Text(
                          _shapes[index % _shapes.length],
                          style: TextStyle(
                            fontSize: widget.exercise.itemSize * 0.8,
                            color: widget.exercise.targetColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.exercise.targetColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!_isShowingItems && _canAnswer)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: List.generate(_shapes.length, (index) {
                    return GestureDetector(
                      onTap: () => _handleAnswer(index),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.exercise.targetColor.withOpacity(0.2),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _shapes[index],
                          style: TextStyle(
                            fontSize: 30,
                            color: widget.exercise.targetColor,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: widget.exercise.targetColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.score,
                        color: widget.exercise.targetColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Skor: $_score / $_totalAttempts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.exercise.targetColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
