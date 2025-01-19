import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/daily_progress_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      appBar: AppBar(
        title: const Text(
          'İstatistikler',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, statistics, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DailyProgressCard(
                  readingLevel: statistics.readingLevel,
                  completedExercises: statistics.completedExercises,
                  duration: statistics.duration,
                  streakDays: statistics.streakDays,
                ),
                const SizedBox(height: 20),
                // Test için geçici butonlar
                ElevatedButton(
                  onPressed: () {
                    statistics.addExerciseCompletion(0.5);
                    statistics.calculateReadingLevel();
                  },
                  child: const Text('Egzersiz Ekle (+30dk)'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => statistics.resetDailyProgress(),
                  child: const Text('Günlük İlerlemeyi Sıfırla'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
