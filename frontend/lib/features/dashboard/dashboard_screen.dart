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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(userName, gymName),
                const SizedBox(height: 24),
                _buildStatsGrid(stats),
                const SizedBox(height: 24),
                _buildOverdueSection(),
                const SizedBox(height: 24),
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
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 80),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Color(0x33F5385B),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Welcome Back, $name!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                _buildNotificationIcon(),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<DashboardProvider>(
              builder: (context, provider, _) {
                final revenueTrend = provider.stats?.trends['revenue'] ?? 0;
                final status = revenueTrend >= 0 ? 'better' : 'lower';
                return Text(
                  '$gymName is performing ${revenueTrend.abs()}% $status than last month. Check out the latest analytics below.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildHeroButton(
                  'Add Member', 
                  Colors.white, 
                  AppColors.primary, 
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddMemberModal(),
                  ),
                ),
                const SizedBox(width: 12),
                _buildHeroButton('Generate Report', Colors.white.withValues(alpha: 0.2), Colors.white, isOutlined: true, onTap: () => context.push('/reports')),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildHeroButton(String text, Color bgColor, Color textColor, {bool isOutlined = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isOutlined ? Border.all(color: Colors.white.withValues(alpha: 0.3)) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
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
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Overdue',
                '${stats?.overdueMembers ?? 0}',
                Icons.priority_high_rounded,
                const Color(0xFFFFEBEE),
                const Color(0xFFEF4444),
                '${trends['overdue'] ?? 0}%',
                isTrendNegative: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Expenses',
                '₹${((stats?.monthlyExpenses ?? 0) / 1000).toStringAsFixed(1)}k',
                Icons.account_balance_wallet_rounded,
                const Color(0xFFFFF3E0),
                const Color(0xFFF59E0B),
                '${trends['expenses'] ?? 0}%',
                isTrendNegative: (trends['expenses'] ?? 0) > 0, // Expenses up is usually negative
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFullWidthStatCard(
          'New Joiners',
          '${stats?.newJoiners ?? 0}',
          Icons.person_add_rounded,
          const Color(0xFFFCE4EC),
          AppColors.primary,
          '${trends['joiners'] ?? 0}%',
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconBg, Color iconColor, String trend, {bool isTrendNegative = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Text(
                trend,
                style: TextStyle(
                  color: isTrendNegative ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthStatCard(String title, String value, IconData icon, Color iconBg, Color iconColor, String trend) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsLayout(DashboardProvider dashboard) {
    return Column(
      children: [
        _buildRevenueTrendsCard(dashboard),
        const SizedBox(height: 24),
        _buildAttendanceTrendsCard(dashboard),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildNewJoinersCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildMonthlyExpensesCard()),
          ],
        ),
        const SizedBox(height: 24),
        _buildOverallSummaryCard(),
        const SizedBox(height: 24),
        _buildLatestJoinersCard(),
      ],
    );
  }

  Widget _buildRevenueTrendsCard(DashboardProvider dashboard) {
    final revenueData = dashboard.revenueChartData;
    final hasData = revenueData.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Trends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Monthly income performance',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
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
                    _buildChartToggle('Year', false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 220,
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
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                              const style = TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, fontSize: 10);
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
                : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
              AppColors.primary.withValues(alpha: isBold ? 0.8 : 0.4),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: y * 1.1,
            color: AppColors.primary.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildChartToggle(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: active ? [const BoxShadow(color: Colors.black12, blurRadius: 2)] : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? AppColors.textPrimary : AppColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAttendanceTrendsCard(DashboardProvider provider) {
    final hasData = provider.attendanceChartData.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Daily check-ins last 30 days',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
              Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
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
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(child: Text('No attendance data available', style: TextStyle(color: AppColors.muted))),
          ),
        ],
      ),
    );
  }

  Widget _buildNewJoinersCard() {
    return Consumer<MemberProvider>(builder: (context, provider, _) {
      final hasData = provider.members.isNotEmpty;
      return Container(
        padding: const EdgeInsets.all(20),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Joiners', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
            const Positioned(
              right: 0,
              child: Icon(Icons.person_add_rounded, color: AppColors.primary, size: 20),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 100,
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
                                colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.primary.withValues(alpha: 0)],
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
              bottom: 10,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Text('${provider.members.length} Total', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              ),
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
      final categories = dashboard.chartData; // Assuming this contains categories if last fetched as 'expenses'
      
      return Container(
        padding: const EdgeInsets.all(20),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monthly Expenses', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                Icon(Icons.receipt_long_rounded, color: AppColors.muted, size: 18),
              ],
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty)
              _buildExpenseBar('Total Spend', '₹${(expenseValue / 1000).toStringAsFixed(1)}k', 1.0, AppColors.primary)
            else
              ...categories.take(3).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
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
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w700)),
            Text(value, style: const TextStyle(fontSize: 10, color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallSummaryCard() {
    return Consumer<DashboardProvider>(builder: (context, dashboard, _) {
      final stats = dashboard.stats;
      final active = (stats?.activeMembers ?? 0).toDouble();
      final total = active + 15; // Mocking total for percentage

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overall Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 55,
                            sections: dashboard.distributionData.isEmpty
                                ? [PieChartSectionData(value: 1, color: AppColors.surfaceLight, radius: 15, showTitle: false)]
                                : dashboard.distributionData.asMap().entries.map((e) {
                                    final colors = [AppColors.primary, AppColors.muted, const Color(0xFFE2F1F3)];
                                    return PieChartSectionData(
                                      value: e.value.value,
                                      color: colors[e.key % colors.length],
                                      radius: 15,
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
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                            ),
                            const Text('EFFICIENCY', style: TextStyle(fontSize: 9, color: AppColors.muted, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildSummaryItem(
                        'Member Retention', 
                        'Active status trend', 
                        '${dashboard.stats?.trends['active'] ?? 0}%', 
                        AppColors.primary
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryItem(
                        'Acquisitions', 
                        'New joiners trend', 
                        '${dashboard.stats?.trends['joiners'] ?? 0}%', 
                        AppColors.muted
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryItem(
                        'Churn Rate', 
                        'Estimated leakage', 
                        '${(dashboard.stats?.trends['overdue'] ?? 0).abs()}%', 
                        const Color(0xFFE2F1F3), 
                        isCircular: true
                      ),
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

  Widget _buildSummaryItem(String title, String subtitle, String val, Color color, {bool isCircular = false}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isCircular ? Border.all(color: AppColors.primary.withValues(alpha: 0.1)) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ),
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildLatestJoinersCard() {
    return Consumer<MemberProvider>(builder: (context, provider, _) {
      final joiners = provider.members.take(3).toList();

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Latest Joiners', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13))),
              ],
            ),
            const SizedBox(height: 16),
            if (joiners.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No members yet', style: TextStyle(color: AppColors.muted)),
              )
            else
              ...joiners.expand((member) => [
                    _buildJoinerItem(
                      member.name,
                      '${(member.trainingType ?? "Plan").toUpperCase()} • ${member.memberId.isNotEmpty ? member.memberId : member.id.substring(0, 4)}',
                      'https://ui-avatars.com/api/?name=${member.name}&background=random',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(color: Colors.white, height: 1),
                    ),
                  ]),
          ],
        ),
      );
    });
  }

  Widget _buildJoinerItem(String name, String details, String imgUrl) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(details.toUpperCase(), style: const TextStyle(fontSize: 9, color: AppColors.muted, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ],
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
  }

  Widget _buildNotificationIcon() {
    return Consumer<MemberProvider>(
      builder: (context, provider, _) {
        final count = provider.expiringSoonMembers.length + provider.recentlyOverdueMembers.length;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
              onPressed: () => _showNotifications(context),
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFFF4D67), shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showExpiringMembersDetails(BuildContext context, List<MemberModel> members) {
    _showNotifications(context);
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
                  Text('Recent Overdue Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: overdueMembers.length,
                itemBuilder: (context, index) {
                  final member = overdueMembers[index];
                  return GestureDetector(
                    onTap: () => showMemberPremiumPopup(context, member),
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('Plan: ${member.trainingType ?? "Monthly"}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Expired ${member.daysUntilExpiry.abs()}d ago', style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                              const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.muted),
                            ],
                          ),
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

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 40);
    var secondEndPoint = Offset(size.width, size.height);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
