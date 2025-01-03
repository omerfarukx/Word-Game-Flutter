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
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/exercises/eye_focus_screen.dart';
import 'presentation/screens/exercises/speed_reading_screen.dart';
import 'presentation/screens/exercises/word_pairs_screen.dart';
import 'presentation/screens/exercises/letter_search_screen.dart';
import 'presentation/screens/exercises/speed_reading_exercise_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/providers/speed_reading_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase oturum kalıcılığını ayarla
  await firebase_auth.FirebaseAuth.instance
      .setPersistence(firebase_auth.Persistence.LOCAL);

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
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => SpeedReadingProvider()..initialize(),
        ),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: ThemeConstants.lightTheme,
            darkTheme: ThemeConstants.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
              RouteConstants.eyeFocus: (context) => const EyeFocusScreen(),
              RouteConstants.speedReading: (context) =>
                  const SpeedReadingScreen(),
              RouteConstants.wordPairs: (context) => const WordPairsScreen(),
              RouteConstants.letterSearch: (context) =>
                  const LetterSearchScreen(),
              RouteConstants.speedReadingExercise: (context) =>
                  const SpeedReadingExerciseScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    ),
  );
}
