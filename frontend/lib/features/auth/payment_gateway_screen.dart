import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final Map<String, dynamic> signupData;

  const PaymentGatewayScreen({super.key, required this.signupData});

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  int _selectedPaymentMethod = 1; // Default to Card for autopayment
  bool _isPaymentSuccessful = false;
  bool _isRegistering = false;

  @override
  Widget build(BuildContext context) {
    final bool isFreeTrial = widget.signupData['isFreeTrial'] ?? false;
    final String months = (widget.signupData['fields']?['subscriptionMonths'] ?? '1');
    
    // Dynamic Pricing Logic
    double totalAmount = 0.0;
    double baseAmount = 0.0;
    double gstAmount = 0.0;
    String planName = '';
    String planDetails = '';

    if (isFreeTrial) {
      totalAmount = 2.0;
      baseAmount = 2.0;
      gstAmount = 0.0;
      planName = '1-Month Free Trial';
      planDetails = 'Autopayment Setup • Verification Fee';
    } else {
      // Prices from Signup Cards
      if (months == '12') {
        baseAmount = 14999.0;
      } else if (months == '3') {
        baseAmount = 3999.0;
      } else {
        baseAmount = 1499.0;
      }
      gstAmount = baseAmount * 0.18;
      totalAmount = baseAmount + gstAmount;
      planName = '$months Months Membership';
      planDetails = 'Valid for ${int.parse(months) * 30} days • All Centers';
    }

    final String totalAmountStr = totalAmount.toStringAsFixed(2);
    final String baseAmountStr = baseAmount.toStringAsFixed(2);
    final String gstAmountStr = gstAmount.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF82F56),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildMainContent(context, planName, planDetails, baseAmountStr, gstAmountStr, totalAmountStr),
          if (_isPaymentSuccessful) _buildSuccessOverlay(context),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, String planName, String planDetails, String baseAmountStr, String gstAmountStr, String totalAmountStr) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Wavy Background
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF82F56),
                        Color(0xFFFF4D6D),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'TOTAL PAYABLE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹$totalAmountStr',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Membership Card
              Positioned(
                top: 140,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8EC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.fitness_center_rounded, color: Color(0xFFF82F56), size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              planName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              planDetails,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF757575),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
              ),
            ],
          ),

          const SizedBox(height: 100), // Space for the floating card

          // Invoice Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INVOICE DETAILS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF9E9E9E),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInvoiceRow('Base Subscription', '₹$baseAmountStr'),
                const SizedBox(height: 16),
                _buildInvoiceRow('GST (18%)', '₹$gstAmountStr'),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFEEEEEE), height: 32),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      '₹$totalAmountStr',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFF82F56),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Payment Methods
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SELECT PAYMENT METHOD',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF9E9E9E),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPaymentOption(
                  index: 0,
                  icon: Icons.qr_code_rounded,
                  title: 'UPI Payments',
                  subtitle: 'Google Pay, PhonePe, Paytm',
                ),
                const SizedBox(height: 16),
                _buildPaymentOption(
                  index: 1,
                  icon: Icons.credit_card_rounded,
                  title: 'Credit / Debit Card',
                  subtitle: 'Visa, Mastercard, RuPay',
                ),
                const SizedBox(height: 16),
                _buildPaymentOption(
                  index: 2,
                  icon: Icons.account_balance_rounded,
                  title: 'Net Banking',
                  subtitle: 'All Indian Banks supported',
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Pay Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: (_isRegistering || _isPaymentSuccessful) ? null : () async {
                      setState(() => _isRegistering = true);
                      
                      try {
                        // 1. Simulate Payment Delay
                        await Future.delayed(const Duration(seconds: 2));
                        
                        // 2. Perform actual Registration on Backend
                        final authProvider = context.read<AuthProvider>();
                        final fields = Map<String, String>.from(widget.signupData['fields'] ?? {});
                        final logoBytes = widget.signupData['logoBytes'];
                        final logoName = widget.signupData['logoName'];

                        if (logoBytes == null) throw Exception('Logo missing');

                        final success = await authProvider.signup(fields, logoBytes, logoName);
                        
                        if (success && mounted) {
                          setState(() {
                            _isRegistering = false;
                            _isPaymentSuccessful = true;
                          });
                          
                          // 3. Redirect after showing success animation
                          Future.delayed(const Duration(seconds: 3), () {
                            if (mounted) {
                              context.go('/login');
                            }
                          });
                        }
                      } catch (e) {
                        setState(() => _isRegistering = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF82F56),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFFF82F56).withValues(alpha: 0.4),
                    ),
                    child: _isRegistering 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          'Proceed to Pay ₹$totalAmountStr',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 6),
                    const Text(
                      'Secure 256-bit SSL Encrypted Payment',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF424242),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessOverlay(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/success.json', // Premium Checkmark
                width: 150,
                height: 150,
                repeat: false,
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Success!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your gym partner account is now active. Welcome to Gympilot!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF82F56).withAlpha(128) : const Color(0xFFF0F0F0),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFF82F56) : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF82F56),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Icon(icon, color: const Color(0xFF424242), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 20);
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
