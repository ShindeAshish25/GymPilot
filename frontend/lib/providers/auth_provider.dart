import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/auth_repository.dart';
import '../data/models/gym_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  GymModel? _gym;
  String? _token;
  bool _isLoading = false;

  GymModel? get gym => _gym;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  /// Returns gym data as a map for backward compatibility with existing UI screens.
  Map<String, dynamic>? get userProfile => _gym?.toJson();

  // ── Session Management ─────────────────────────────────────────────────────

  /// Restores session from SharedPreferences. Call this in main.dart.
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final gymJson = prefs.getString('gym_data');
    if (gymJson != null) {
      try {
        _gym = GymModel.fromJson(jsonDecode(gymJson));
      } catch (e) {
        debugPrint('Error decoding gym data: $e');
      }
    }
    notifyListeners();
  }

  /// Alias for restoreSession for backward compatibility with main.dart.
  Future<void> checkAuthStatus() => restoreSession();

  Future<void> _persistSession(String token, GymModel gym) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('gym_data', jsonEncode(gym.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('gym_data');
  }

  // ── Authentication Actions ────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repository.login(email, password);
      _token = response['token'];
      final gymData = response['gym'];
      
      if (gymData != null && gymData is Map<String, dynamic>) {
        try {
          _gym = GymModel.fromJson(gymData);
        } catch (e) {
          debugPrint('AuthProvider: Error parsing gym data: $e');
          _gym = null;
        }
      } else {
        debugPrint('AuthProvider: WARNING: gym data is missing or not a Map: $gymData');
        _gym = null;
      }

      if (_token != null && _gym != null) {
        await _persistSession(_token!, _gym!);
        return true;
      } else if (_token != null) {
        debugPrint('AuthProvider: Login partially successful (token present, gym missing)');
        // We still allow login if token is there, but features might be limited
        return true; 
      }
      
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(Map<String, String> fields, Uint8List logoBytes, String logoName) async {
    return register(fields, logoBytes, logoName);
  }

  Future<bool> register(Map<String, String> fields, Uint8List logoBytes, String logoName) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repository.registerGym(fields, logoBytes, logoName);
      _token = response['token'];
      _gym = GymModel.fromJson(response['gym']);
      await _persistSession(_token!, _gym!);
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
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
      await _repository.logout();
    } catch (e) {
      debugPrint('Server logout error: $e');
    } finally {
      _token = null;
      _gym = null;
      await _clearSession();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Profile & Info ───────────────────────────────────────────────────────

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _repository.getProfile();
      _gym = GymModel.fromJson(data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gym_data', jsonEncode(_gym!.toJson()));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedData = await _repository.updateProfile(data);
      _gym = GymModel.fromJson(updatedData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gym_data', jsonEncode(_gym!.toJson()));
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
      final updatedData = await _repository.updateGymInfo(gymName, logoBytes, fileName);
      _gym = GymModel.fromJson(updatedData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gym_data', jsonEncode(_gym!.toJson()));
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
      final result = await _repository.updateMembership(months);
      // Backend returns updated gym object usually, but if it only returns planEndDate:
      if (result.containsKey('planEndDate')) {
        final currentJson = _gym?.toJson() ?? {};
        currentJson['planEndDate'] = result['planEndDate'];
        _gym = GymModel.fromJson(currentJson);
      }
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── OTP & Password ───────────────────────────────────────────────────────

  Future<void> sendOtp(String email) async {
    //TODO Not handle Success
    await _repository.sendOtp(email);
  }

  Future<bool> verifyOtp(String email, String otp) async {
    return await _repository.verifyOtp(email, otp);
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    await _repository.resetPassword(email, otp, newPassword);
  }
}