// lib/features/members/widgets/member_detail_popup.dart
// ✅ Full member info | Accurate expiry days | Renew Membership | Delete/Edit

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/providers/member_provider.dart';
import 'package:frontend/core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────
// ENTRY POINT — call this anywhere to show the popup
// ─────────────────────────────────────────────────────────────────
void showMemberDetailPopup(
  BuildContext context,
  MemberModel member, {
  VoidCallback? onEdit,
  VoidCallback? onDeleted,
  VoidCallback? onRenewed,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MemberDetailPopup(
      member: member,
      onEdit: onEdit,
      onDeleted: onDeleted,
      onRenewed: onRenewed,
    ),
  );
}

class MemberDetailPopup extends StatelessWidget {
  final MemberModel member;
  final VoidCallback? onEdit;
  final VoidCallback? onDeleted;
  final VoidCallback? onRenewed;

  const MemberDetailPopup({
    super.key,
    required this.member,
    this.onEdit,
    this.onDeleted,
    this.onRenewed,
  });

  // Accurate days left
  int get _daysLeft {
    if (member.membershipEndDate == null) return 0;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final endOnly = DateTime(
      member.membershipEndDate!.year,
      member.membershipEndDate!.month,
      member.membershipEndDate!.day,
    );
    return endOnly.difference(todayOnly).inDays;
  }

  bool get _isExpired => _daysLeft < 0;
  bool get _isExpiringSoon => !_isExpired && _daysLeft <= 7;
  bool get _isExpiringSoonish => !_isExpired && _daysLeft <= 30;

  Color get _statusColor {
    if (_isExpired) return const Color(0xFFE53935);
    if (_isExpiringSoon) return Colors.orange;
    if (_isExpiringSoonish) return Colors.amber.shade700;
    return const Color(0xFF43A047);
  }

  String get _statusLabel {
    if (_isExpired) return 'EXPIRED';
    if (_isExpiringSoon) return 'EXPIRING SOON';
    return 'ACTIVE';
  }

