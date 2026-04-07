class TrainerModel {
  final String id;
  final String name;
  final String phone;
  final String? photoUrl;
  final String? specialization;
  final double feeChargePerPerson;
  final String? experience;
  final int assignedMembers;

  TrainerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    this.specialization,
    this.feeChargePerPerson = 0.0,
    this.experience,
    this.assignedMembers = 0,
  });

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    return TrainerModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'],
      specialization: json['specialization'],
      feeChargePerPerson: (json['feeChargePerPerson'] ?? 0.0).toDouble(),
      experience: json['experience'],
      assignedMembers: json['assignedMembers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'specialization': specialization,
      'feeChargePerPerson': feeChargePerPerson,
      'experience': experience,
      'assignedMembers': assignedMembers,
    };
  }
}
