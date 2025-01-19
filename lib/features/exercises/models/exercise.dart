import 'package:flutter/material.dart';
import '../../../core/constants/route_constants.dart';

class Exercise {
  final String title;
  final String description;
  final String route;
  final String category;
  final IconData icon;
  final Color color;

  Exercise({
    required this.title,
    required this.description,
    required this.route,
    required this.category,
    required this.icon,
    required this.color,
  });

  static List<Exercise> get exercises => [
        Exercise(
          title: 'Göz Odaklama',
          description: 'Göz kaslarınızı güçlendirin',
          route: RouteConstants.eyeFocus,
          category: 'Görsel Egzersizler',
          icon: Icons.remove_red_eye,
          color: Colors.blue,
        ),
        Exercise(
          title: 'Hızlı Okuma',
          description: 'Okuma hızınızı artırın',
          route: RouteConstants.speedReading,
          category: 'Okuma Egzersizleri',
          icon: Icons.speed,
          color: Colors.orange,
        ),
        Exercise(
          title: 'Kelime Çiftleri',
          description: 'Kelimeleri eşleştirin',
          route: RouteConstants.wordPairs,
          category: 'Kelime Egzersizleri',
          icon: Icons.compare_arrows,
          color: Colors.purple,
        ),
        Exercise(
          title: 'Harf Arama',
          description: 'Harfleri bulun',
          route: RouteConstants.letterSearch,
          category: 'Kelime Egzersizleri',
          icon: Icons.search,
          color: Colors.green,
        ),
        Exercise(
          title: 'Kelime Tanıma',
          description: 'Kelimeleri hızlıca tanıyın',
          route: RouteConstants.wordRecognition,
          category: 'Kelime Egzersizleri',
          icon: Icons.visibility,
          color: Colors.red,
        ),
        Exercise(
          title: 'Çevresel Görüş',
          description: 'Görüş alanınızı genişletin',
          route: RouteConstants.peripheralVision,
          category: 'Görsel Egzersizler',
          icon: Icons.panorama_fish_eye,
          color: Colors.indigo,
        ),
        Exercise(
          title: 'Kelime Odaklama',
          description: 'Kelimelere odaklanın',
          route: RouteConstants.wordFocus,
          category: 'Kelime Egzersizleri',
          icon: Icons.center_focus_strong,
          color: Colors.amber,
        ),
        Exercise(
          title: 'Kelime Arama',
          description: 'Kelimeleri bulun',
          route: RouteConstants.wordSearch,
          category: 'Kelime Egzersizleri',
          icon: Icons.grid_on,
          color: Colors.cyan,
        ),
        Exercise(
          title: 'Kelime Zinciri',
          description: 'Son harften yeni kelimeler türetin',
          route: RouteConstants.wordChain,
          category: 'Kelime Egzersizleri',
          icon: Icons.link,
          color: Colors.teal,
        ),
      ];
}
