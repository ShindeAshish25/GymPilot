import 'dart:convert';
import 'dart:typed_data';
import '../services/api_service.dart';
import '../../core/utils/exceptions.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<String> login(String email, String password) async {
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      final error = json.decode(response.body);
      throw ServerException(error['msg'] ?? 'Failed to login');
    }
  }

  Future<String> registerGym(Map<String, String> fields, Uint8List bytes, String fileName) async {
    final response = await _apiService.postMultipart('/auth/register-gym', fields, bytes, fileName, 'gymLogo');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      final error = json.decode(response.body);
      throw ServerException(error['msg'] ?? 'Failed to register gym');
    }
  }

  Future<void> sendOtp(String email) async {
    final response = await _apiService.post('/auth/send-otp', {'email': email});
    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw ServerException(error['message'] ?? 'Failed to send OTP');
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    final response = await _apiService.post('/auth/verify-otp', {'email': email, 'otp': otp});
    if (response.statusCode == 200) {
      return true;
    } else {
      final error = json.decode(response.body);
      throw ServerException(error['message'] ?? 'Invalid or expired OTP');
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    final response = await _apiService.post('/auth/reset-password', {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw ServerException(error['msg'] ?? error['message'] ?? 'Failed to reset password');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiService.get('/gym/profile');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw ServerException(error['msg'] ?? 'Failed to fetch profile');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiService.put('/gym/profile', data);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw ServerException(error['msg'] ?? 'Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> updateGymInfo(String? gymName, Uint8List? logoBytes, String? fileName) async {
    if (logoBytes != null && fileName != null) {
      final fields = gymName != null ? {'gymName': gymName} : <String, String>{};
      final response = await _apiService.putMultipart('/gym/info', fields, logoBytes, fileName, 'logo');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw ServerException(error['msg'] ?? 'Failed to update gym info');
      }
    } else {
      final response = await _apiService.put('/gym/info', {'gymName': gymName});
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw ServerException(error['msg'] ?? 'Failed to update gym info');
      }
    }
  }

  Future<Map<String, dynamic>> updateMembership(int months) async {
    final response = await _apiService.put('/gym/membership', {'months': months});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw ServerException(error['msg'] ?? 'Failed to update membership');
    }
  }

  Future<void> logout() async {
    final response = await _apiService.post('/auth/logout', {});
    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw ServerException(error['msg'] ?? 'Logout failed on server');
    }
  }
}
