import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/data/repositories/member_repository.dart';
import 'package:frontend/data/services/api_service.dart';

class MemberProvider with ChangeNotifier {
  final MemberRepository _memberRepository = MemberRepository();
  final ApiService _apiService = ApiService();
  List<MemberModel> _members = [];
  List<MemberModel> _expiringMembers = [];
  bool _isLoading = false;

  List<MemberModel> get members => _members;
  List<MemberModel> get expiringMembers => _expiringMembers;
  bool get isLoading => _isLoading;

  // ── Filtered Accessors ─────────────────────────────────────────

  /// Members expiring in 5 days or less
  List<MemberModel> get expiringSoonMembers =>
      _members.where((m) => m.isExpiringSoon).toList();

  /// Members who expired in the last 10 days
  List<MemberModel> get recentlyOverdueMembers =>
      _members.where((m) => m.isRecentlyOverdue).toList();

  Future<void> fetchMembers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _members = await _memberRepository.getMembers();
    } catch (e) {
      debugPrint('Error fetching members: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMember(Map<String, dynamic> memberData, {Uint8List? imageBytes, String? imageName}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newMember = await _memberRepository.addMember(memberData, imageBytes: imageBytes, imageName: imageName);
      _members.insert(0, newMember); // Add to top of list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding member: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMember(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _memberRepository.deleteMember(id);
      _members.removeWhere((m) => m.id == id);
      return true;
    } catch (e) {
      debugPrint('Error deleting member: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMember(String id, Map<String, dynamic> memberData) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _memberRepository.updateMember(id, memberData);
      await fetchMembers(); // Refresh list
      return true;
    } catch (e) {
      debugPrint('Error updating member: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchExpiringMembers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _expiringMembers = await _memberRepository.getExpiringMembers();
    } catch (e) {
      debugPrint('Error fetching expiring members: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendWhatsAppReminder(String memberId) async {
    try {
      final response = await _apiService.post('/whatsapp/remind', {'memberId': memberId});
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sending WhatsApp reminder: $e');
      return false;
    }
  }
}
