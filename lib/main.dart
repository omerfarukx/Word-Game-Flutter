import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  await setupServiceLocator();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => SpeedReadingProvider()..initialize(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: ThemeConstants.lightTheme,
            darkTheme: ThemeConstants.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: RouteConstants.login,
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
