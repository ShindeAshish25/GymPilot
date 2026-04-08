import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ReportPdfGenerator {
  static Future<void> generateAndPrint({
    required Map<String, dynamic> reportData,
    required DateTime startDate,
    required DateTime endDate,
    String? gymName,
    String? gymLogoUrl,
    String? gymLogoAssetPath,
  }) async {
    final pdf = pw.Document();

    // ── Fonts (Dynamic from Google Fonts) ──────────────────────────
    final ttfRegular = await PdfGoogleFonts.lexendRegular();
    final ttfBold    = await PdfGoogleFonts.lexendBold();
    final ttfMedium  = await PdfGoogleFonts.lexendMedium();
    final ttfLight   = await PdfGoogleFonts.lexendLight();
    final ttf        = ttfRegular; // Alias for general use

    // ── Color Palette ──────────────────────────────────────────────
    const primaryColor = PdfColor.fromInt(0xFFF5385B);   // #F5385B (Brand Primary)
    const accentColor  = PdfColor.fromInt(0xFFF7627D);   // Lighter pink/red
    const bgLight      = PdfColor.fromInt(0xFFF8F5F6);
    const textPrimary  = PdfColor.fromInt(0xFF221013);
    const textMuted    = PdfColor.fromInt(0xFF888888);
    const white        = PdfColors.white;
    const successGreen = PdfColor.fromInt(0xFF27AE60);
    const dangerRed    = PdfColor.fromInt(0xFFE74C3C);
    const cardShadow   = PdfColor.fromInt(0xFFEEEEEE);

    // ── Load Logo ──────────────────────────────────────────────────
    pw.ImageProvider? logoImage;
    if (gymLogoUrl != null && gymLogoUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(gymLogoUrl));
        if (response.statusCode == 200) {
          logoImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        debugPrint('Error loading network logo: $e');
      }
    }

    if (logoImage == null && gymLogoAssetPath != null) {
      try {
        final logoBytes = await rootBundle.load(gymLogoAssetPath);
        logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
      } catch (_) {
        logoImage = null;
      }
    }

    // ── Data Helpers ───────────────────────────────────────────────
    final summary = reportData['summary'] ?? {};
    final lists = reportData['lists'] ?? {};
    final overdueMembers = reportData['overdueMembers'] ?? lists['overdueMembers'] ?? [];
    final recentRenewals = reportData['recentRenewals'] ?? lists['recentRenewals'] ?? [];

    final dateRange =
        '${DateFormat('MMM dd, yyyy').format(startDate)} – ${DateFormat('MMM dd, yyyy').format(endDate)}';

    final revenue     = summary['revenue'] ?? 0;
    final upi         = summary['revenueDetails']?['upi'] ?? 0;
    final cash        = summary['revenueDetails']?['cash'] ?? 0;
    final active      = summary['activeMembers'] ?? 0;
    final overdue     = summary['overdueMembers'] ?? 0;
    final newJoiners  = summary['newJoiners'] ?? 0;
    final unpaid      = summary['unpaidAmount'] ?? 0;
    final expenses    = summary['expenses'] ?? 0;

    final actualGymName = gymName ?? 'FitZone Gym';

    String _ini(String? name) {
      if (name == null || name.isEmpty) return '?';
      return name.trim().split(' ').map((e) => e.isEmpty ? '' : e[0]).take(2).join().toUpperCase();
    }

    // ── Shared Builders ────────────────────────────────────────────

    pw.Widget _metricCard({
      required String label,
      required String value,
      String? sub,
      PdfColor? valueColor,
      PdfColor? bgColor,
      PdfColor? labelColor,
      PdfColor? subColor,
    }) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: bgColor ?? white,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: cardShadow, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label.toUpperCase(),
              style: pw.TextStyle(
                font: ttfMedium,
                fontSize: 7,
                color: labelColor ?? textMuted,
                letterSpacing: 0.8,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 20,
                color: valueColor ?? textPrimary,
              ),
            ),
            if (sub != null) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                sub,
                style: pw.TextStyle(font: ttfLight, fontSize: 8, color: subColor ?? textMuted),
              ),
            ],
          ],
        ),
      );
    }

    pw.Widget _sectionHeader(String title, {PdfColor? iconBg, String? count}) {
      final baseColor = iconBg ?? primaryColor;
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 18,
                decoration: pw.BoxDecoration(
                  color: baseColor,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(title, style: pw.TextStyle(font: ttfBold, fontSize: 13, color: textPrimary)),
            ],
          ),
          if (count != null)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: pw.BoxDecoration(
                color: PdfColor(baseColor.red, baseColor.green, baseColor.blue, 0.15),
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Text(
                count,
                style: pw.TextStyle(font: ttfBold, fontSize: 8, color: baseColor),
              ),
            ),
        ],
      );
    }

    pw.Widget _tableHeader(List<String> cols, List<double> flex) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const pw.BoxDecoration(color: bgLight),
        child: pw.Row(
          children: List.generate(cols.length, (i) {
            return pw.Expanded(
              flex: (flex[i] * 10).toInt(),
              child: pw.Text(
                cols[i].toUpperCase(),
                style: pw.TextStyle(font: ttfMedium, fontSize: 7, color: textMuted, letterSpacing: 0.6),
              ),
            );
          }),
        ),
      );
    }

    pw.Widget _divider() => pw.Container(height: 0.5, color: cardShadow);

    // ── PAGE 1 ─────────────────────────────────────────────────────
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => [
          // ── HERO HEADER ──────────────────────────────────────────
          pw.Container(
            width: double.infinity,
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [primaryColor, accentColor],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 28),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      actualGymName,
                      style: pw.TextStyle(font: ttfBold, fontSize: 22, color: white),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Membership & Revenue Report',
                      style: pw.TextStyle(font: ttfLight, fontSize: 11, color: const PdfColor.fromInt(0xB2FFFFFF)),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColor(white.red, white.green, white.blue, 0.2),
                        borderRadius: pw.BorderRadius.circular(20),
                        border: pw.Border.all(color: const PdfColor.fromInt(0x61FFFFFF), width: 0.8),
                      ),
                      child: pw.Text(
                        dateRange,
                        style: pw.TextStyle(font: ttfMedium, fontSize: 9, color: white),
                      ),
                    ),
                  ],
                ),
                if (logoImage != null)
                  pw.Container(
                    width: 64,
                    height: 64,
                    decoration: pw.BoxDecoration(
                      color: white,
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: PdfColors.white, width: 2),
                    ),
                    child: pw.ClipOval(child: pw.Image(logoImage, fit: pw.BoxFit.cover)),
                  )
                else
                  pw.Container(
                    width: 64,
                    height: 64,
                    decoration: pw.BoxDecoration(
                      color: PdfColor(white.red, white.green, white.blue, 0.25),
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        actualGymName.isNotEmpty ? actualGymName[0].toUpperCase() : 'G',
                        style: pw.TextStyle(font: ttfBold, fontSize: 28, color: white),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── BODY ─────────────────────────────────────────────────
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                // ── SUMMARY STRIP ─────────────────────────────────
                pw.Text(
                  'SUMMARY OVERVIEW',
                  style: pw.TextStyle(font: ttfMedium, fontSize: 8, color: textMuted, letterSpacing: 1.2),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _metricCard(
                        label: 'Active Members',
                        value: '$active',
                        sub: 'Currently active',
                        valueColor: successGreen,
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: _metricCard(
                        label: 'Overdue Members',
                        value: '$overdue',
                        sub: 'Payment pending',
                        valueColor: dangerRed,
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: _metricCard(
                        label: 'New Joiners',
                        value: '$newJoiners',
                        sub: 'In this period',
                        valueColor: primaryColor,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          gradient: const pw.LinearGradient(
                            colors: [primaryColor, accentColor],
                            begin: pw.Alignment.topLeft,
                            end: pw.Alignment.bottomRight,
                          ),
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'TOTAL REVENUE',
                                  style: pw.TextStyle(font: ttfMedium, fontSize: 7, color: const PdfColor.fromInt(0xB2FFFFFF), letterSpacing: 0.8),
                                ),
                                pw.SizedBox(height: 6),
                                pw.Text(
                                  'Rs. $revenue',
                                  style: pw.TextStyle(font: ttfBold, fontSize: 22, color: white),
                                ),
                              ],
                            ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColor(white.red, white.green, white.blue, 0.2),
                                    borderRadius: pw.BorderRadius.circular(8),
                                  ),
                                  child: pw.Text('UPI: Rs. $upi',
                                      style: pw.TextStyle(font: ttfBold, fontSize: 8, color: white)),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColor(white.red, white.green, white.blue, 0.2),
                                    borderRadius: pw.BorderRadius.circular(8),
                                  ),
                                  child: pw.Text('Cash: Rs. $cash',
                                      style: pw.TextStyle(font: ttfBold, fontSize: 8, color: white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: _metricCard(
                        label: 'Total Expenses',
                        value: 'Rs. $expenses',
                        sub: 'Operational costs',
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: _metricCard(
                        label: 'Remaining Amount',
                        value: 'Rs. $unpaid',
                        sub: 'Dues outstanding',
                        valueColor: dangerRed,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 24),

                // ── OVERDUE MEMBERS ───────────────────────────────
                _sectionHeader(
                  'Overdue Members',
                  iconBg: dangerRed,
                  count: '${overdueMembers.length}',
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: white,
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: cardShadow),
                  ),
                  child: pw.Column(
                    children: [
                      _tableHeader(['Member', 'Membership End', 'Overdue Days', 'Due Amount'], [2.5, 1.8, 1.5, 1.5]),
                      ...List.generate(overdueMembers.length, (i) {
                        final m = overdueMembers[i];
                        int overdueDays = 0;
                        if (m['membershipEndDate'] != null) {
                          final end = DateTime.tryParse(m['membershipEndDate']);
                          if (end != null) overdueDays = DateTime.now().difference(end).inDays;
                        }
                        final endDateStr = m['membershipEndDate'] != null
                            ? DateFormat('dd MMM yyyy').format(DateTime.parse(m['membershipEndDate']))
                            : '—';
                        return pw.Column(
                          children: [
                            _divider(),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                              child: pw.Row(
                                children: [
                                  pw.Expanded(
                                    flex: 25,
                                    child: pw.Row(
                                      children: [
                                        pw.Container(
                                          width: 28,
                                          height: 28,
                                          decoration: pw.BoxDecoration(
                                            color: PdfColor(dangerRed.red, dangerRed.green, dangerRed.blue, 0.12),
                                            shape: pw.BoxShape.circle,
                                          ),
                                          child: pw.Center(
                                            child: pw.Text(
                                              _ini(m['name']),
                                              style: pw.TextStyle(font: ttfBold, fontSize: 9, color: dangerRed),
                                            ),
                                          ),
                                        ),
                                        pw.SizedBox(width: 8),
                                        pw.Text(
                                          m['name'] ?? 'Unknown',
                                          style: pw.TextStyle(font: ttfMedium, fontSize: 10, color: textPrimary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 18,
                                    child: pw.Text(endDateStr,
                                        style: pw.TextStyle(font: ttf, fontSize: 9, color: textMuted)),
                                  ),
                                  pw.Expanded(
                                    flex: 15,
                                    child: pw.Container(
                                      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: pw.BoxDecoration(
                                        color: PdfColor(dangerRed.red, dangerRed.green, dangerRed.blue, 0.1),
                                        borderRadius: pw.BorderRadius.circular(6),
                                      ),
                                      child: pw.Text(
                                        '$overdueDays days',
                                        style: pw.TextStyle(font: ttfBold, fontSize: 8, color: dangerRed),
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 15,
                                    child: pw.Text(
                                      'Rs. ${m['remainingAmount'] ?? 0}',
                                      style: pw.TextStyle(font: ttfBold, fontSize: 10, color: dangerRed),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                      if (overdueMembers.isEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(16),
                          child: pw.Center(
                            child: pw.Text('No overdue members',
                                style: pw.TextStyle(font: ttfLight, fontSize: 10, color: textMuted)),
                          ),
                        ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 24),

                // ── RECENT RENEWALS ───────────────────────────────
                _sectionHeader(
                  'Recent Renewals',
                  iconBg: successGreen,
                  count: '${recentRenewals.length}',
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: white,
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: cardShadow),
                  ),
                  child: pw.Column(
                    children: [
                      _tableHeader(['Member', 'Membership End', 'Days Left', 'Status'], [2.5, 1.8, 1.5, 1.5]),
                      ...List.generate(recentRenewals.length, (i) {
                        final m = recentRenewals[i];
                        int daysLeft = 0;
                        if (m['membershipEndDate'] != null) {
                          final end = DateTime.tryParse(m['membershipEndDate']);
                          if (end != null) daysLeft = end.difference(DateTime.now()).inDays;
                        }
                        final endDateStr = m['membershipEndDate'] != null
                            ? DateFormat('dd MMM yyyy').format(DateTime.parse(m['membershipEndDate']))
                            : '—';
                        final isExpiringSoon = daysLeft <= 7;
                        return pw.Column(
                          children: [
                            _divider(),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                              child: pw.Row(
                                children: [
                                  pw.Expanded(
                                    flex: 25,
                                    child: pw.Row(
                                      children: [
                                        pw.Container(
                                          width: 28,
                                          height: 28,
                                          decoration: pw.BoxDecoration(
                                            color: PdfColor(successGreen.red, successGreen.green, successGreen.blue, 0.12),
                                            shape: pw.BoxShape.circle,
                                          ),
                                          child: pw.Center(
                                            child: pw.Text(
                                              _ini(m['name']),
                                              style: pw.TextStyle(font: ttfBold, fontSize: 9, color: successGreen),
                                            ),
                                          ),
                                        ),
                                        pw.SizedBox(width: 8),
                                        pw.Text(
                                          m['name'] ?? 'Unknown',
                                          style: pw.TextStyle(font: ttfMedium, fontSize: 10, color: textPrimary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 18,
                                    child: pw.Text(endDateStr,
                                        style: pw.TextStyle(font: ttf, fontSize: 9, color: textMuted)),
                                  ),
                                  pw.Expanded(
                                    flex: 15,
                                    child: pw.Text(
                                      '$daysLeft days',
                                      style: pw.TextStyle(
                                        font: ttfBold,
                                        fontSize: 9,
                                        color: isExpiringSoon ? dangerRed : successGreen,
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 15,
                                    child: pw.Container(
                                      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: pw.BoxDecoration(
                                        color: isExpiringSoon 
                                          ? PdfColor(dangerRed.red, dangerRed.green, dangerRed.blue, 0.1) 
                                          : PdfColor(successGreen.red, successGreen.green, successGreen.blue, 0.1),
                                        borderRadius: pw.BorderRadius.circular(6),
                                      ),
                                      child: pw.Text(
                                        isExpiringSoon ? 'Expiring Soon' : 'Active',
                                        style: pw.TextStyle(
                                          font: ttfBold,
                                          fontSize: 7.5,
                                          color: isExpiringSoon ? dangerRed : successGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                      if (recentRenewals.isEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(16),
                          child: pw.Center(
                            child: pw.Text('No recent renewals',
                                style: pw.TextStyle(font: ttfLight, fontSize: 10, color: textMuted)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: cardShadow, width: 0.8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '$actualGymName — Confidential',
                style: pw.TextStyle(font: ttfLight, fontSize: 8, color: textMuted),
              ),
              pw.Text(
                'Generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}  •  Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(font: ttfLight, fontSize: 8, color: textMuted),
              ),
            ],
          ),
        ),
      ),
    );

    // ── Print / Share / Download ───────────────────────────────────
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${actualGymName.replaceAll(' ', '_')}_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }
}