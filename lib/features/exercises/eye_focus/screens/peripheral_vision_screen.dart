import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class PeripheralVisionScreen extends StatefulWidget {
  final String difficulty;
  final int duration;

  const PeripheralVisionScreen({
    Key? key,
    required this.difficulty,
    required this.duration,
  }) : super(key: key);

  @override
  State<PeripheralVisionScreen> createState() => _PeripheralVisionScreenState();
}

class _PeripheralVisionScreenState extends State<PeripheralVisionScreen>
    with SingleTickerProviderStateMixin {
  late Timer timer;
  int remainingTime = 0;
  bool isExerciseStarted = false;
  List<Color> shapeColors = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.duration;
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _pulseController.forward();
        }
      });
    _pulseController.forward();
  }

  @override
  void dispose() {
    if (isExerciseStarted) {
      timer.cancel();
    }
    _pulseController.dispose();
    super.dispose();
  }

  List<Offset> _generateShapePositions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return List.generate(8, (index) {
      final angle = index * (pi / 4);
      final radius = screenWidth * 0.35;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;
      return Offset(x, y);
    });
  }

  void _startExercise() {
    setState(() {
      shapeColors = List.generate(8, (index) => Colors.blue);
      isExerciseStarted = true;
      _changeRandomShapeColor();
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
          int yellowIndex = shapeColors.indexOf(Colors.yellow);
          if (yellowIndex != -1) {
            shapeColors[yellowIndex] = Colors.blue;
          }
          _changeRandomShapeColor();
        } else {
          timer.cancel();
          _showCompletionDialog();
        }
      });
    });
  }

  void _changeRandomShapeColor() {
    final random = Random();
    int index;
    do {
      index = random.nextInt(8);
    } while (shapeColors[index] == Colors.yellow);

    setState(() {
      shapeColors[index] = Colors.yellow;
    });
  }

  void _onShapeTap(int index) {
    if (!isExerciseStarted) return;

    if (shapeColors[index] == Colors.yellow) {
      setState(() {
        shapeColors[index] = Colors.blue;
      });
      _changeRandomShapeColor();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Egzersiz Tamamlandı!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Zorluk: ${widget.difficulty}',
              style: TextStyle(
                fontSize: 18,
                color: _getDifficultyColor(),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                remainingTime = widget.duration;
                isExerciseStarted = false;
              });
            },
            child: const Text('Tekrar Başla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Çıkış'),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty.toUpperCase()) {
      case 'EASY':
        return Colors.green;
      case 'MEDIUM':
        return Colors.blue;
      case 'HARD':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double _getShapeSize() {
    switch (widget.difficulty.toUpperCase()) {
      case 'EASY':
        return 40.0;
      case 'MEDIUM':
        return 30.0;
      case 'HARD':
        return 20.0;
      default:
        return 30.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shapePositions = _generateShapePositions(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.difficulty} Çevresel Görüş'),
        actions: [
          if (isExerciseStarted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '$remainingTime s',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A2B3C),
              const Color(0xFF2C3E50),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isExerciseStarted) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 64,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${widget.difficulty} Çevresel Görüş',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Egzersiz Bilgileri',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.timer,
                                  title: 'Süre',
                                  value: '${widget.duration} saniye',
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  icon: Icons.speed,
                                  title: 'Zorluk',
                                  value: widget.difficulty,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  icon: Icons.stars,
                                  title: 'Puan',
                                  value: widget.difficulty == 'EASY'
                                      ? '10 puan'
                                      : widget.difficulty == 'MEDIUM'
                                          ? '20 puan'
                                          : '30 puan',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Nasıl Oynanır?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '1. Ortadaki kırmızı noktaya odaklanın\n'
                                  '2. Gözünüzü kırmızı noktadan ayırmadan çevredeki mavi noktaları fark etmeye çalışın\n'
                                  '3. Sarı renge dönen noktaları hızlıca tıklayın\n'
                                  '4. Her doğru tıklama için puan kazanırsınız',
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: Color(0xFF7F8C8D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _startExercise,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: Colors.blue.withOpacity(0.5),
                            ),
                            child: const Text(
                              'BAŞLA',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(
                      shapePositions.length,
                      (index) => Transform.translate(
                        offset: shapePositions[index],
                        child: GestureDetector(
                          onTap: () => _onShapeTap(index),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: _getShapeSize() * 1.5,
                            height: _getShapeSize() * 1.5,
                            alignment: Alignment.center,
                            child: Container(
                              width: _getShapeSize(),
                              height: _getShapeSize(),
                              decoration: BoxDecoration(
                                color: shapeColors[index],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: shapeColors[index] == Colors.yellow
                                        ? Colors.yellow.withOpacity(0.3)
                                        : Colors.blue.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2C3E50),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
