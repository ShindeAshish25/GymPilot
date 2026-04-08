import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/member_model.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/notifications/notifications_screen.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int notificationCount;

  const AppHeader({
    super.key,
    this.title = '',
    this.notificationCount = 0, // Fallback, now using provider
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Logo + Gym Name
            Row(
              children: [
                if (context.canPop())
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: AppColors.textPrimary),
                        onPressed: () => context.pop()),
                  ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final gymName = auth.userProfile?['gymName'] ?? 'GymPro';
                    return Text(
                      title.isNotEmpty ? title : gymName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    );
                  },
                ),
              ],
            ),
            // Right: Notification + Profile
            Row(
              children: [
                Consumer<MemberProvider>(
                  builder: (context, memberProvider, _) {
                    final count = memberProvider.expiringSoonMembers.length + 
                                  memberProvider.recentlyOverdueMembers.length;
                    return _NotificationBell(
                      count: count,
                    );
                  },
                ),
                const SizedBox(width: 12),
                _ProfileAvatar(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  const _NotificationBell({required this.count});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/profile');
      },
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final logoUrl = auth.userProfile?['logoUrl'] as String?;
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surfaceLight,
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: logoUrl != null && logoUrl.isNotEmpty
                  ? Image.network(
                      logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultAvatar(),
                    )
                  : _defaultAvatar(),
            ),
          );
        },
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
    );
  }
}

