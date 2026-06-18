import 'package:flutter/material.dart';
import '../data/models/inquiry_model.dart';
import '../data/services/inquiry_service.dart';

class InquiryProvider with ChangeNotifier {
  final InquiryService _service = InquiryService();
  List<InquiryModel> _inquiries = [];
  bool _isLoading = false;

  List<InquiryModel> get inquiries => _inquiries;
  bool get isLoading => _isLoading;

  Future<void> fetchInquiries() async {
    _isLoading = true;
    notifyListeners();
    try {
      _inquiries = await _service.getInquiries();
    } catch (e) {
      debugPrint('Error fetching inquiries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addInquiry(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _service.addInquiry(data);
      if (success) {
        await fetchInquiries();
      }
      return success;
    } catch (e) {
      debugPrint('Error adding inquiry: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    try {
      final success = await _service.updateInquiryStatus(id, status);
      if (success) {
        await fetchInquiries();
      }
      return success;
    } catch (e) {
      debugPrint('Error updating inquiry status: $e');
      return false;
    }
  }

  Future<bool> deleteInquiry(String id) async {
    try {
      final success = await _service.deleteInquiry(id);
      if (success) {
        _inquiries.removeWhere((i) => i.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting inquiry: $e');
      return false;
    }
  }
}
