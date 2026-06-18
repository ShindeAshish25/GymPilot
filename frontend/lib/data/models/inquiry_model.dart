class InquiryModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? gender;
  final DateTime inquiryDate;
  final DateTime? planToJoinDate;
  final String? address;
  final String status;

  InquiryModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.gender,
    required this.inquiryDate,
    this.planToJoinDate,
    this.address,
    required this.status,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> json) {
    return InquiryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      gender: json['gender'],
      inquiryDate: json['inquiryDate'] != null 
          ? DateTime.parse(json['inquiryDate']) 
          : DateTime.now(),
      planToJoinDate: json['planToJoinDate'] != null 
          ? DateTime.parse(json['planToJoinDate']) 
          : null,
      address: json['address'],
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'inquiryDate': inquiryDate.toIso8601String(),
      'planToJoinDate': planToJoinDate?.toIso8601String(),
      'address': address,
      'status': status,
    };
  }
}
