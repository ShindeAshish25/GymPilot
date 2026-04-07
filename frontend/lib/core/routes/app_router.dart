import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/forgot_password_view.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/dashboard/dashboard_shell.dart';
import '../../features/settings/profile_setting_screen.dart';
import '../../features/settings/edit_profile_screen.dart';
import '../../features/settings/gym_info_screen.dart';
import '../../features/settings/membership_screen.dart';
import '../../features/members/customer_list_screen.dart';
import '../../features/members/overdue_screen.dart';
import '../../features/members/all_members_screen.dart';
import '../../features/attendance/qr_scan_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/trainers/trainer_screen.dart';
import '../../features/expenses/expense_screen.dart';

import '../../features/auth/welcome_screen.dart';
import '../../features/auth/payment_gateway_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/payment-gateway',
        builder: (context, state) {
          final signupData = state.extra as Map<String, dynamic>?;
          return PaymentGatewayScreen(signupData: signupData ?? {});
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return DashboardShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/members',
            builder: (context, state) => const CustomerListScreen(),
          ),
          GoRoute(
            path: '/overdue',
            builder: (context, state) => const OverdueScreen(),
          ),
          GoRoute(
            path: '/all-members',
            builder: (context, state) => const AllMembersScreen(),
          ),
          GoRoute(
            path: '/trainers',
            builder: (context, state) => const TrainerScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileSettingScreen(),
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/gym-info',
            builder: (context, state) => const GymInfoScreen(),
          ),
          GoRoute(
            path: '/membership',
            builder: (context, state) => const MembershipScreen(),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpenseScreen(),
          ),
        ],
      ),
    ],
  );
}
