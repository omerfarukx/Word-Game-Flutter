import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../providers/auth_provider.dart';

class CategoryInfo {
  final String name;
  final Color color;
  final IconData icon;

  const CategoryInfo({
    required this.name,
    required this.color,
    required this.icon,
  });
}

class Exercise {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final String category;

  Exercise({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.category,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Map<String, CategoryInfo> get categoryInfo => {
        'Kelime Egzersizleri': CategoryInfo(
          name: 'Kelime Egzersizleri',
          color: const Color(0xFF8B5CF6),
          icon: Icons.text_fields,
        ),
        'Görsel Egzersizler': CategoryInfo(
          name: 'Görsel Egzersizler',
          color: const Color(0xFF3B82F6),
          icon: Icons.visibility,
        ),
        'Okuma Egzersizleri': CategoryInfo(
          name: 'Okuma Egzersizleri',
          color: const Color(0xFFF59E0B),
          icon: Icons.menu_book,
        ),
      };

  List<Exercise> get exercises => [
        Exercise(
          title: 'Kelime Çiftleri',
          subtitle: 'Aynı olmayan kelime çiftlerini bulun',
          icon: Icons.compare_arrows,
          route: RouteConstants.wordPairs,
          category: 'Kelime Egzersizleri',
        ),
        Exercise(
          title: 'Kelime Tanıma',
          subtitle: 'Kelime tanıma hızınızı artırın',
          icon: Icons.flash_on,
          route: RouteConstants.wordRecognition,
          category: 'Kelime Egzersizleri',
        ),
        Exercise(
          title: 'Kelime Odağı',
          subtitle: 'Kelimeler arasındaki ilişkileri keşfedin',
          icon: Icons.psychology,
          route: RouteConstants.wordFocus,
          category: 'Kelime Egzersizleri',
        ),
        Exercise(
          title: 'Kelime Bulma',
          subtitle: 'Gizli kelimeleri bulun',
          icon: Icons.grid_on,
          route: RouteConstants.wordSearch,
          category: 'Kelime Egzersizleri',
        ),
        Exercise(
          title: 'Harf Arama',
          subtitle: 'Harfleri bulun ve seçin',
          icon: Icons.search,
          route: RouteConstants.letterSearch,
          category: 'Görsel Egzersizler',
        ),
        Exercise(
          title: 'Göz Odaklama',
          subtitle: 'Göz kaslarınızı güçlendirin',
          icon: Icons.remove_red_eye,
          route: RouteConstants.eyeFocus,
          category: 'Görsel Egzersizler',
        ),
        Exercise(
          title: 'Çevresel Görüş',
          subtitle: 'Merkeze odaklanırken çevreyi fark edin',
          icon: Icons.visibility,
          route: RouteConstants.peripheralVision,
          category: 'Görsel Egzersizler',
        ),
        Exercise(
          title: 'Hızlı Okuma',
          subtitle: 'Okuma hızınızı artırın',
          icon: Icons.speed,
          route: RouteConstants.speedReadingExercise,
          category: 'Okuma Egzersizleri',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = true;
    final categories = exercises.map((e) => e.category).toSet().toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F2937), Color(0xFF111827)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: const Color(0xFF1F2937),
                elevation: 0,
                title: const Text(
                  'Hızlı Okuma',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      try {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                              context, RouteConstants.login);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(context, isDark),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      final info = categoryInfo[category]!;
                      return _buildCategorySection(
                        context,
                        info,
                        exercises.where((e) => e.category == category).toList(),
                        isDark,
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildStatisticsCard(context, isDark),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0EA5E9),
            Color(0xFF0284C7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoş Geldin!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Bugün kendini geliştirmeye hazır mısın?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '3 Günlük Seri!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    CategoryInfo info,
    List<Exercise> categoryExercises,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  info.icon,
                  color: info.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                info.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE5E7EB),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.95,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categoryExercises.length,
          itemBuilder: (context, index) {
            final exercise = categoryExercises[index];
            return _buildExerciseCard(
              context,
              exercise.title,
              exercise.subtitle,
              exercise.icon,
              exercise.route,
              info.color,
              isDark,
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
    Color color,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF9FAFB),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD1D5DB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GÜNLÜK İLERLEME',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade300,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Okuma Düzeyi',
                  'Şampiyon',
                  Icons.emoji_events,
                  Colors.amber,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Egzersiz',
                  '24 Tamamlandı',
                  Icons.check_circle,
                  Colors.green,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Süre',
                  '2.5 Saat',
                  Icons.timer,
                  Colors.blue,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Seri',
                  '3 Gün',
                  Icons.local_fire_department,
                  Colors.orange,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF9FAFB),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFD1D5DB),
            ),
          ),
        ],
      ),
    );
  }
}
