import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/constants/theme_constants.dart';
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
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: ThemeConstants.darkTheme,
            darkTheme: ThemeConstants.darkTheme,
            themeMode: ThemeMode.dark,
            home: StreamBuilder<firebase_auth.User?>(
              stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Oturum durumunu kontrol et
                final isLoggedIn = snapshot.hasData;
                if (isLoggedIn) {
                  return const HomeScreen();
                }
                return const LoginScreen();
              },
            ),
            routes: {
              RouteConstants.login: (context) => const LoginScreen(),
              RouteConstants.register: (context) => const RegisterScreen(),
              RouteConstants.home: (context) => const HomeScreen(),
              RouteConstants.eyeFocus: (context) => const EyeFocusListScreen(),
              RouteConstants.speedReading: (context) =>
                  const SpeedReadingScreen(),
              RouteConstants.wordPairs: (context) => const WordPairsScreen(),
              RouteConstants.letterSearch: (context) =>
                  const LetterSearchScreen(),
              RouteConstants.speedReadingExercise: (context) =>
                  const SpeedReadingExerciseScreen(),
              RouteConstants.wordRecognition: (context) =>
                  const WordRecognitionListScreen(),
              RouteConstants.peripheralVision: (context) =>
                  const PeripheralVisionListScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    ),
  );
}
