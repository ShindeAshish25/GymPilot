import 'dart:convert';
import '../models/dashboard_stats_model.dart';
import '../services/api_service.dart';

class DashboardRepository {
  final ApiService _apiService = ApiService();

  Future<DashboardStatsModel> getStats() async {
    final response = await _apiService.get('/dashboard/stats');
    if (response.statusCode == 200) {
      return DashboardStatsModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  Future<List<ChartDataPoint>> getChartData(String type, String filter) async {
    final response = await _apiService.get('/dashboard/charts?type=$type&filter=$filter');
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChartDataPoint.fromJson(json, type)).toList();
    } else {
      throw Exception('Failed to load chart data');
    }
  }
}
