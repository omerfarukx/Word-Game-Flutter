import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/providers/auth_provider.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  // Register instances
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Repositories
  getIt.registerSingleton<IAuthRepository>(
    AuthRepositoryImpl(secureStorage, prefs),
  );

  // Providers
  getIt.registerSingleton<AuthProvider>(
    AuthProvider(getIt<IAuthRepository>()),
  );
}