  String get _expiryText {
    if (_isExpired) return 'Expired ${_daysLeft.abs()} day${_daysLeft.abs() == 1 ? '' : 's'} ago';
    if (_daysLeft == 0) return 'Expires today!';
    if (_daysLeft == 1) return 'Expires tomorrow';
    return 'Expires in $_daysLeft days';
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');

    return Container(
      height: MediaQuery.of(context).size.height * 0.93,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 0),
            child: Center(
              child: Container(
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Member Profile',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      Row(
                        children: [
                          _IconBtn(icon: Icons.edit_outlined, color: AppColors.primary,
                              onTap: () { Navigator.pop(context); onEdit?.call(); }),
                          const SizedBox(width: 8),
                          _IconBtn(icon: Icons.delete_outline, color: Color(0xFFE53935),
                              onTap: () => _confirmDelete(context)),
                          const SizedBox(width: 8),
                          _IconBtn(icon: Icons.close, color: AppColors.textMuted,
                              onTap: () => Navigator.pop(context)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Profile hero card
                  _buildProfileCard(),
                  const SizedBox(height: 14),

                  // Progress bar
                  if (member.joinDate != null && member.membershipEndDate != null)
                    _buildProgressCard(fmt),
                  const SizedBox(height: 14),

                  // Personal
                  _SectionCard(title: 'Personal Details', icon: Icons.person_outline, children: [
                    _InfoRow(Icons.phone_outlined, 'Phone', member.phone),
                    if (member.email?.isNotEmpty == true)
                      _InfoRow(Icons.email_outlined, 'Email', member.email!),
                    if (member.gender?.isNotEmpty == true)
                      _InfoRow(Icons.wc_outlined, 'Gender', member.gender!),
                    if (member.address?.isNotEmpty == true)
                      _InfoRow(Icons.location_on_outlined, 'Address', member.address!),
                  ]),
                  const SizedBox(height: 12),

                  // Membership
                  _SectionCard(title: 'Membership Details', icon: Icons.card_membership_outlined, children: [
                    if (member.memberId?.isNotEmpty == true)
                      _InfoRow(Icons.tag, 'Member ID', member.memberId!),
                    if (member.batch?.isNotEmpty == true)
                      _InfoRow(Icons.schedule_outlined, 'Batch', member.batch!),
                    if (member.trainingType?.isNotEmpty == true)
                      _InfoRow(Icons.fitness_center_outlined, 'Training', member.trainingType!),
                    if (member.joinDate != null)
                      _InfoRow(Icons.calendar_today_outlined, 'Start Date', fmt.format(member.joinDate!)),
                    if (member.membershipEndDate != null)
                      _InfoRow(Icons.event_outlined, 'End Date', fmt.format(member.membershipEndDate!)),
                    _InfoRow(Icons.timelapse_outlined, 'Duration',
                        '${member.membershipDuration ?? 1} Month${(member.membershipDuration ?? 1) > 1 ? 's' : ''}'),
                  ]),
                  const SizedBox(height: 12),

                  // Payment
                  _SectionCard(title: 'Payment Details', icon: Icons.payments_outlined, children: [
                    _InfoRow(Icons.currency_rupee, 'Total Fee', '₹${member.totalFee.toStringAsFixed(0)}'),
                    _InfoRow(Icons.check_circle_outline, 'Amount Paid',
                        '₹${member.amountPaid.toStringAsFixed(0)}', valueColor: const Color(0xFF43A047)),
                    _InfoRow(Icons.pending_outlined, 'Remaining',
                        '₹${(member.totalFee - member.amountPaid).toStringAsFixed(0)}',
                        valueColor: (member.totalFee - member.amountPaid) > 0
                            ? const Color(0xFFE53935) : const Color(0xFF43A047)),
                    if (member.paymentMode?.isNotEmpty == true)
                      _InfoRow(Icons.credit_card_outlined, 'Payment Mode', member.paymentMode!),
                    _InfoRow(Icons.info_outline, 'Status', member.paymentStatus ?? 'N/A',
                        valueColor: member.paymentStatus == 'Paid'
                            ? const Color(0xFF43A047) : Colors.orange),
                  ]),

                  // Physical records
                  if (member.physicalDetails.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildPhysicalCard(fmt),
                  ],

                  // Notes
                  if (member.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _SectionCard(title: 'Notes', icon: Icons.notes_outlined, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                        child: Text(member.description!,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ),

          // Bottom actions
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.primary.withOpacity(0.08), AppColors.primary.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 76, height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _statusColor, width: 3),
                  color: Colors.grey.shade100,
                ),
                child: ClipOval(
                  child: member.photoUrl?.isNotEmpty == true
                      ? Image.network(member.photoUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, size: 36,
                              color: AppColors.primary.withOpacity(0.4)))
                      : Icon(Icons.person_rounded, size: 36, color: AppColors.primary.withOpacity(0.4)),
                ),
              ),
              Positioned(
                bottom: 2, right: 2,
                child: Container(
                  width: 17, height: 17,
                  decoration: BoxDecoration(
                    color: _statusColor, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(member.phone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_statusLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                          color: _statusColor, letterSpacing: 0.4)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(_isExpired ? Icons.warning_amber_rounded : Icons.access_time_rounded,
                        size: 13, color: _statusColor),
                    const SizedBox(width: 4),
                    Text(_expiryText,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _statusColor)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(DateFormat fmt) {
    final totalDays = member.membershipEndDate!.difference(member.joinDate!).inDays;
    final daysUsed = DateTime.now().difference(member.joinDate!).inDays.clamp(0, totalDays);
    final progress = totalDays > 0 ? (daysUsed / totalDays).clamp(0.0, 1.0) : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Membership Period',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
              Text(_isExpired ? 'Expired' : '$_daysLeft days left',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _statusColor)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress, minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fmt.format(member.joinDate!),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text(fmt.format(member.membershipEndDate!),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalCard(DateFormat fmt) {
    final latest = member.physicalDetails.last;
    return _SectionCard(title: 'Physical Records', icon: Icons.monitor_weight_outlined, children: [
      Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latest — ${fmt.format(latest.date)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Row(
              children: [
                if (latest.height != null)
                  Expanded(child: _StatChip(icon: Icons.height, label: 'HEIGHT',
                      value: '${latest.height} cm', color: Colors.blue)),
                if (latest.height != null && latest.weight != null) const SizedBox(width: 10),
                if (latest.weight != null)
                  Expanded(child: _StatChip(icon: Icons.monitor_weight_outlined, label: 'WEIGHT',
                      value: '${latest.weight} kg', color: Colors.orange)),
              ],
            ),
            if (latest.workoutPlan?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              _PlanBox(label: 'WORKOUT', value: latest.workoutPlan!),
            ],
            if (latest.dietPlan?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              _PlanBox(label: 'DIET', value: latest.dietPlan!),
            ],
          ],
        ),
      ),
    ]);
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100))),
      child: (_isExpired || _isExpiringSoon || _isExpiringSoonish)
          ? ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showRenewMembershipModal(context, member, onRenewed: onRenewed);
              },
              icon: const Icon(Icons.autorenew_rounded, size: 18),
              label: Text(_isExpired ? 'Renew Now — Membership Expired' : 'Renew Membership',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isExpired ? const Color(0xFFE53935) : Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            )
          : OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showRenewMembershipModal(context, member, onRenewed: onRenewed);
              },
              icon: const Icon(Icons.autorenew_rounded, size: 18),
              label: const Text('Renew Membership', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Member', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Remove ${member.name} from the gym? This cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(context);
              await context.read<MemberProvider>().deleteMember(member.id);
              onDeleted?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: color),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 15, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade100),
        ...children,
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(this.icon, this.label, this.value, {this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    child: Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        Flexible(child: Text(value, textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary))),
      ],
    ),
  );
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
    child: Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ]),
      ],
    ),
  );
}

