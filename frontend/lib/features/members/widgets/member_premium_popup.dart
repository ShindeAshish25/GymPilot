import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/core/constants/app_colors.dart';

void showMemberPremiumPopup(BuildContext context, MemberModel member) {
  showDialog(
    context: context,
    builder: (context) => MemberPremiumPopup(member: member),
  );
}

class MemberPremiumPopup extends StatelessWidget {
  final MemberModel member;
  const MemberPremiumPopup({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM dd, yyyy');
    final lastPaymentDate = member.paymentDate != null ? fmt.format(member.paymentDate!) : 'N/A';
    final remainingAmount = member.totalFee - member.amountPaid;
    final duration = '${member.membershipDuration ?? 1} Months Premium';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            // Avatar with Badge
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: member.photoUrl != null && member.photoUrl!.isNotEmpty
                        ? DecorationImage(image: NetworkImage(member.photoUrl!), fit: BoxFit.cover)
                        : null,
                    color: Colors.grey.shade100,
                  ),
                  child: (member.photoUrl == null || member.photoUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 80, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4D67),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Name
            Text(member.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            // Phone
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, size: 18, color: Color(0xFFFF4D67)),
                const SizedBox(width: 8),
                Text(member.phone, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              ],
            ),
            const SizedBox(height: 32),
            
            // Detail Rows
            _buildDetailRow(Icons.calendar_today, 'Last Payment Date', lastPaymentDate),
            _buildDetailRow(Icons.account_balance_wallet, 'Remaining Amount', 
              '₹${remainingAmount.toStringAsFixed(2)}', isAmount: true),
            _buildDetailRow(Icons.timer, 'Membership Duration', duration),
            _buildDetailRow(Icons.info_outline, 'Membership Status', 
              member.daysUntilExpiry < 0 ? 'Expired' : 'Active',
              isStatus: true,
              statusColor: member.daysUntilExpiry < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
            _buildDetailRow(Icons.event, 'Remaining Days', 
              member.daysUntilExpiry >= 9999 ? 'N/A' : '${member.daysUntilExpiry} Days'),
            
            const SizedBox(height: 32),
            
            // Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D67),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: const Color(0xFFFF4D67).withOpacity(0.4),
                ),
                child: const Text('Close Notification', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isAmount = false, bool isStatus = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, 
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          ),
          Flexible(
            child: Text(value, 
              style: TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.w800, 
                color: isStatus ? statusColor : (isAmount ? const Color(0xFFFF4D67) : const Color(0xFF1E293B)),
                overflow: TextOverflow.ellipsis,
              )),
          ),
        ],
      ),
    );
  }
}
