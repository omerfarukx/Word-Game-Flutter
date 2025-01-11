import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._authRepository) {
    _init();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authRepository.getCurrentUser();
    } catch (e) {
      debugPrint('Auth init error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(email, password);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authRepository.register(email, password, name);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.updateUser(user);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
