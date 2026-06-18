import 'dart:convert';
import '../models/inquiry_model.dart';
import 'api_service.dart';

class InquiryService {
  final ApiService _api = ApiService();

  Future<List<InquiryModel>> getInquiries() async {
    final response = await _api.get('/inquiries');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> inquiriesJson = data['data'];
      return inquiriesJson.map((json) => InquiryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inquiries');
    }
  }

  Future<bool> addInquiry(Map<String, dynamic> data) async {
    final response = await _api.post('/inquiries/add', data);
    return response.statusCode == 201;
  }

  Future<bool> updateInquiryStatus(String id, String status) async {
    final response = await _api.put('/inquiries/update/$id', {'status': status});
    return response.statusCode == 200;
  }

  Future<bool> deleteInquiry(String id) async {
    final response = await _api.delete('/inquiries/delete/$id');
    return response.statusCode == 200;
  }
}