class _PlanBox extends StatelessWidget {
  final String label;
  final String value;
  const _PlanBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
      const SizedBox(height: 4),
      Container(
        width: double.infinity, padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
        child: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
      ),
    ],
  );
}

// ═════════════════════════════════════════════════════════════════
// RENEW MEMBERSHIP MODAL
// ═════════════════════════════════════════════════════════════════

void showRenewMembershipModal(BuildContext context, MemberModel member, {VoidCallback? onRenewed}) {
  showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => RenewMembershipModal(member: member, onRenewed: onRenewed),
  );
}

class RenewMembershipModal extends StatefulWidget {
  final MemberModel member;
  final VoidCallback? onRenewed;
  const RenewMembershipModal({super.key, required this.member, this.onRenewed});
  @override
  State<RenewMembershipModal> createState() => _RenewMembershipModalState();
}

class _RenewMembershipModalState extends State<RenewMembershipModal> {
  int _months = 1;
  late DateTime _renewStart;
  final _totalCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  double _remaining = 0;
  String _mode = 'Cash';

  static const _monthOpts = [1, 2, 3, 6, 12];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _renewStart = (widget.member.membershipEndDate != null && widget.member.membershipEndDate!.isAfter(now))
        ? widget.member.membershipEndDate!
        : now;
    _totalCtrl.addListener(_calc);
    _paidCtrl.addListener(_calc);
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    _paidCtrl.dispose();
    super.dispose();
  }

  void _calc() {
    final t = double.tryParse(_totalCtrl.text) ?? 0;
    final p = double.tryParse(_paidCtrl.text) ?? 0;
    setState(() => _remaining = t - p);
  }

  DateTime get _endDate => DateTime(_renewStart.year, _renewStart.month + _months, _renewStart.day);

  Future<void> _submit() async {
    final provider = context.read<MemberProvider>();
    final data = {
      'name': widget.member.name, 'phone': widget.member.phone,
      'email': widget.member.email, 'address': widget.member.address,
      'gender': widget.member.gender, 'joinDate': _renewStart.toIso8601String(),
      'paymentDate': DateTime.now().toIso8601String(), 'batch': widget.member.batch,
      'membershipDuration': _months, 'trainingType': widget.member.trainingType,
      'totalFee': double.tryParse(_totalCtrl.text) ?? widget.member.totalFee,
      'amountPaid': double.tryParse(_paidCtrl.text) ?? 0,
      'remainingAmount': _remaining, 'paymentMode': _mode,
      'paymentStatus': _remaining <= 0 ? 'Paid' : 'Partial',
      'description': widget.member.description,
      'physicalDetails': widget.member.physicalDetails.map((e) => e.toJson()).toList(),
      'memberId': widget.member.memberId,
    };
    final ok = await provider.updateMember(widget.member.id, data);
    if (ok && mounted) {
      Navigator.pop(context);
      widget.onRenewed?.call();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text('${widget.member.name} renewed until ${DateFormat('dd MMM yyyy').format(_endDate)}')),
        ]),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 44, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Renew Membership',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(widget.member.name,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ]),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            const Text('Select Duration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(
              children: _monthOpts.map((m) {
                final sel = _months == m;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _months = m),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? AppColors.primary : Colors.grey.shade200),
                      ),
                      alignment: Alignment.center,
                      child: Text('${m}M',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                              color: sel ? Colors.white : AppColors.textSecondary)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('START', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5)),
                  const SizedBox(height: 3),
                  Text(fmt.format(_renewStart), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ])),
                Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.primary.withOpacity(0.4)),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('END (AUTO)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade700, letterSpacing: 0.5)),
                  const SizedBox(height: 3),
                  Text(fmt.format(_endDate), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ])),
              ]),
            ),
            const SizedBox(height: 16),

            const Text('Payment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _AmtField(label: 'Total Fee (₹)', ctrl: _totalCtrl)),
              const SizedBox(width: 10),
              Expanded(child: _AmtField(label: 'Paid (₹)', ctrl: _paidCtrl)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Remaining', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                  child: Text('₹${_remaining.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                          color: _remaining > 0 ? const Color(0xFFE53935) : const Color(0xFF43A047))),
                ),
              ])),
            ]),
            const SizedBox(height: 16),

            const Text('Payment Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: ['Cash', 'UPI', 'Both'].map((m) {
                final sel = _mode == m;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mode = m),
                    child: Container(
                      margin: EdgeInsets.only(right: m != 'Both' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? AppColors.primary : Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: Text(m, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                          color: sel ? AppColors.primary : AppColors.textSecondary)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            Consumer<MemberProvider>(
              builder: (ctx, p, _) => ElevatedButton.icon(
                onPressed: p.isLoading ? null : _submit,
                icon: p.isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.autorenew_rounded, size: 20),
                label: Text(p.isLoading ? 'Renewing...' : 'Confirm Renewal',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmtField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  const _AmtField({required this.label, required this.ctrl});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl, keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: '0', contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
        ),
      ),
    ],
  );
}