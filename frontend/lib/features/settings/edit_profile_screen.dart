import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinput/pinput.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/glass_container.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _otpController;
  String? _initialEmail;
  bool _isEmailVerified = false;
  bool _showOtpSection = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().userProfile;
    _nameController = TextEditingController(text: profile?['fullName']);
    _initialEmail = profile?['email'];
    _emailController = TextEditingController(text: _initialEmail);
    _phoneController = TextEditingController(text: profile?['mobileNumber']);
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _initialEmail = null;
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please enter a valid email'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    try {
      await context.read<AuthProvider>().sendOtp(_emailController.text);
      setState(() => _showOtpSection = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('OTP sent to your new email'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _verifyOtp() async {
    if (_otpController.text.length < 6) return;
    try {
      final success = await context.read<AuthProvider>().verifyOtp(_emailController.text, _otpController.text);
      if (success) {
        setState(() {
          _isEmailVerified = true;
          _showOtpSection = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Email verified successfully'), backgroundColor: AppColors.success),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final emailChanged = _emailController.text != _initialEmail;
    if (emailChanged && !_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please verify your new email first'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final data = {
      'fullName': _nameController.text,
      'email': _emailController.text,
      'mobileNumber': _phoneController.text,
    };

    try {
      final success = await context.read<AuthProvider>().updateProfile(data);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Profile updated successfully'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.accentYellow)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surface,
                      child: const Icon(Icons.person, size: 50, color: AppColors.textSecondary),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accentYellow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ).animate().scale(),
              ),
              const SizedBox(height: 40),
              const Text(
                'Profile',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              _buildFieldLabel('Name'),
              _buildTextField(_nameController, '*Name', Icons.person_outline),
              
              _buildFieldLabel('Email'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _emailController, 
                      '*Email', 
                      Icons.email_outlined,
                      onChanged: (val) {
                        setState(() {
                          _isEmailVerified = val == _initialEmail;
                          if (val == _initialEmail) _showOtpSection = false;
                        });
                      },
                    ),
                  ),
                  if (_emailController.text != _initialEmail && !_isEmailVerified)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 20),
                      child: TextButton(
                        onPressed: isLoading ? null : _sendOtp,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.accentYellow.withOpacity(0.1),
                          foregroundColor: AppColors.accentYellow,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Verify'),
                      ),
                    ),
                  if (_isEmailVerified && _emailController.text != _initialEmail)
                    const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 20),
                      child: Icon(Icons.check_circle, color: AppColors.success),
                    ),
                ],
              ),
              
              if (_showOtpSection) ...[
                const Text('Enter 6-digit OTP', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Pinput(
                  length: 6,
                  controller: _otpController,
                  onCompleted: (_) => _verifyOtp(),
                  defaultPinTheme: PinTheme(
                    width: 45,
                    height: 50,
                    textStyle: const TextStyle(color: Colors.white, fontSize: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              _buildFieldLabel('Phone Number'),
              _buildTextField(_phoneController, '*Phone Number', Icons.phone_android_outlined),
              
              const SizedBox(height: 32),
              isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentYellow.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '*$label',
        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {bool readOnly = false, Function(String)? onChanged}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          fillColor: AppColors.surface,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (value) => value == null || value.isEmpty ? 'This field cannot be empty' : null,
      ),
    );
  }
}
