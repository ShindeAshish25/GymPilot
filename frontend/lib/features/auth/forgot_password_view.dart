import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/glass_container.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 0;
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  void _nextStep() {
    setState(() => _currentStep++);
  }

  Future<void> _sendOTP() async {
    if (_emailController.text.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().sendOtp(_emailController.text);
      _nextStep();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter 6-digit OTP')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await context.read<AuthProvider>().verifyOtp(_emailController.text, _otpController.text);
      if (success) {
        _nextStep();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().resetPassword(
        _emailController.text, 
        _otpController.text, 
        _newPasswordController.text
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: _buildCurrentStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildOTPStep();
      case 2:
        return _buildResetStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.history, color: AppColors.primary, size: 40),
        ),
        const SizedBox(height: 32),
        const Text(
          'Reset your password',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.darkSurface),
        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        const Text(
          'Enter your email address to receive a 6-digit\nverification code to reset your gym account\npassword.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 48),
        Align(
          alignment: Alignment.centerLeft,
          child: const Text('   Email Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'e.g. member@powergym.com',
            prefixIcon: const Icon(Icons.mail_outline_rounded),
            filled: true,
            fillColor: AppColors.surfaceLight.withValues(alpha: 0.3),
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 32),
        GradientButton(
          text: 'Send OTP',
          isLoading: _isLoading,
          onPressed: _sendOTP,
          suffixIcon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
        ).animate().fadeIn(delay: 600.ms),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Remember your password? ', style: TextStyle(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Log In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOTPStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_user_outlined, color: AppColors.success, size: 40),
        ),
        const SizedBox(height: 32),
        const Text(
          'Verify OTP',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.darkSurface),
        ).animate().fadeIn(),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "We've sent a 6-digit code to\n",
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            children: [
              TextSpan(
                text: _emailController.text,
                style: const TextStyle(color: AppColors.darkSurface, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 48),
        Center(
          child: Pinput(
            length: 6,
            controller: _otpController,
            defaultPinTheme: PinTheme(
              width: 50,
              height: 60,
              textStyle: const TextStyle(fontSize: 24, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.surfaceLight, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surfaceLight.withValues(alpha: 0.2),
              ),
            ),
            focusedPinTheme: PinTheme(
              width: 50,
              height: 60,
              textStyle: const TextStyle(fontSize: 24, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
            ),
          ).animate().scale(delay: 400.ms),
        ),
        const SizedBox(height: 48),
        GradientButton(
          text: 'Verify OTP',
          isLoading: _isLoading,
          onPressed: _verifyOTP,
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Didn't receive code? ", style: TextStyle(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: _sendOTP,
              child: const Text('Resend OTP', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.key_outlined, color: AppColors.primary, size: 40),
        ),
        const SizedBox(height: 32),
        const Text(
          'Create New Password',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.darkSurface),
        ).animate().fadeIn(),
        const SizedBox(height: 12),
        const Text(
          'Your new password must be different from\nprevious used passwords.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.centerLeft,
          child: const Text('   New Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            filled: true,
            fillColor: AppColors.surfaceLight.withValues(alpha: 0.3),
            suffixIcon: const Icon(Icons.visibility_outlined, color: AppColors.textMuted),
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: const Text('   Confirm Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            filled: true,
            fillColor: AppColors.surfaceLight.withValues(alpha: 0.3),
          ),
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Password must be at least 8 characters long and include a mix of letters, numbers and symbols.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 40),
        GradientButton(
          text: 'Update Password',
          isLoading: _isLoading,
          onPressed: _resetPassword,
        ).animate().fadeIn(delay: 700.ms),
      ],
    );
  }
}
