import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/data/services/api_service.dart';

class MemberRepository {
  final ApiService _apiService = ApiService();

  Future<List<MemberModel>> getMembers() async {
    final response = await _apiService.get('/members');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List membersList = data['members'] ?? [];
      return membersList.map((json) => MemberModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load members');
    }
  }

  Future<List<MemberModel>> getExpiringMembers() async {
    final response = await _apiService.get('/members/expiring/list');
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => MemberModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expiring members');
    }
  }

  Future<MemberModel> addMember(Map<String, dynamic> memberData, {Uint8List? imageBytes, String? imageName}) async {
    http.Response response;
    
    if (imageBytes != null && imageName != null) {
      // Create map of strings for multipart fields
      final Map<String, String> stringFields = memberData.map((key, value) => MapEntry(key, value.toString()));
      response = await _apiService.postMultipart('/members/add', stringFields, imageBytes, imageName, 'photo');
    } else {
      response = await _apiService.post('/members/add', memberData);
    }

    if (response.statusCode == 200) {
      return MemberModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add member');
    }
  }

  Future<void> updateMember(String id, Map<String, dynamic> memberData) async {
    final response = await _apiService.put('/members/update/$id', memberData);
    if (response.statusCode != 200) {
      throw Exception('Failed to update member');
    }
  }

  Future<void> deleteMember(String id) async {
    final response = await _apiService.delete('/members/delete/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete member');
    }
  }
}
