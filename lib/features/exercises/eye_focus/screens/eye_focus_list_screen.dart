import 'package:flutter/material.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/theme_constants.dart';

class EyeFocusListScreen extends StatelessWidget {
  const EyeFocusListScreen({Key? key}) : super(key: key);

  Widget _buildExerciseCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String route,
    List<Color> gradientColors,
  ) {
    return Card(
      elevation: 8,
      shadowColor: gradientColors[1].withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
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
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
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
                    mainAxisSize: MainAxisSize.min,
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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Göz Odaklama Egzersizleri'),
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
                  'Schultz Tablosu',
                  'Sayıları sırayla bulun',
                  Icons.grid_on,
                  RouteConstants.eyeFocus,
                  [
                    Colors.orange.shade300,
                    Colors.orange.shade500,
                    Colors.orange.shade700
                  ],
                ),
                const SizedBox(height: 12),
                _buildExerciseCard(
                  context,
                  'Çevresel Görüş',
                  'Merkeze odaklanırken çevreyi fark edin',
                  Icons.visibility,
                  RouteConstants.peripheralVision,
                  [
                    Colors.purple.shade300,
                    Colors.purple.shade500,
                    Colors.purple.shade700
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
