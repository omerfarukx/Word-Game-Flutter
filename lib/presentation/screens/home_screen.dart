import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hızlı Okuma'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, RouteConstants.login);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ÇALIŞMALAR',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            _buildExerciseCard(
              context,
              'Kelime Çiftleri',
              'Aynı olmayan kelime çiftlerini bulun',
              Icons.compare_arrows,
              RouteConstants.wordPairs,
            ),
            _buildExerciseCard(
              context,
              'Harf Arama',
              'Harfleri bulun ve seçin',
              Icons.search,
              RouteConstants.letterSearch,
            ),
            _buildExerciseCard(
              context,
              'Hızlı Okuma',
              'Okuma hızınızı artırın',
              Icons.speed,
              RouteConstants.speedReadingExercise,
            ),
            _buildExerciseCard(
              context,
              'Göz Odaklama',
              'Göz kaslarınızı güçlendirin',
              Icons.remove_red_eye,
              RouteConstants.eyeFocus,
            ),
            const SizedBox(height: 24),
            const Text(
              'İSTATİSTİKLER',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatisticsCard(
              'Okuma düzeyi',
              'Hızlı okuma Şampiyonu',
              Icons.emoji_events,
            ),
            _buildStatisticsCard(
              'Tamamlanan alıştırmalar',
              '308',
              Icons.check_circle,
            ),
            _buildStatisticsCard(
              'Ortalama Hafıza kapasitesi',
              '%73',
              Icons.psychology,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, String title, String subtitle,
      IconData icon, String route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _buildStatisticsCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
