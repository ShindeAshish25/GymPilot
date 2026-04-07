import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/attendance_provider.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  late MobileScannerController controller;
  String? scannedMemberId;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _processCheckIn() async {
    if (scannedMemberId == null) return;
    
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final success = await attendanceProvider.checkIn(scannedMemberId!);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Check-in Successful!' : 'Check-in Failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        setState(() {
          scannedMemberId = null; // Reset for next scan
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Check-In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: scannedMemberId == null ? MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                      final code = barcodes.first.rawValue;
                      if (scannedMemberId != code) {
                        setState(() {
                          scannedMemberId = code;
                        });
                      }
                    }
                  },
                ) : const Center(child: Icon(Icons.check_circle, color: Colors.green, size: 100)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              scannedMemberId == null ? 'Scan QR Code to Check In' : 'QR Found!', 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            if (scannedMemberId != null) ...[
              Text('Scanned ID: $scannedMemberId', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 32),
              Consumer<AttendanceProvider>(
                builder: (context, attendance, child) {
                  return ElevatedButton(
                    onPressed: attendance.isLoading ? null : _processCheckIn,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: attendance.isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Confirm Check-in', style: TextStyle(fontSize: 18)),
                  );
                }
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => scannedMemberId = null),
                child: const Text('Rescan', style: TextStyle(color: Colors.red)),
              )
            ]
          ],
        ),
      ),
    );
  }
}
