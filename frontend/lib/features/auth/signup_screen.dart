import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';
import 'payment_gateway_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  XFile? _logo;
  Uint8List? _logoBytes;
  String _selectedPlan = '12'; // Default to 12 months
  bool _isFreeTrial = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _gymNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isEmailVerified = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _logo = image;
        _logoBytes = bytes;
      });
    }
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
      return;
    }

    setState(() => _isSendingOtp = true);
    try {
      await context.read<AuthProvider>().sendOtp(_emailController.text);
      setState(() => _isOtpSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent! Please check your email or terminal.')));
      }
    } catch (e) {
      // Even if email fails, we show the OTP field so the user can use the terminal-logged OTP
      setState(() => _isOtpSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Note: Email delivery failed, but you can find the OTP in the backend terminal.'),
          duration: const Duration(seconds: 5),
        ));
      }
    } finally {
      setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter 6-digit OTP')));
      return;
    }

    setState(() => _isVerifyingOtp = true);
    try {
      final success = await context.read<AuthProvider>().verifyOtp(_emailController.text, _otpController.text);
      if (success) {
        setState(() => _isEmailVerified = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email verified successfully')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    } finally {
      setState(() => _isVerifyingOtp = false);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_logo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload your Gym logo')),
        );
        return;
      }
      if (!_isEmailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify your email via OTP first')),
        );
        return;
      }

      final fields = {
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'mobileNumber': _mobileController.text,
        'gymName': _gymNameController.text,
        'password': _passwordController.text,
        'subscriptionMonths': _selectedPlan,
        'isFreeTrial': _isFreeTrial.toString(),
        'address': 'Not specified',
      };

      // Navigate to Payment Gateway FIRST - The registration call happens AFTER payment success
      context.push('/payment-gateway', extra: {
        'fields': fields,
        'logoBytes': _logoBytes,
        'logoName': _logo!.name,
        'isFreeTrial': _isFreeTrial,
        'selectedPlan': _selectedPlan,
        'planName': _isFreeTrial ? 'Free Trial' : (_selectedPlan == '12' ? 'Annual' : 'Quarterly'),
        'totalAmount': _isFreeTrial ? 2.0 : (_selectedPlan == '12' ? 14999.0 : 3999.0),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Partner Portal',
          style: TextStyle(color: AppColors.darkSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Upload Section
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: ClipOval(
                          child: _logoBytes != null 
                            ? Image.memory(_logoBytes!, fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.fitness_center, size: 40, color: AppColors.textMuted.withValues(alpha: 0.5)),
                                  const SizedBox(height: 4),
                                  const Text('GYM LOGO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                                ],
                              ),
                        ),
                      ),
                      GestureDetector(
                        onTap: isLoading ? null : _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ).animate().scale(duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Join the Network',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkSurface,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const Text(
                    'Grow your fitness business today',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  
                  const SizedBox(height: 40),
                  
                  // Form Fields in a Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Owner\'s Full Name'),
                        _buildRoundedTextField(_fullNameController, 'John Doe', Icons.person_outline_rounded),
                        
                        const SizedBox(height: 20),
                        _buildLabel('Gym Name'),
                        _buildRoundedTextField(_gymNameController, 'Elite Fitness Center', Icons.storefront_rounded),
                        
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('Email Address'),
                            if (!_isEmailVerified)
                              GestureDetector(
                                onTap: _isSendingOtp ? null : _sendOtp,
                                child: Text(
                                  _isSendingOtp ? 'Sending...' : 'Verify OTP',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                          ],
                        ),
                        _buildRoundedTextField(
                          _emailController, 
                          'owner@gymname.com', 
                          Icons.mail_outline_rounded,
                          readOnly: _isEmailVerified,
                          suffixIcon: _isEmailVerified ? const Icon(Icons.check_circle, color: Colors.green, size: 20) : null,
                        ),

                        if (_isOtpSent && !_isEmailVerified) ...[
                          const SizedBox(height: 20),
                          _buildLabel('Enter 6-Digit OTP'),
                          _buildRoundedTextField(
                            _otpController, 
                            'Enter OTP from terminal/email', 
                            Icons.lock_open_rounded,
                            keyboardType: TextInputType.number,
                            suffixIcon: _isVerifyingOtp 
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.verified_user_rounded, color: AppColors.primary),
                                  onPressed: _verifyOtp,
                                ),
                          ).animate().fadeIn().shake(),
                        ],

                        const SizedBox(height: 20),
                        _buildLabel('Mobile Number'),
                        _buildRoundedTextField(_mobileController, '+1 (555) 000-0000', Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                        
                        const SizedBox(height: 20),
                        _buildLabel('Password'),
                        _buildRoundedTextField(
                          _passwordController, 
                          '••••••••', 
                          Icons.lock_outline_rounded, 
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        
                        const SizedBox(height: 20),
                        _buildLabel('Confirm Password'),
                        _buildRoundedTextField(
                          _confirmPasswordController, 
                          '••••••••', 
                          Icons.lock_outline_rounded, 
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),

                        const SizedBox(height: 24),
                        _buildLabel('Choose Your Plan'),
                        const SizedBox(height: 12),
                        
                        // Plan Selection Cards
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildPlanCard(
                                title: 'Free Trial',
                                duration: '1 Month',
                                price: '₹0',
                                description: '₹2.00 setup fee',
                                isTrial: true,
                              ),
                              const SizedBox(width: 12),
                              _buildPlanCard(
                                title: 'Quarterly',
                                duration: '3 Months',
                                price: '₹3,999',
                                description: 'Save 15%',
                                planValue: '3',
                              ),
                              const SizedBox(width: 12),
                              _buildPlanCard(
                                title: 'Annual',
                                duration: '12 Months',
                                price: '₹14,999',
                                description: 'Best Value (40% OFF)',
                                planValue: '12',
                                isBestValue: true,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        isLoading 
                          ? const Center(child: CircularProgressIndicator())
                          : GradientButton(
                              text: 'Signup Now',
                              onPressed: _isEmailVerified ? _submit : null,
                            ),
                        
                        const SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              const Text('By signing up, you agree to our ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              const Text('Terms of Service', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              const Text(' and ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              const Text('Privacy Policy', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 32),
                  Center(
                    child: TextButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have a partner account? ',
                          style: TextStyle(color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                              text: 'Log In',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  // Bottom Nav Placeholder
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomNavItem(Icons.home_filled, 'Home', true),
                      _buildBottomNavItem(Icons.info_outline, 'About', false),
                      _buildBottomNavItem(Icons.help_outline, 'Support', false),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkSurface),
      ),
    );
  }

  Widget _buildRoundedTextField(
    TextEditingController controller, 
    String hint, 
    IconData icon, {
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: AppColors.surfaceLight.withValues(alpha: 0.3),
        suffixIcon: suffixIcon ?? (isPassword 
          ? IconButton(
              icon: Icon(obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
              onPressed: onToggleVisibility,
            )
          : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        return null;
      },
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String duration,
    required String price,
    required String description,
    String? planValue,
    bool isTrial = false,
    bool isBestValue = false,
  }) {
    final bool isSelected = isTrial ? _isFreeTrial : (_selectedPlan == planValue && !_isFreeTrial);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isTrial) {
            _isFreeTrial = true;
            _selectedPlan = '1';
          } else {
            _isFreeTrial = false;
            _selectedPlan = planValue!;
          }
        });
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBestValue)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              duration,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkSurface,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              price,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? AppColors.primary : AppColors.textMuted, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
