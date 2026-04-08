import 'package:flutter/foundation.dart';

// class GymModel {
//   final String id;
//   final String gymName;
//   final String ownerName;
//   final String email;
//   final String phone;
//   final String? address;
//   final String? logoUrl;
//   final String subscriptionPlan;

//   GymModel({
//     required this.id,
//     required this.gymName,
//     required this.ownerName,
//     required this.email,
//     required this.phone,
//     this.address,
//     this.logoUrl,
//     this.subscriptionPlan = 'PRO',
//   });

//   factory GymModel.fromJson(Map<String, dynamic> json) {
//     return GymModel(
//       id: json['_id'] ?? json['id'] ?? '',
//       gymName: json['gymName'] ?? '',
//       ownerName: json['ownerName'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       address: json['address'],
//       logoUrl: json['logoUrl'],
//       subscriptionPlan: json['subscriptionPlan'] ?? 'PRO',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'gymName': gymName,
//       'ownerName': ownerName,
//       'email': email,
//       'phone': phone,
//       'address': address,
//       'logoUrl': logoUrl,
//       'subscriptionPlan': subscriptionPlan,
//     };
//   }
// }


class GymModel {
  final String id;
  final String gymId;
  final String gymName;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String logoUrl;
  final String? planEndDate;
  final bool isFreeTrial;

  GymModel({
    required this.id,
    required this.gymId,
    required this.gymName,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.logoUrl,
    this.planEndDate,
    required this.isFreeTrial,
  });

  factory GymModel.fromJson(Map<String, dynamic> json) {
    try {
      return GymModel(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        gymId: json['gymId']?.toString() ?? '',
        gymName: json['gymName'] ?? '',
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        mobileNumber: json['mobileNumber'] ?? '',
        logoUrl: json['logoUrl'] ?? '',
        planEndDate: json['planEndDate']?.toString(),
        isFreeTrial: json['isFreeTrial'] == true,
      );
    } catch (e) {
      debugPrint('GymModel.fromJson error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'gymId': gymId,
        'gymName': gymName,
        'fullName': fullName,
        'email': email,
        'mobileNumber': mobileNumber,
        'logoUrl': logoUrl,
        'planEndDate': planEndDate,
        'isFreeTrial': isFreeTrial,
      };
}