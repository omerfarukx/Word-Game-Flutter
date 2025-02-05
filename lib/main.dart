import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/di/service_locator.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'features/exercises/eye_focus/screens/eye_focus_list_screen.dart';
import 'presentation/screens/exercises/speed_reading_screen.dart';
import 'presentation/screens/exercises/word_pairs_screen.dart';
import 'presentation/screens/exercises/letter_search_screen.dart';
import 'presentation/screens/exercises/speed_reading_exercise_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/providers/speed_reading_provider.dart';
import 'features/exercises/word_recognition/screens/word_recognition_list_screen.dart';
import 'features/exercises/peripheral_vision/screens/peripheral_vision_list_screen.dart';
import 'features/word_focus/screens/word_focus_list_screen.dart';
import 'features/word_focus/screens/word_search_screen.dart';
import 'features/statistics/providers/statistics_provider.dart';
import 'features/statistics/screens/statistics_screen.dart';
import 'features/word_chain/screens/word_chain_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCrY4cxxq2Of-gY7_OsIiQXyL9v2IJSXRE",
        authDomain: "word-game-c4a49.firebaseapp.com",
        projectId: "word-game-c4a49",
        storageBucket: "word-game-c4a49.appspot.com",
        messagingSenderId: "837489322530",
        appId: "1:837489322530:web:YOUR_WEB_APP_ID",
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCrY4cxxq2Of-gY7_OsIiQXyL9v2IJSXRE",
        appId: "1:837489322530:android:941aa85c54b5c2a470387b",
        messagingSenderId: "837489322530",
        projectId: "word-game-c4a49",
        storageBucket: "word-game-c4a49.firebasestorage.app",
      ),
    );
  }

  await setupServiceLocator();
  await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => getIt<AuthProvider>(),
        ),
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
        initialRoute: RouteConstants.login,
        routes: {
          RouteConstants.login: (context) => const LoginScreen(),
          RouteConstants.register: (context) => const RegisterScreen(),
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
