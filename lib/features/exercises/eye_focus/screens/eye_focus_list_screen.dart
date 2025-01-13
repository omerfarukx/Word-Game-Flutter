import 'package:flutter/material.dart';
import '../models/eye_focus_exercise.dart';
import 'schultz_table_screen.dart';
import 'peripheral_vision_screen.dart';

class EyeFocusListScreen extends StatelessWidget {
  const EyeFocusListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Göz Odaklama Egzersizleri'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildExerciseCard(
                context,
                title: 'Schultz Tablosu',
                description: 'Sayıları sırayla bulun',
                color: Colors.orange,
                icon: Icons.grid_on,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SchultzTableScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildExerciseCard(
                context,
                title: 'Temel Çevresel Görüş',
                description:
                    'Merkeze odaklanırken çevredeki büyük şekilleri fark edin.',
                color: Colors.green,
                icon: Icons.visibility,
                difficulty: 'EASY',
                duration: '60 saniye',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PeripheralVisionScreen(
                        difficulty: 'EASY',
                        duration: 60,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildExerciseCard(
                context,
                title: 'Orta Seviye Çevresel Görüş',
                description:
                    'Merkeze odaklanırken çevredeki orta boy şekilleri fark edin.',
                color: Colors.blue,
                icon: Icons.visibility,
                difficulty: 'MEDIUM',
                duration: '90 saniye',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PeripheralVisionScreen(
                        difficulty: 'MEDIUM',
                        duration: 90,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildExerciseCard(
                context,
                title: 'İleri Seviye Çevresel Görüş',
                description:
                    'Merkeze odaklanırken çevredeki küçük şekilleri fark edin.',
                color: Colors.red,
                icon: Icons.visibility,
                difficulty: 'HARD',
                duration: '120 saniye',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PeripheralVisionScreen(
                        difficulty: 'HARD',
                        duration: 120,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    String? difficulty,
    String? duration,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (difficulty != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        difficulty,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(color: Colors.white),
                softWrap: true,
              ),
              if (duration != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                  child: const Text(
                    'BAŞLA',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
