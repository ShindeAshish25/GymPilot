import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _userProfile;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get userProfile => _userProfile;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authRepository.login(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      _token = token;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> signup(Map<String, String> fields, Uint8List bytes, String fileName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authRepository.registerGym(fields, bytes, fileName);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      _token = token;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _token = null;
      _userProfile = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendOtp(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.sendOtp(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _authRepository.verifyOtp(email, otp);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.resetPassword(email, otp, newPassword);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _authRepository.getProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _authRepository.updateProfile(data);
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateGymInfo(String? gymName, Uint8List? logoBytes, String? fileName) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _authRepository.updateGymInfo(gymName, logoBytes, fileName);
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMembership(int months) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authRepository.updateMembership(months);
      _userProfile?['planEndDate'] = result['planEndDate'];
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
