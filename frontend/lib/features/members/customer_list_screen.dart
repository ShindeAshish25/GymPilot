import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/providers/member_provider.dart';
import 'package:frontend/features/members/widgets/member_card.dart';
import 'package:frontend/features/members/member_form_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
           preferredSize: const Size.fromHeight(60),
           child: Container(
             color: Colors.white,
             child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Overdue'),
                Tab(text: 'All Customers'),
              ],
            ),
           ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent('ACTIVE'),
          _buildTabContent('OVERDUE'),
          _buildTabContent('ALL'),
        ],
      ),
    );
  }

  Widget _buildTabContent(String filter) {
    return Consumer<MemberProvider>(
      builder: (context, memberProvider, child) {
        if (memberProvider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        var allMembers = memberProvider.members;
        List<MemberModel> displayedMembers = [];

        if (filter == 'ACTIVE') {
          displayedMembers = allMembers.where((m) => m.isActive).toList();
        } else if (filter == 'OVERDUE') {
          displayedMembers = allMembers.where((m) => m.isRecentlyOverdue).toList();
        } else {
          displayedMembers = allMembers.where((m) => m.isActive || m.isRecentlyOverdue).toList();
        }

        // For "Active" tab, get some recently overdue as well if needed
        final recentlyOverdue = allMembers.where((m) => m.isRecentlyOverdue).take(1).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddButton(),
              const SizedBox(height: 24),
              Text(
                '${filter == "ALL" ? "All Customers" : (filter == "ACTIVE" ? "Active Memberships" : "Overdue Members")} (${displayedMembers.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              if (displayedMembers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text('No customers found', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                ...displayedMembers.map((member) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MemberCard(
                        member: member,
                        onEdit: () => _showMemberForm(member: member),
                        onDelete: () => _handleDelete(context, memberProvider, member),
                      ),
                    )),
              if (filter == 'ACTIVE' && recentlyOverdue.isNotEmpty) ...[
                 const SizedBox(height: 24),
                 const Text('Recently Overdue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                 const SizedBox(height: 16),
                 _buildRecentlyOverdueCard(recentlyOverdue.first, memberProvider),
              ]
            ],
          ),
        );
      },
    );
  }

  void _handleDelete(BuildContext context, MemberProvider provider, MemberModel member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await provider.deleteMember(member.id);
    }
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _showMemberForm(),
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
        label: const Text('Add New Customer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildRecentlyOverdueCard(MemberModel member, MemberProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
             width: 50,
             height: 50,
             decoration: BoxDecoration(
               color: Colors.grey.shade300,
               shape: BoxShape.circle,
               border: Border.all(color: Colors.white, width: 2),
             ),
             child: member.photoUrl != null && member.photoUrl!.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.network(member.photoUrl!, fit: BoxFit.cover))
                  : const Icon(Icons.person, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Overdue: ${member.daysUntilExpiry.abs()} days',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Flexible(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 0,
              ),
              child: const Text('Renew', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
            onPressed: () => _handleDelete(context, provider, member),
          ),
        ],
      ),
    );
  }
}
