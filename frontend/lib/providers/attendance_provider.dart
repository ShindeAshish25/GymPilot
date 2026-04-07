import 'package:flutter/foundation.dart';
import '../data/services/api_service.dart';

class AttendanceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> checkIn(String memberId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final String formattedTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      final response = await _apiService.post('/attendance/checkin', {
        'memberId': memberId,
        'checkInDate': now.toIso8601String(),
        'checkInTime': formattedTime,
      });

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error marking attendance: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
