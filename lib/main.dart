import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'features/exercises/eye_focus/screens/eye_focus_list_screen.dart';
import 'features/exercises/speed_reading/screens/speed_reading_screen.dart';
import 'features/exercises/word_pairs/screens/word_pairs_screen.dart';
import 'features/exercises/letter_search/screens/letter_search_screen.dart';
import 'features/exercises/speed_reading/screens/speed_reading_exercise_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/exercises/speed_reading/providers/speed_reading_provider.dart';
import 'features/exercises/word_recognition/screens/word_recognition_list_screen.dart';
import 'features/exercises/peripheral_vision/screens/peripheral_vision_list_screen.dart';
import 'features/word_focus/screens/word_focus_list_screen.dart';
import 'features/word_focus/screens/word_search_screen.dart';
import 'features/statistics/providers/statistics_provider.dart';
import 'features/statistics/screens/statistics_screen.dart';
import 'features/word_chain/screens/word_chain_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SpeedReadingProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => StatisticsProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF1F2937),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        initialRoute: RouteConstants.home,
        routes: {
          RouteConstants.home: (context) => const HomeScreen(),
          RouteConstants.eyeFocus: (context) => const EyeFocusListScreen(),
          RouteConstants.speedReading: (context) => const SpeedReadingScreen(),
          RouteConstants.wordPairs: (context) => const WordPairsScreen(),
          RouteConstants.letterSearch: (context) => const LetterSearchScreen(),
          RouteConstants.speedReadingExercise: (context) =>
              const SpeedReadingExerciseScreen(),
          RouteConstants.wordRecognition: (context) =>
              const WordRecognitionListScreen(),
          RouteConstants.peripheralVision: (context) =>
              const PeripheralVisionListScreen(),
          RouteConstants.wordFocus: (context) => const WordFocusListScreen(),
          RouteConstants.wordSearch: (context) => const WordSearchScreen(),
          RouteConstants.statistics: (context) => const StatisticsScreen(),
          RouteConstants.wordChain: (context) => const WordChainScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}


