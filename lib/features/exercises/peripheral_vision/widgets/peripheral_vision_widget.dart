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
  int _remainingTime = 60;
  int _score = 0;
  int _totalAttempts = 0;
  bool _isActive = true;
  bool _showFeedback = false;
  bool _isCorrect = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final List<Shape> _shapes = [
    Shape.circle,
    Shape.square,
    Shape.triangle,
    Shape.diamond
  ];
  Shape _selectedShape = Shape.circle;
  List<Shape> _peripheralShapes = [];
  final Random _random = Random();
  double _baseRadius = 120.0;
  double _currentScale = 1.0;
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.white;
  bool _showMessage = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.exercise.durationInSeconds;
    _startTimer();
    _generatePeripheralShapes();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _endExercise();
        }
      });
    });
  }

  void _generatePeripheralShapes() {
    setState(() {
      _peripheralShapes = List.generate(8, (index) {
        return _shapes[_random.nextInt(_shapes.length)];
      });
      _currentScale = 1.0;
    });
  }

  void _checkShape(Shape shape) {
    if (!_isActive) return;

    setState(() {
      _totalAttempts++;
      _isCorrect = shape == _selectedShape;
      if (_isCorrect) {
        _score++;
        _currentScale = 1.2;
        _feedbackMessage = 'Harika! Doğru şekli buldun!';
        _feedbackColor = Colors.green;
      } else {
        _feedbackMessage = 'Tekrar dene, yanlış şekli seçtin.';
        _feedbackColor = Colors.red;
      }
      _showFeedback = true;
      _showMessage = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showMessage = false;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
          _selectedShape = _shapes[_random.nextInt(_shapes.length)];
          _generatePeripheralShapes();
        });
      }
    });
  }

  void _endExercise() {
    _timer.cancel();
    _isActive = false;
    final accuracy = (_score / _totalAttempts) * 100;
    widget.onComplete(_score, accuracy);
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Merkeze odaklanırken çevredeki şekilleri bul',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.exercise.targetColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.exercise.targetColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: widget.exercise.targetColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_remainingTime',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.exercise.targetColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.exercise.targetColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        color: widget.exercise.targetColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_score/$_totalAttempts',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.exercise.targetColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showMessage)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _feedbackMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: _feedbackColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      widget.exercise.targetColor.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.exercise.targetColor.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.exercise.targetColor.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ...List.generate(8, (index) {
                          final angle = (index * pi / 4);
                          final radius = _baseRadius * _currentScale;
                          return Positioned(
                            left: 150 + radius * cos(angle),
                            top: 150 + radius * sin(angle),
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 300),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _checkShape(_peripheralShapes[index]),
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.exercise.targetColor
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: _showFeedback ? 4 : 0,
                                          ),
                                        ],
                                      ),
                                      child: ShapeWidget(
                                        shape: _peripheralShapes[index],
                                        color: widget.exercise.targetColor
                                            .withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.exercise.targetColor
                                      .withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ShapeWidget(
                              shape: _selectedShape,
                              color: widget.exercise.targetColor,
                              size: 35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.exercise.targetColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_red_eye,
                    color: widget.exercise.targetColor.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Merkeze odaklanmayı unutma!',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.exercise.targetColor.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShapeWidget extends StatelessWidget {
  final Shape shape;
  final Color color;
  final double size;

  const ShapeWidget({
    Key? key,
    required this.shape,
    required this.color,
    this.size = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        size: Size(size, size),
        painter: ShapePainter(shape: shape, color: color),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final Shape shape;
  final Color color;

  ShapePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    switch (shape) {
      case Shape.circle:
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.width / 2,
          paint,
        );
        break;
      case Shape.square:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          paint,
        );
        break;
      case Shape.triangle:
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case Shape.diamond:
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(0, size.height / 2)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum Shape { circle, square, triangle, diamond }
