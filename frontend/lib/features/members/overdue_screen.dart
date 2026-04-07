import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/providers/member_provider.dart';
import 'package:frontend/features/members/widgets/overdue_member_card.dart';
import 'package:frontend/features/members/member_form_screen.dart';

class OverdueScreen extends StatefulWidget {
  const OverdueScreen({super.key});

  @override
  State<OverdueScreen> createState() => _OverdueScreenState();
}

class _OverdueScreenState extends State<OverdueScreen> {
  String _selectedTab = 'Overdue';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    });
  }

  void _showMemberForm({MemberModel? member}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MemberFormScreen(member: member),
    );
    if (result == true && mounted) {
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F2), // Light teal/blue background from design
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(),
            Expanded(
              child: Consumer<MemberProvider>(
                builder: (context, memberProvider, child) {
                  if (memberProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  // Logic according to user request: 
                  // "after 10 days member should not be seen in this screen"
                  final overdueMembers = memberProvider.members
                      .where((m) => m.isRecentlyOverdue)
                      .toList();

                  List<MemberModel> filteredList;
                  if (_selectedTab == 'Overdue') {
                    filteredList = overdueMembers;
                  } else if (_selectedTab == 'Active') {
                    filteredList = memberProvider.members.where((m) => m.isActive).toList();
                  } else {
                    // "All Members" in this screen context: Active + Recently Overdue (hide >10 days expired)
                    filteredList = memberProvider.members.where((m) => m.isActive || m.isRecentlyOverdue).toList();
                  }

                  return Column(
                    children: [
                      // Banner only for Overdue tab
                      if (_selectedTab == 'Overdue' && overdueMembers.isNotEmpty)
                        _buildUrgentBanner(overdueMembers.length),

                      Expanded(
                        child: filteredList.isEmpty 
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final member = filteredList[index];
                                  return OverdueMemberCard(
                                    member: member,
                                    onRenew: () => _showMemberForm(member: member),
                                    onDelete: () => _confirmDelete(member, memberProvider),
                                  );
                                },
                              ),
                      ),
                      
                      if (_selectedTab == 'Overdue') _buildFooter(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Overdue Members',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.search, color: Color(0xFF1E293B)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.tune, color: Color(0xFF1E293B)), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['All Members', 'Overdue', 'Active'].map((tab) {
          bool isSel = _selectedTab == tab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = tab),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tab,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                    color: isSel ? const Color(0xFFFF4D67) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                if (isSel)
                  Container(
                    width: tab == 'Overdue' ? 60 : 80,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D67),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUrgentBanner(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E8).withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF4D67).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'URGENT ATTENTION',
                  style: TextStyle(
                    color: Color(0xFFFF4D67),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count Memberships Expired',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFF4D67),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.priority_high, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('No members found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Text(
            'Managing multiple overdue accounts?',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mail_outline, color: Color(0xFFFF4D67), size: 20),
            label: const Text(
              'Send Bulk Reminders',
              style: TextStyle(
                color: Color(0xFFFF4D67),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(MemberModel member, MemberProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Remove ${member.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.deleteMember(member.id);
    }
  }
}
