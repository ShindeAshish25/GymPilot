import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/report_pdf_generator.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/data/services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateReport();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
      _generateReport();
    }
  }

  void _generateReport() {
    final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(_endDate);
    Provider.of<ReportProvider>(context, listen: false)
        .fetchCustomReport(startStr, endStr);
  }

  Future<void> _exportPdf(Map reportData) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final gymProfile = auth.userProfile;
      final gymName = gymProfile?['gymName'] ?? 'Gym Manager';
      
      // Construct absolute logo URL
      String? logoUrl = gymProfile?['logoUrl'];
      if (logoUrl != null && logoUrl.isNotEmpty && logoUrl.startsWith('/')) {
        final baseUrlStr = ApiService.baseUrl;
        final baseDomain = baseUrlStr.split('/api').first;
        logoUrl = '$baseDomain$logoUrl';
      }

      await ReportPdfGenerator.generateAndPrint(
        reportData: Map<String, dynamic>.from(reportData),
        startDate: _startDate,
        endDate: _endDate,
        gymName: gymName,
        gymLogoUrl: logoUrl,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF export failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.reportData == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final data = provider.reportData;
          final summary = data?['summary'] ?? {};
          final lists = data?['lists'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateRangeSelector(data),
                const SizedBox(height: 24),
                _buildMetricsGrid(summary),
                const SizedBox(height: 24),
                _buildOverdueSection(lists['overdueMembers'] ?? []),
                const SizedBox(height: 24),
                _buildRecentRenewalsSection(lists['recentRenewals'] ?? []),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRangeSelector(Map? data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DATE RANGE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDateField('Start Date', _startDate, true)),
              const SizedBox(width: 12),
              Expanded(child: _buildDateField('End Date', _endDate, false)),
            ],
          ),
          const SizedBox(height: 16),

          // ── PDF Export Button (full width, no Excel) ──────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: data == null
                  ? null
                  : () => _exportPdf(data),
              icon: _isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: Text(_isExporting ? 'Generating PDF...' : 'Export as PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, bool isStart) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStart),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MM/dd/yyyy').format(date),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Map<dynamic, dynamic> summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatCard('Active Members',
                    '${summary['activeMembers'] ?? 0}',
                    trend: '+5%', color: Colors.green)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard('Overdue Members',
                    '${summary['overdueMembers'] ?? 0}',
                    valueColor: AppColors.primary,
                    trend: '+2',
                    trendColor: Colors.red)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'New Joiners', '${summary['newJoiners'] ?? 0}',
                    trend: '+12%', color: Colors.green)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard('Remaining Amount',
                    '₹${summary['unpaidAmount'] ?? 0}')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Total Expenses', '₹${summary['expenses'] ?? 0}')),
            const SizedBox(width: 12),
            Expanded(child: _buildRevenueCard(summary)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value,
      {String? trend,
      Color? color,
      Color? valueColor,
      Color? trendColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? AppColors.textPrimary),
              ),
              if (trend != null) ...[
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: trendColor ?? color ?? Colors.green),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(Map<dynamic, dynamic> summary) {
    final upi = summary['revenueDetails']?['upi'] ?? 0;
    final cash = summary['revenueDetails']?['cash'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Revenue',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70)),
          const SizedBox(height: 8),
          Text('₹${summary['revenue'] ?? 0}',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('UPI: ₹${(upi / 1000).toStringAsFixed(1)}k',
                  style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Text('CASH: ₹${(cash / 1000).toStringAsFixed(1)}k',
                  style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueSection(List members) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Overdue Members',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('${members.length}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          ...members.take(3).map((m) => _buildOverdueTile(m)),
          if (members.length > 3)
            InkWell(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Center(
                  child: Text('VIEW ALL OVERDUE',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverdueTile(dynamic m) {
    final initials = m['name']
            ?.split(' ')
            .map((e) => e[0])
            .take(2)
            .join('')
            .toUpperCase() ??
        '';
    int overdueDays = 0;
    if (m['membershipEndDate'] != null) {
      final end = DateTime.parse(m['membershipEndDate']);
      overdueDays = DateTime.now().difference(end).inDays;
    }

    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1)))),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFF1F5F9),
            child: Text(initials,
                style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['name'] ?? 'Unknown',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Overdue by $overdueDays days',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('₹${m['remainingAmount'] ?? 0}',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRecentRenewalsSection(List members) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('Recent Renewals',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('Active',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          ...members.take(3).map((m) => _buildRenewalTile(m)),
          if (members.length > 3)
            InkWell(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Center(
                  child: Text('VIEW ALL ACTIVE',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRenewalTile(dynamic m) {
    int daysLeft = 0;
    if (m['membershipEndDate'] != null) {
      final end = DateTime.parse(m['membershipEndDate']);
      daysLeft = end.difference(DateTime.now()).inDays;
    }

    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1)))),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                m['photoUrl'] != null ? NetworkImage(m['photoUrl']) : null,
            backgroundColor: const Color(0xFFF1F5F9),
            child: m['photoUrl'] == null
                ? const Icon(Icons.person, color: AppColors.textMuted)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['name'] ?? 'Unknown',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Expires in $daysLeft days',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}



//==============================================================================================================



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:frontend/core/constants/app_colors.dart';
// import 'package:frontend/providers/report_provider.dart';
// import 'package:frontend/core/utils/report_pdf_generator.dart';
// import 'package:frontend/providers/auth_provider.dart'; // adjust path as needed

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   State<ReportsScreen> createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
//   DateTime _endDate = DateTime.now();
//   bool _isExporting = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _generateReport();
//     });
//   }

//   Future<void> _selectDate(BuildContext context, bool isStart) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isStart ? _startDate : _endDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primary,
//               onPrimary: Colors.white,
//               onSurface: AppColors.textPrimary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStart) _startDate = picked;
//         else _endDate = picked;
//       });
//       _generateReport();
//     }
//   }

//   void _generateReport() {
//     final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
//     final endStr = DateFormat('yyyy-MM-dd').format(_endDate);
//     Provider.of<ReportProvider>(context, listen: false)
//         .fetchCustomReport(startStr, endStr);
//   }

//   Future<void> _exportPdf(Map reportData) async {
//     if (_isExporting) return;
//     setState(() => _isExporting = true);
//     try {
//       // Pull gym info from AuthProvider
//       final auth = Provider.of<AuthProvider>(context, listen: false);
//       final gymName = auth.gym?.gymName ?? 'My Gym';
//       final rawLogoUrl = auth.gym?.logoUrl ?? '';
//       // ✅ Replace YOUR_SERVER_IP with your machine's local IP e.g. 192.168.1.100
//       const serverBase = 'http://YOUR_SERVER_IP:5000';
//       final gymLogoUrl = rawLogoUrl.isNotEmpty ? '$serverBase$rawLogoUrl' : null;

//       // Build the reportData map in the shape ReportPdfGenerator expects
//       final Map<String, dynamic> pdfData = {
//         'summary': reportData['summary'] ?? {},
//         'lists': reportData['lists'] ?? {},
//         'overdueMembers': (reportData['lists'] ?? {})['overdueMembers'] ?? [],
//         'recentRenewals': (reportData['lists'] ?? {})['recentRenewals'] ?? [],
//       };

//       await ReportPdfGenerator.generateAndPrint(
//         reportData: pdfData,
//         startDate: _startDate,
//         endDate: _endDate,
//         gymName: gymName,
//         gymLogoUrl: gymLogoUrl,
//       );
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('PDF export failed: $e'),
//             backgroundColor: Colors.redAccent,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       body: Consumer<ReportProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading && provider.reportData == null) {
//             return const Center(
//                 child: CircularProgressIndicator(color: AppColors.primary));
//           }

//           final data = provider.reportData;
//           final summary = data?['summary'] ?? {};
//           final lists = data?['lists'] ?? {};

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildDateRangeSelector(data),
//                 const SizedBox(height: 24),
//                 _buildMetricsGrid(summary),
//                 const SizedBox(height: 24),
//                 _buildOverdueSection(lists['overdueMembers'] ?? []),
//                 const SizedBox(height: 24),
//                 _buildRecentRenewalsSection(lists['recentRenewals'] ?? []),
//                 const SizedBox(height: 80),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDateRangeSelector(Map? data) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'DATE RANGE',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textMuted,
//               letterSpacing: 1.2,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(child: _buildDateField('Start Date', _startDate, true)),
//               const SizedBox(width: 12),
//               Expanded(child: _buildDateField('End Date', _endDate, false)),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // ── PDF Export Button (full width, no Excel) ──────────────
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: data == null
//                   ? null
//                   : () => _exportPdf(data),
//               icon: _isExporting
//                   ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: AppColors.textPrimary,
//                       ),
//                     )
//                   : const Icon(Icons.picture_as_pdf_outlined, size: 18),
//               label: Text(_isExporting ? 'Generating PDF...' : 'Export as PDF'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFF1F5F9),
//                 foregroundColor: AppColors.textPrimary,
//                 elevation: 0,
//                 padding: const EdgeInsets.symmetric(vertical: 13),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 textStyle: const TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 13),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateField(String label, DateTime date, bool isStart) {
//     return GestureDetector(
//       onTap: () => _selectDate(context, isStart),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//                 fontSize: 11,
//                 color: AppColors.textSecondary,
//                 fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 6),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             decoration: BoxDecoration(
//               color: AppColors.backgroundLight,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   DateFormat('MM/dd/yyyy').format(date),
//                   style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.textPrimary),
//                 ),
//                 const Icon(Icons.calendar_today_outlined,
//                     size: 16, color: AppColors.textSecondary),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMetricsGrid(Map<dynamic, dynamic> summary) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//                 child: _buildStatCard('Active Members',
//                     '${summary['activeMembers'] ?? 0}',
//                     trend: '+5%', color: Colors.green)),
//             const SizedBox(width: 12),
//             Expanded(
//                 child: _buildStatCard('Overdue Members',
//                     '${summary['overdueMembers'] ?? 0}',
//                     valueColor: AppColors.primary,
//                     trend: '+2',
//                     trendColor: Colors.red)),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//                 child: _buildStatCard(
//                     'New Joiners', '${summary['newJoiners'] ?? 0}',
//                     trend: '+12%', color: Colors.green)),
//             const SizedBox(width: 12),
//             Expanded(
//                 child: _buildStatCard('Remaining Amount',
//                     '₹${summary['unpaidAmount'] ?? 0}')),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//                 child: _buildStatCard(
//                     'Total Expenses', '₹${summary['expenses'] ?? 0}')),
//             const SizedBox(width: 12),
//             Expanded(child: _buildRevenueCard(summary)),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(String label, String value,
//       {String? trend,
//       Color? color,
//       Color? valueColor,
//       Color? trendColor}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.02),
//               blurRadius: 8,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textSecondary),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.baseline,
//             textBaseline: TextBaseline.alphabetic,
//             children: [
//               Text(
//                 value,
//                 style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: valueColor ?? AppColors.textPrimary),
//               ),
//               if (trend != null) ...[
//                 const SizedBox(width: 4),
//                 Text(
//                   trend,
//                   style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       color: trendColor ?? color ?? Colors.green),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRevenueCard(Map<dynamic, dynamic> summary) {
//     final upi = summary['revenueDetails']?['upi'] ?? 0;
//     final cash = summary['revenueDetails']?['cash'] ?? 0;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.primary,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//               color: AppColors.primary.withOpacity(0.3),
//               blurRadius: 12,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Total Revenue',
//               style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white70)),
//           const SizedBox(height: 8),
//           Text('₹${summary['revenue'] ?? 0}',
//               style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white)),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('UPI: ₹${(upi / 1000).toStringAsFixed(1)}k',
//                   style: const TextStyle(
//                       fontSize: 9,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold)),
//               Text('CASH: ₹${(cash / 1000).toStringAsFixed(1)}k',
//                   style: const TextStyle(
//                       fontSize: 9,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOverdueSection(List members) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.02),
//               blurRadius: 10,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Row(
//                   children: [
//                     Icon(Icons.error_outline,
//                         color: AppColors.primary, size: 20),
//                     SizedBox(width: 8),
//                     Text('Overdue Members',
//                         style: TextStyle(
//                             fontSize: 15, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                       color: AppColors.primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Text('${members.length}',
//                       style: const TextStyle(
//                           color: AppColors.primary,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//           ),
//           ...members.take(3).map((m) => _buildOverdueTile(m)),
//           if (members.length > 3)
//             InkWell(
//               onTap: () {},
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 child: const Center(
//                   child: Text('VIEW ALL OVERDUE',
//                       style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.textMuted)),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOverdueTile(dynamic m) {
//     final initials = m['name']
//             ?.split(' ')
//             .map((e) => e[0])
//             .take(2)
//             .join('')
//             .toUpperCase() ??
//         '';
//     int overdueDays = 0;
//     if (m['membershipEndDate'] != null) {
//       final end = DateTime.parse(m['membershipEndDate']);
//       overdueDays = DateTime.now().difference(end).inDays;
//     }

//     return Container(
//       decoration: BoxDecoration(
//           border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1)))),
//       padding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 20,
//             backgroundColor: const Color(0xFFF1F5F9),
//             child: Text(initials,
//                 style: const TextStyle(
//                     color: AppColors.textMuted,
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold)),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(m['name'] ?? 'Unknown',
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 14)),
//                 Text('Overdue by $overdueDays days',
//                     style: const TextStyle(
//                         fontSize: 11, color: AppColors.textSecondary)),
//               ],
//             ),
//           ),
//           Text('₹${m['remainingAmount'] ?? 0}',
//               style: const TextStyle(
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentRenewalsSection(List members) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.02),
//               blurRadius: 10,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Row(
//                   children: [
//                     Icon(Icons.check_circle_outline,
//                         color: Colors.green, size: 20),
//                     SizedBox(width: 8),
//                     Text('Recent Renewals',
//                         style: TextStyle(
//                             fontSize: 15, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(4)),
//                   child: const Text('Active',
//                       style: TextStyle(
//                           color: Colors.green,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//           ),
//           ...members.take(3).map((m) => _buildRenewalTile(m)),
//           if (members.length > 3)
//             InkWell(
//               onTap: () {},
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 child: const Center(
//                   child: Text('VIEW ALL ACTIVE',
//                       style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.textMuted)),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRenewalTile(dynamic m) {
//     int daysLeft = 0;
//     if (m['membershipEndDate'] != null) {
//       final end = DateTime.parse(m['membershipEndDate']);
//       daysLeft = end.difference(DateTime.now()).inDays;
//     }

//     return Container(
//       decoration: BoxDecoration(
//           border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1)))),
//       padding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 20,
//             backgroundImage:
//                 m['photoUrl'] != null ? NetworkImage(m['photoUrl']) : null,
//             backgroundColor: const Color(0xFFF1F5F9),
//             child: m['photoUrl'] == null
//                 ? const Icon(Icons.person, color: AppColors.textMuted)
//                 : null,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(m['name'] ?? 'Unknown',
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 14)),
//                 Text('Expires in $daysLeft days',
//                     style: const TextStyle(
//                         fontSize: 11, color: AppColors.textSecondary)),
//               ],
//             ),
//           ),
//           const Icon(Icons.chevron_right,
//               color: AppColors.textMuted, size: 20),
//         ],
//       ),
//     );
//   }
// }