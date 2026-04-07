import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/providers/member_provider.dart';
import 'package:frontend/features/members/widgets/member_premium_popup.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Notifications', 
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<MemberProvider>(
        builder: (context, provider, child) {
          final expiring = provider.expiringSoonMembers;
          final overdue = provider.recentlyOverdueMembers;
          
          // Combine real notifications from members
          final notifications = [
            ...expiring.map((m) => NotificationItem(
              title: m.name,
              message: 'Membership expiring in ${m.daysUntilExpiry} days',
              member: m,
              type: 'expiry',
              isRead: false,
            )),
            ...overdue.map((m) => NotificationItem(
              title: m.name,
              message: 'Membership overdue by ${m.daysUntilExpiry.abs()} days',
              member: m,
              type: 'overdue',
              isRead: false,
            )),
          ];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) => _buildNotificationCard(context, notifications[index]),
                ),
              ),
              _buildPagination(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item) {
    return GestureDetector(
      onTap: () => showMemberPremiumPopup(context, item.member),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with status
            Stack(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: item.member.photoUrl != null && item.member.photoUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(item.member.photoUrl!), fit: BoxFit.cover)
                      : null,
                    color: Colors.grey.shade100,
                  ),
                  child: (item.member.photoUrl == null || item.member.photoUrl!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey) 
                    : null,
                ),
                if (item.type == 'expiry' || item.type == 'overdue')
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: item.type == 'expiry' ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(item.message, 
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4D67),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PaginationButton(label: 'Previous', icon: Icons.chevron_left, isDisabled: true),
          const SizedBox(width: 8),
          _PageNumber(number: 1, isActive: true),
          _PageNumber(number: 2, isActive: false),
          _PageNumber(number: 3, isActive: false),
          const SizedBox(width: 8),
          _PaginationButton(label: 'Next', icon: Icons.chevron_right, isTrailing: true),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No new notifications', 
            style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final MemberModel member;
  final String type;
  final bool isRead;
  NotificationItem({
    required this.title, 
    required this.message, 
    required this.member, 
    this.type = 'general', 
    this.isRead = false
  });
}

class _PaginationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDisabled;
  final bool isTrailing;
  const _PaginationButton({required this.label, required this.icon, this.isDisabled = false, this.isTrailing = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (!isTrailing) Icon(icon, size: 16, color: isDisabled ? Colors.grey : Colors.black),
          if (!isTrailing) const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDisabled ? Colors.grey : Colors.black)),
          if (isTrailing) const SizedBox(width: 4),
          if (isTrailing) Icon(icon, size: 16, color: isDisabled ? Colors.grey : Colors.black),
        ],
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final int number;
  final bool isActive;
  const _PageNumber({required this.number, required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF4D67) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text('$number', 
        style: TextStyle(fontSize: 14, color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.w700)),
    );
  }
}
