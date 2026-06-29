import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/design/app_theme.dart';
import 'core/feedback/achievements.dart';
import 'core/feedback/music_service.dart';
import 'core/feedback/records.dart';
import 'core/feedback/sound_service.dart';
import 'core/words/word_service.dart';
import 'features/exercises/eye_focus/screens/eye_focus_screen.dart';
import 'features/exercises/speed_reading/screens/speed_reading_screen.dart';
import 'features/exercises/word_pairs/screens/word_pairs_screen.dart';
import 'features/exercises/letter_search/screens/letter_search_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/exercises/word_recognition/screens/word_recognition_screen.dart';
import 'features/exercises/peripheral_vision/screens/peripheral_vision_screen.dart';
import 'features/word_focus/screens/word_focus_screen.dart';
import 'features/word_focus/screens/word_search_screen.dart';
import 'features/statistics/providers/statistics_provider.dart';
import 'features/statistics/screens/statistics_screen.dart';
import 'features/word_chain/screens/word_chain_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await WordService.load();
  await SoundService.instance.load();
  await MusicService.instance.init();
  await Records.instance.init();
  await Achievements.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StatisticsProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.dark,
        initialRoute: RouteConstants.home,
        routes: {
          RouteConstants.home: (context) => const HomeScreen(),
          RouteConstants.eyeFocus: (context) => const EyeFocusScreen(),
          RouteConstants.speedReading: (context) => const SpeedReadingScreen(),
          RouteConstants.wordPairs: (context) => const WordPairsScreen(),
          RouteConstants.letterSearch: (context) => const LetterSearchScreen(),
          RouteConstants.speedReadingExercise: (context) =>
              const SpeedReadingScreen(),
          RouteConstants.wordRecognition: (context) =>
              const WordRecognitionScreen(),
          RouteConstants.peripheralVision: (context) =>
              const PeripheralVisionScreen(),
          RouteConstants.wordFocus: (context) => const WordFocusScreen(),
          RouteConstants.wordSearch: (context) => const WordSearchScreen(),
          RouteConstants.statistics: (context) => const StatisticsScreen(),
          RouteConstants.wordChain: (context) => const WordChainScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}


