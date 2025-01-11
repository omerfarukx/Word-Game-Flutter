import '../entities/user.dart';

abstract class IAuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String name);
  Future<void> logout();
  Future<void> updateUser(User user);
  Future<bool> isLoggedIn();
}
