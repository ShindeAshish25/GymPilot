import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO Either replace the Background image UI as the text color are overlapping into it.
    // TODO Need to add Constant font size and decoration into Constant file to make it common
    return Scaffold(
      body: Stack(
        children: [
          // TODO Background Image with Overlay and also replace the inside need vertical type image not horizontal
          Image.network('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=2070&auto=format&fit=crop',
            fit: BoxFit.fill,width: double.infinity,height: double.infinity,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo / Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fitness_center, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Gympilot',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),

                const Spacer(),

                // Welcome Text
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flash_on, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'TRANSFORM YOUR LIFE',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).scale(),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome to',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                    const Text(
                      'Gympilot',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 20),
                    Text(
                      'The ultimate gym management experience. Streamline your workouts, track your progress, and join a community of fitness enthusiasts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),

                const SizedBox(height: 48),
                const Spacer(),

                // Action Buttons
                Column(
                  children: [
                    GradientButton(
                      text: 'Sign Up',
                      onPressed: () => context.push('/signup'),
                      suffixIcon: const Icon(Icons.arrow_forward, color: Colors.white),
                    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => context.push('/login'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
