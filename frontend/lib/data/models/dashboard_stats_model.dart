class DashboardStatsModel {
  final int activeMembers;
  final int overdueMembers;
  final int newJoiners;
  final double monthlyRevenue;
  final double monthlyExpenses;
  final Map<String, dynamic> trends;

  DashboardStatsModel({
    this.activeMembers = 0,
    this.overdueMembers = 0,
    this.newJoiners = 0,
    this.monthlyRevenue = 0.0,
    this.monthlyExpenses = 0.0,
    this.trends = const {},
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      activeMembers: json['activeMembers'] ?? 0,
      overdueMembers: json['overdueMembers'] ?? 0,
      newJoiners: json['newJoiners'] ?? 0,
      monthlyRevenue: (json['revenue'] ?? 0.0).toDouble(),
      monthlyExpenses: (json['expenses'] ?? 0.0).toDouble(),
      trends: json['trends'] ?? {},
    );
  }
}

class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint({required this.label, required this.value});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json, String type) {
    double val = 0.0;
    if (type == 'joiners' || type == 'attendance') {
      val = (json['count'] ?? 0.0).toDouble();
    } else if (type == 'distribution') {
      val = (json['count'] ?? 0.0).toDouble();
    } else {
      val = (json['amount'] ?? 0.0).toDouble();
    }
    
    return ChartDataPoint(
      label: (json['label'] ?? json['_id'] ?? json['name'] ?? '').toString(),
      value: val,
    );
  }
}
