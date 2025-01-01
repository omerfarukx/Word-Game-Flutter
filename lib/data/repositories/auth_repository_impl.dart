import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  static const String _userKey = 'current_user';

  AuthRepositoryImpl(this._secureStorage, this._prefs)
      : _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name:
            firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? '',
        lastLoginDate: DateTime.now(),
      );
    } catch (e) {
      print('getCurrentUser error: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return _firebaseAuth.currentUser != null;
    } catch (e) {
      print('isLoggedIn error: $e');
      return false;
    }
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email ve şifre alanları boş bırakılamaz');
      }

      await _firebaseAuth.setPersistence(firebase_auth.Persistence.LOCAL);

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Giriş başarısız oldu. Lütfen tekrar deneyin.');
      }

      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? email.split('@')[0],
        lastLoginDate: DateTime.now(),
      );

      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Bu email adresi ile kayıtlı kullanıcı bulunamadı');
        case 'wrong-password':
          throw Exception('Hatalı şifre girdiniz');
        case 'invalid-email':
          throw Exception('Geçersiz email formatı');
        case 'user-disabled':
          throw Exception('Bu hesap devre dışı bırakılmış');
        case 'too-many-requests':
          throw Exception(
              'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin');
        default:
          throw Exception(
              'Giriş yapılırken bir hata oluştu: ${e.message ?? 'Bilinmeyen hata'}');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception(
          'Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _prefs.remove(_userKey);
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Çıkış yapılırken bir hata oluştu');
    }
  }

  @override
  Future<User> register(String email, String password, String name) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw Exception('Tüm alanların doldurulması zorunludur');
      }

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Kayıt işlemi başarısız oldu. Lütfen tekrar deneyin.');
      }

      await firebaseUser.updateDisplayName(name);

      // Kayıt sonrası otomatik oturumu kapat
      await _firebaseAuth.signOut();

      final user = User(
        id: firebaseUser.uid,
        email: email,
        name: name,
        lastLoginDate: DateTime.now(),
      );

      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'weak-password':
          throw Exception('Şifre çok zayıf. En az 6 karakter kullanın');
        case 'email-already-in-use':
          throw Exception('Bu email adresi zaten kullanımda');
        case 'invalid-email':
          throw Exception('Geçersiz email formatı');
        case 'operation-not-allowed':
          throw Exception('Email/şifre girişi devre dışı bırakılmış');
        default:
          throw Exception(
              'Kayıt olurken bir hata oluştu: ${e.message ?? 'Bilinmeyen hata'}');
      }
    } catch (e) {
      print('Register error: $e');
      throw Exception(
          'Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(user.name);
      }
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      print('UpdateUser error: $e');
      throw Exception('Kullanıcı bilgileri güncellenirken bir hata oluştu');
    }
  }
}
