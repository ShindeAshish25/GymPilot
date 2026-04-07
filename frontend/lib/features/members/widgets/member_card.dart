// import 'package:flutter/material.dart';
// import 'package:frontend/core/constants/app_colors.dart';
// import 'package:frontend/data/models/member_model.dart';
// import 'package:intl/intl.dart';

// class MemberCard extends StatelessWidget {
//   final MemberModel member;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const MemberCard({
//     super.key,
//     required this.member,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isActive = member.status == 'ACTIVE' || member.status == 'EXPIRING SOON';
    
//     // Mock data for display based on design if missing
//     final planName = member.trainingType?.isNotEmpty == true ? member.trainingType! : 'Premium Yearly';
    
//     int daysDiff = 0;
//     if (member.membershipEndDate != null) {
//       daysDiff = member.membershipEndDate!.difference(DateTime.now()).inDays;
//     }
    
//     String expiryText = '';
//     Color expiryColor = AppColors.textSecondary;
//     if (member.status == 'OVERDUE') {
//       expiryText = 'Overdue by ${daysDiff.abs()} days';
//       expiryColor = AppColors.error;
//     } else {
//       expiryText = 'Expires in $daysDiff days';
//       if (daysDiff <= 14) {
//         expiryColor = AppColors.error;
//       } else {
//         expiryColor = AppColors.primary;
//       }
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Avatar with status indicator
//           Stack(
//             children: [
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: AppColors.surfaceLight,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 2),
//                 ),
//                 child: member.photoUrl != null && member.photoUrl!.isNotEmpty
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(30),
//                         child: Image.network(
//                           member.photoUrl!,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               const Icon(Icons.person, color: AppColors.textMuted, size: 30),
//                         ),
//                       )
//                     : Icon(Icons.person, color: AppColors.primary.withOpacity(0.5), size: 30),
//               ),
//               Positioned(
//                 bottom: 2,
//                 right: 2,
//                 child: Container(
//                   width: 14,
//                   height: 14,
//                   decoration: BoxDecoration(
//                     color: isActive ? Colors.green : Colors.grey,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 16),
//           // Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   member.name,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Plan: $planName',
//                   style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   expiryText,
//                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: expiryColor),
//                 ),
//               ],
//             ),
//           ),
//           // Actions
//           IconButton(
//             icon: const Icon(Icons.edit, color: AppColors.textMuted, size: 20),
//             onPressed: onEdit,
//             constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
//             padding: EdgeInsets.zero,
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete, color: AppColors.textMuted, size: 20),
//             onPressed: onDelete,
//             constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
//             padding: EdgeInsets.zero,
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/features/members/widgets/member_card.dart
// ✅ Tap card → opens MemberDetailPopup | Accurate expiry days | Renew badge

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/features/members/widgets/member_detail_popup.dart';

class MemberCard extends StatelessWidget {
  final MemberModel member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onRenewed;

  const MemberCard({
    super.key,
    required this.member,
    required this.onEdit,
    required this.onDelete,
    this.onRenewed,
  });

  Color get _statusColor {
    if (member.isCriticallyOverdue) return const Color(0xFFEF4444); // Red
    if (member.isRecentlyOverdue) return const Color(0xFFF59E0B); // Yellow
    if (member.hasPendingPayment) return const Color(0xFFF59E0B); // Yellow
    return const Color(0xFF10B981); // Green
  }

  String get _expiryText {
    final days = member.daysUntilExpiry;
    if (days >= 9999) return 'No Expiry';
    if (days < 0) return 'Expired ${days.abs()}d ago';
    if (days == 0) return 'Expires today!';
    if (days == 1) return 'Expires tomorrow';
    return 'Expires in ${days}d';
  }

  String get _planLabel {
    final training = member.trainingType;
    if (training?.isNotEmpty == true) return training!;
    final dur = member.membershipDuration ?? 1;
    return '$dur Month${dur > 1 ? 's' : ''} Plan';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showMemberDetailPopup(
        context,
        member,
        onEdit: onEdit,
        onDeleted: onDelete,
        onRenewed: onRenewed,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: member.daysUntilExpiry >= 0
              ? Border.all(color: AppColors.success.withOpacity(0.4), width: 1.5)
              : (member.isCriticallyOverdue || member.hasPendingPayment)
                  ? Border.all(color: _statusColor.withOpacity(0.25))
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _statusColor.withOpacity(0.4), width: 2),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipOval(
                    child: member.photoUrl?.isNotEmpty == true
                        ? Image.network(member.photoUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _defaultAvatar)
                        : _defaultAvatar,
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 13, height: 13,
                    decoration: BoxDecoration(
                      color: _statusColor, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
 
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(_planLabel,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(member.isCriticallyOverdue ? Icons.warning_amber_rounded : Icons.access_time_rounded,
                          size: 11, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(_expiryText,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor)),
                    ],
                  ),
                ],
              ),
            ),
 
            // Right side
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Renew badge for expiring/expired
                if (member.daysUntilExpiry <= 7)
                  GestureDetector(
                    onTap: () => showRenewMembershipModal(context, member, onRenewed: onRenewed),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.autorenew_rounded, size: 11, color: _statusColor),
                          const SizedBox(width: 3),
                          Text('Renew',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _statusColor)),
                        ],
                      ),
                    ),
                  )
                else if (member.batch?.isNotEmpty == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(member.batch!,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                const SizedBox(height: 8),
                Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get _defaultAvatar =>
      Icon(Icons.person_rounded, size: 26, color: AppColors.primary.withOpacity(0.4));
}
