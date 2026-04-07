class GymModel {
  final String id;
  final String gymName;
  final String ownerName;
  final String email;
  final String phone;
  final String? address;
  final String? logoUrl;
  final String subscriptionPlan;

  GymModel({
    required this.id,
    required this.gymName,
    required this.ownerName,
    required this.email,
    required this.phone,
    this.address,
    this.logoUrl,
    this.subscriptionPlan = 'PRO',
  });

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: json['_id'] ?? json['id'] ?? '',
      gymName: json['gymName'] ?? '',
      ownerName: json['ownerName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      logoUrl: json['logoUrl'],
      subscriptionPlan: json['subscriptionPlan'] ?? 'PRO',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gymName': gymName,
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'address': address,
      'logoUrl': logoUrl,
      'subscriptionPlan': subscriptionPlan,
    };
  }
}
