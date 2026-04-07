class PhysicalDetail {
  final DateTime date;
  final double? height;
  final double? weight;
  final String? workoutPlan;
  final String? dietPlan;
  final String? description;

  PhysicalDetail({
    required this.date,
    this.height,
    this.weight,
    this.workoutPlan,
    this.dietPlan,
    this.description,
  });

  factory PhysicalDetail.fromJson(Map<String, dynamic> json) {
    return PhysicalDetail(
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      height: (json['height'] ?? 0.0).toDouble(),
      weight: (json['weight'] ?? 0.0).toDouble(),
      workoutPlan: json['workoutPlan'],
      dietPlan: json['dietPlan'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'height': height,
      'weight': weight,
      'workoutPlan': workoutPlan,
      'dietPlan': dietPlan,
      'description': description,
    };
  }
}

class MemberModel {
  final String id;
  final String memberId;
  final String name;
  final String phone;
  final String? email;
  final String? gender;
  final String? address;
  final String? paymentStatus;
  final DateTime? membershipEndDate;
  final DateTime? joinDate;
  final String? photoUrl;
  final double totalFee;
  final double amountPaid;
  final double remainingAmount;
  final int? membershipDuration; // In months
  
  // New Fields
  final String? batch;
  final String? trainingType;
  final DateTime? paymentDate;
  final String? paymentMode;
  final double cashAmount;
  final double upiAmount;
  final String? description;
  final String? status;
  final List<PhysicalDetail> physicalDetails;

  // ── Computed Properties for Membership Logic ───────────────────
  
  /// The effective end date of the membership.
  /// Uses membershipEndDate from backend, or calculates from joinDate + duration.
  DateTime? get effectiveEndDate {
    if (membershipEndDate != null) return membershipEndDate;
    if (joinDate != null && membershipDuration != null) {
      // Align with backend logic: 30 days per month
      return joinDate!.add(Duration(days: membershipDuration! * 30));
    }
    return null;
  }

  /// Returns days until expiry. Positive if in future, negative if in past (expired).
  int get daysUntilExpiry {
    final end = effectiveEndDate;
    if (end == null) return 0; // Default to 0 instead of 9999 to avoid UI glitches
    
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final endDate = DateTime(end.year, end.month, end.day);
    
    return endDate.difference(todayDate).inDays;
  }

  /// True if membership has not expired or expires today.
  bool get isActive => daysUntilExpiry >= 0;

  /// True if membership expires in 5 days or less.
  bool get isExpiringSoon => daysUntilExpiry >= 0 && daysUntilExpiry <= 5;

  /// True if membership expired in the last 10 days.
  bool get isRecentlyOverdue => daysUntilExpiry < 0 && daysUntilExpiry >= -10;

  /// True if membership expired more than 10 days ago.
  bool get isCriticallyOverdue => daysUntilExpiry < -10;

  /// True if there is a pending payment balance.
  bool get hasPendingPayment => (totalFee > amountPaid);
  

  MemberModel({
    required this.id,
    required this.memberId,
    required this.name,
    required this.phone,
    this.email,
    this.gender,
    this.address,
    this.paymentStatus,
    this.membershipEndDate,
    this.joinDate,
    this.photoUrl,
    this.totalFee = 0.0,
    this.amountPaid = 0.0,
    this.remainingAmount = 0.0,
    this.membershipDuration,
    this.batch,
    this.trainingType,
    this.paymentDate,
    this.paymentMode,
    this.cashAmount = 0.0,
    this.upiAmount = 0.0,
    this.description,
    this.status,
    this.physicalDetails = const [],
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['_id'] ?? json['id'] ?? '',
      memberId: json['memberId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      gender: json['gender'],
      address: json['address'],
      paymentStatus: json['paymentStatus'],
      membershipEndDate: json['membershipEndDate'] != null ? DateTime.tryParse(json['membershipEndDate']) : null,
      joinDate: json['joinDate'] != null ? DateTime.tryParse(json['joinDate']) : null,
      photoUrl: json['photoUrl'],
      totalFee: (json['totalFee'] ?? 0.0).toDouble(),
      amountPaid: (json['amountPaid'] ?? 0.0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0.0).toDouble(),
      membershipDuration: json['membershipDuration'] != null 
          ? int.tryParse(json['membershipDuration'].toString()) 
          : null,
      batch: json['batch'],
      trainingType: json['trainingType'],
      paymentDate: json['paymentDate'] != null ? DateTime.tryParse(json['paymentDate']) : null,
      paymentMode: json['paymentMode'],
      cashAmount: (json['cashAmount'] ?? 0.0).toDouble(),
      upiAmount: (json['upiAmount'] ?? 0.0).toDouble(),
      description: json['description'],
      status: json['status'],
      physicalDetails: (json['physicalDetails'] as List? ?? [])
          .map((e) => PhysicalDetail.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'address': address,
      'paymentStatus': paymentStatus,
      'membershipEndDate': membershipEndDate?.toIso8601String(),
      'joinDate': joinDate?.toIso8601String(),
      'photoUrl': photoUrl,
      'totalFee': totalFee,
      'amountPaid': amountPaid,
      'remainingAmount': remainingAmount,
      'membershipDuration': membershipDuration,
      'batch': batch,
      'trainingType': trainingType,
      'paymentDate': paymentDate?.toIso8601String(),
      'paymentMode': paymentMode,
      'cashAmount': cashAmount,
      'upiAmount': upiAmount,
      'description': description,
      'status': status,
      'physicalDetails': physicalDetails.map((e) => e.toJson()).toList(),
    };
  }
}
