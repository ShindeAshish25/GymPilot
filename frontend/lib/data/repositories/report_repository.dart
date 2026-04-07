import 'dart:convert';
import '../services/api_service.dart';

class ReportRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getCustomReport(String startDate, String endDate) async {
    final response = await _apiService.get('/reports/custom?startDate=$startDate&endDate=$endDate');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load custom report');
    }
  }
}
