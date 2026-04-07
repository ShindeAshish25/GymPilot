import 'package:flutter/foundation.dart';
import '../data/models/dashboard_stats_model.dart';
import '../data/repositories/dashboard_repository.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  DashboardStatsModel? _stats;
  List<ChartDataPoint> _chartData = [];
  List<ChartDataPoint> _revenueChartData = [];
  List<ChartDataPoint> _joinersChartData = [];
  List<ChartDataPoint> _attendanceChartData = [];
  List<ChartDataPoint> _distributionData = [];
  bool _isLoading = false;
  String _currentFilter = 'month';

  DashboardStatsModel? get stats => _stats;
  List<ChartDataPoint> get chartData => _chartData;
  List<ChartDataPoint> get revenueChartData => _revenueChartData;
  List<ChartDataPoint> get joinersChartData => _joinersChartData;
  List<ChartDataPoint> get attendanceChartData => _attendanceChartData;
  List<ChartDataPoint> get distributionData => _distributionData;
  bool get isLoading => _isLoading;
  String get currentFilter => _currentFilter;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _repository.getStats();
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDistributionData() async {
    try {
      _distributionData = await _repository.getChartData('distribution', 'month');
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching distribution data: $e');
    }
  }

  Future<void> fetchAttendanceData() async {
    try {
      _attendanceChartData = await _repository.getChartData('attendance', 'month');
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching attendance data: $e');
    }
  }

  Future<void> fetchChartData(String type, String filter) async {
    _isLoading = true;
    _currentFilter = filter;
    notifyListeners();

    try {
      final data = await _repository.getChartData(type, filter);
      if (type == 'joiners') {
        _joinersChartData = data;
      } else if (type == 'revenue') {
        _revenueChartData = data;
      } else {
        _chartData = data;
      }
    } catch (e) {
      debugPrint('Error fetching chart data: $e');
      if (type == 'joiners') {
        _joinersChartData = [];
      } else if (type == 'revenue') {
        _revenueChartData = [];
      } else {
        _chartData = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
