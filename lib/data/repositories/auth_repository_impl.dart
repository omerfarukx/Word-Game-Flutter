import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';

  AuthRepositoryImpl(this._secureStorage, this._prefs);

  @override
  Future<User?> getCurrentUser() async {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null;
  }

  @override
  Future<User> login(String email, String password) async {
    // TODO: Gerçek bir API ile değiştirilecek
    // Şimdilik mock bir kullanıcı döndürüyoruz
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email ve şifre boş olamaz');
    }

    final user = User(
      id: _uuid.v4(),
      email: email,
      name: email.split('@')[0],
      lastLoginDate: DateTime.now(),
    );

    // Token oluştur ve sakla
    final token = _uuid.v4();
    await _secureStorage.write(key: _tokenKey, value: token);

    // Kullanıcı bilgilerini sakla
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));

    return user;
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _prefs.remove(_userKey);
  }

  @override
  Future<User> register(String email, String password, String name) async {
    // TODO: Gerçek bir API ile değiştirilecek
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('Tüm alanlar doldurulmalıdır');
    }

    final user = User(
      id: _uuid.v4(),
      email: email,
      name: name,
      lastLoginDate: DateTime.now(),
    );

    // Token oluştur ve sakla
    final token = _uuid.v4();
    await _secureStorage.write(key: _tokenKey, value: token);

    // Kullanıcı bilgilerini sakla
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));

    return user;
  }

  @override
  Future<void> updateUser(User user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
