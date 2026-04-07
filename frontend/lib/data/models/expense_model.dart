class ExpenseModel {
  final String id;
  final DateTime date;
  final String category;
  final double amount;
  final String? notes;
  String get categoryName => category;

  ExpenseModel({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    this.notes,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['_id'] ?? json['id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'category': category,
      'amount': amount,
      'notes': notes,
    };
  }
}

class ExpenseCategoryModel {
  final String id;
  final String name;
  final String? logo;
  final bool isDefault;

  ExpenseCategoryModel({
    required this.id,
    required this.name,
    this.logo,
    this.isDefault = false,
  });

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'isDefault': isDefault,
    };
  }
}
