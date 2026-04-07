import 'package:flutter/foundation.dart';
import '../data/repositories/report_repository.dart';

class ReportProvider with ChangeNotifier {
  final ReportRepository _repository = ReportRepository();
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;

  Map<String, dynamic>? get reportData => _reportData;
  bool get isLoading => _isLoading;

  Future<void> fetchCustomReport(String startDate, String endDate) async {
    _isLoading = true;
    notifyListeners();
    try {
      _reportData = await _repository.getCustomReport(startDate, endDate);
    } catch (e) {
      debugPrint('Error fetching custom report: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
