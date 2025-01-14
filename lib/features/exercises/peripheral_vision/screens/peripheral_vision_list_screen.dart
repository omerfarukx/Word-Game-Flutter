import 'package:flutter/material.dart';
import '../models/peripheral_vision_exercise.dart';
import 'peripheral_vision_screen.dart';
import '../../../../core/constants/theme_constants.dart';

class PeripheralVisionListScreen extends StatelessWidget {
  const PeripheralVisionListScreen({Key? key}) : super(key: key);

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'KOLAY';
      case 2:
        return 'ORTA';
      case 3:
        return 'ZOR';
      default:
        return 'KOLAY';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çevresel Görüş Egzersizleri'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                _buildExerciseCard(
                  context,
                  PeripheralVisionExercise.basic(),
                  [
                    Colors.green.shade300,
                    Colors.green.shade500,
                    Colors.green.shade700,
                  ],
                  Icons.visibility,
                ),
                const SizedBox(height: 12),
                _buildExerciseCard(
                  context,
                  PeripheralVisionExercise.intermediate(),
                  [
                    Colors.blue.shade300,
                    Colors.blue.shade500,
                    Colors.blue.shade700,
                  ],
                  Icons.visibility,
                ),
                const SizedBox(height: 12),
                _buildExerciseCard(
                  context,
                  PeripheralVisionExercise.advanced(),
                  [
                    Colors.red.shade300,
                    Colors.red.shade500,
                    Colors.red.shade700,
                  ],
                  Icons.visibility,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    PeripheralVisionExercise exercise,
    List<Color> gradientColors,
    IconData icon,
  ) {
    return Hero(
      tag: exercise.title,
      child: Card(
        elevation: 8,
        shadowColor: gradientColors[1].withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PeripheralVisionScreen(exercise: exercise),
              ),
            );
          },
          borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(ThemeConstants.cardBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[1].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          size: ThemeConstants.iconSize,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonBorderRadius,
                                ),
                              ),
                              child: Text(
                                _getDifficultyText(exercise.difficulty),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    exercise.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${exercise.durationInSeconds} saniye',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(
                            ThemeConstants.buttonBorderRadius,
                          ),
                        ),
                        child: Row(
                          children: const [
                            Text(
                              'BAŞLA',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
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
