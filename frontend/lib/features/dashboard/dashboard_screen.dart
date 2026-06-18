import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/member_model.dart';
import '../members/widgets/add_member_modal.dart';
import '../notifications/notifications_screen.dart';
import '../members/widgets/member_premium_popup.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      provider.fetchDashboardStats();
      provider.fetchChartData('revenue', 'month');
      provider.fetchChartData('joiners', 'month');
      provider.fetchChartData('expenses', 'month'); // For categories
      provider.fetchAttendanceData();
      provider.fetchDistributionData();
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
      Provider.of<MemberProvider>(context, listen: false).fetchExpiringMembers();
      Provider.of<AuthProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;
    final userName = user?['fullName'] ?? 'Admin';
    final gymName = user?['gymName'] ?? 'Gympilot';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer<DashboardProvider>(
        builder: (context, dashboard, child) {
          final stats = dashboard.stats;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(userName, gymName),
                const SizedBox(height: 20),
                _buildStatsGrid(stats),
                const SizedBox(height: 20),
                _buildOverdueSection(),
                const SizedBox(height: 20),
                _buildChartsLayout(dashboard),
                const SizedBox(height: 100), // Space for nav bar
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(String name, String gymName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $name!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome to $gymName',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Consumer<DashboardProvider>(
            builder: (context, provider, _) {
              final revenueTrend = provider.stats?.trends['revenue'] ?? 0;
              final status = revenueTrend >= 0 ? 'growth' : 'dip';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      revenueTrend >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${revenueTrend.abs()}% $status this month',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildHeroButton(String text, Color bgColor, Color textColor, {bool isOutlined = false, VoidCallback? onTap}) {
    return const SizedBox.shrink(); // Buttons removed as per requirement
  }

  Widget _buildStatsGrid(dynamic stats) {
    final trends = stats?.trends ?? {};
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Active Members',
                '${stats?.activeMembers ?? 0}',
                Icons.groups_rounded,
                const Color(0xFFE2F1F3),
                AppColors.primary,
                '${trends['active'] ?? 0}%',
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Overdue',
                '${stats?.overdueMembers ?? 0}',
                Icons.priority_high_rounded,
                const Color(0xFFFFEBEE),
                const Color(0xFFEF4444),
                '${trends['overdue'] ?? 0}%',
                isTrendNegative: true,
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Revenue',
                '₹${((stats?.monthlyRevenue ?? 0) / 1000).toStringAsFixed(1)}k',
                Icons.payments_rounded,
                const Color(0xFFE8F5E9),
                const Color(0xFF10B981),
                '${trends['revenue'] ?? 0}%',
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Expenses',
                '₹${((stats?.monthlyExpenses ?? 0) / 1000).toStringAsFixed(1)}k',
                Icons.account_balance_wallet_rounded,
                const Color(0xFFFFF3E0),
                const Color(0xFFF59E0B),
                '${trends['expenses'] ?? 0}%',
                isTrendNegative: (trends['expenses'] ?? 0) > 0,
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconBg, Color iconColor, String trend, {bool isTrendNegative = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isTrendNegative ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: isTrendNegative ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthStatCard(String title, String value, IconData icon, Color iconBg, Color iconColor, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            trend,
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsLayout(DashboardProvider dashboard) {
    return Column(
      children: [
        _buildRevenueTrendsCard(dashboard).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        _buildAttendanceTrendsCard(dashboard).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildNewJoinersCard().animate().fadeIn(delay: 700.ms).slideX(begin: -0.1, end: 0)),
            const SizedBox(width: 12),
            Expanded(child: _buildMonthlyExpensesCard().animate().fadeIn(delay: 800.ms).slideX(begin: 0.1, end: 0)),
          ],
        ),
        const SizedBox(height: 16),
        _buildOverallSummaryCard().animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildRevenueTrendsCard(DashboardProvider dashboard) {
    final revenueData = dashboard.revenueChartData;
    final hasData = revenueData.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Trends',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Monthly performance',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildChartToggle('Week', false),
                    _buildChartToggle('Month', true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: hasData
                ? BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: revenueData.fold<double>(0, (max, p) => p.value > max ? p.value : max) * 1.5,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => AppColors.textPrimary,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '₹${(rod.toY / 1000).toStringAsFixed(1)}k',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const style = TextStyle(color: AppColors.muted, fontWeight: FontWeight.bold, fontSize: 9);
                              if (value.toInt() >= 0 && value.toInt() < revenueData.length) {
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 8,
                                  child: Text(revenueData[value.toInt()].label.toUpperCase(), style: style),
                                );
                              }
                              return const SizedBox();
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: revenueData.asMap().entries.map((entry) {
                        return _makeBarGroup(entry.key, entry.value.value, isBold: entry.key == revenueData.length - 1);
                      }).toList(),
                    ),
                  )
                : const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, {bool isBold = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(isBold ? 0.8 : 0.4),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: y * 1.1 + 1000,
            color: AppColors.primary.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildChartToggle(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? AppColors.textPrimary : AppColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAttendanceTrendsCard(DashboardProvider provider) {
    final hasData = provider.attendanceChartData.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Trends',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Daily check-ins',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
              Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: hasData
                ? LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: provider.attendanceChartData.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.value);
                          }).toList(),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(child: Text('No attendance data available', style: TextStyle(color: AppColors.muted, fontSize: 12))),
          ),
        ],
      ),
    );
  }

  Widget _buildNewJoinersCard() {
    return Consumer<MemberProvider>(builder: (context, provider, _) {
      return Container(
        padding: const EdgeInsets.all(16),
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Joiners', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ],
            ),
            const Positioned(
              right: 0,
              child: Icon(Icons.person_add_rounded, color: AppColors.primary, size: 18),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 80,
                child: Consumer<DashboardProvider>(
                  builder: (context, provider, _) {
                    final data = provider.joinersChartData;
                    final hasSpots = data.isNotEmpty;
                    return LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: hasSpots
                                ? data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList()
                                : const [FlSpot(0, 0), FlSpot(1, 0)],
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Text('${provider.members.length} Total', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.muted)),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMonthlyExpensesCard() {
    return Consumer<DashboardProvider>(builder: (context, dashboard, _) {
      final stats = dashboard.stats;
      final expenseValue = stats?.monthlyExpenses ?? 0;
      final categories = dashboard.chartData;
      
      return Container(
        padding: const EdgeInsets.all(16),
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expenses', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                Icon(Icons.receipt_long_rounded, color: AppColors.muted, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            if (categories.isEmpty)
              _buildExpenseBar('Total Spend', '₹${(expenseValue / 1000).toStringAsFixed(1)}k', 1.0, AppColors.primary)
            else
              ...categories.take(2).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _buildExpenseBar(e.label, '₹${(e.value / 1000).toStringAsFixed(1)}k', e.value / (expenseValue > 0 ? expenseValue : 1), AppColors.primary),
              )),
          ],
        ),
      );
    });
  }

  Widget _buildExpenseBar(String label, String value, double percent, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(label, style: const TextStyle(fontSize: 9, color: AppColors.muted, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Text(value, style: const TextStyle(fontSize: 9, color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallSummaryCard() {
    return Consumer<DashboardProvider>(builder: (context, dashboard, _) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overall Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 45,
                            sections: dashboard.distributionData.isEmpty
                                ? [PieChartSectionData(value: 1, color: AppColors.surfaceLight, radius: 12, showTitle: false)]
                                : dashboard.distributionData.asMap().entries.map((e) {
                                    final colors = [AppColors.primary, AppColors.muted, const Color(0xFFE2F1F3)];
                                    return PieChartSectionData(
                                      value: e.value.value,
                                      color: colors[e.key % colors.length],
                                      radius: 12,
                                      showTitle: false,
                                    );
                                  }).toList(),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dashboard.distributionData.isEmpty
                                  ? '0%'
                                  : '${((dashboard.distributionData.first.value / (dashboard.distributionData.fold(0.0, (previousValue, element) => previousValue + element.value))) * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                            const Text('EFFICIENCY', style: TextStyle(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildSummaryItem('Retention', '${dashboard.stats?.trends['active'] ?? 0}%', AppColors.primary),
                      const SizedBox(height: 12),
                      _buildSummaryItem('Growth', '${dashboard.stats?.trends['joiners'] ?? 0}%', AppColors.muted),
                      const SizedBox(height: 12),
                      _buildSummaryItem('Churn', '${(dashboard.stats?.trends['overdue'] ?? 0).abs()}%', const Color(0xFFE2F1F3)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem(String title, String val, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ],
    );
  }


  Widget _buildOverdueSection() {
    return Consumer<MemberProvider>(
      builder: (context, provider, _) {
        final overdueMembers = provider.recentlyOverdueMembers;
        if (overdueMembers.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text('Urgent Follow-ups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: overdueMembers.length,
                itemBuilder: (context, index) {
                  final member = overdueMembers[index];
                  return GestureDetector(
                    onTap: () => showMemberPremiumPopup(context, member),
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const Spacer(),
                          Text('Expired ${member.daysUntilExpiry.abs()}d ago', style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
