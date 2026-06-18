import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/providers/member_provider.dart';
import 'package:frontend/providers/inquiry_provider.dart';
import 'package:frontend/data/models/inquiry_model.dart';
import 'package:frontend/features/members/widgets/member_card.dart';
import 'package:frontend/features/members/widgets/inquiry_card.dart';
import 'package:frontend/features/members/member_form_screen.dart';
import 'package:frontend/features/members/inquiry_form_screen.dart';

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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Rebuild to show/hide FAB
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
      Provider.of<InquiryProvider>(context, listen: false).fetchInquiries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showMemberForm({MemberModel? member}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MemberFormScreen(member: member),
        fullscreenDialog: false,
      ),
    );
    if (result == true && mounted) {
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    }
  }

  void _showInquiryForm() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const InquiryFormScreen(),
      ),
    );
    if (result == true && mounted) {
      Provider.of<InquiryProvider>(context, listen: false).fetchInquiries();
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
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Overdue'),
                Tab(text: 'All Customers'),
                Tab(text: 'Inquiry'),
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
          _buildInquiryTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 3 
        ? null // We will put the FAB in the stack for Inquiry tab as requested "top right"
        : FloatingActionButton(
            onPressed: () => _showMemberForm(),
            backgroundColor: AppColors.primary,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.person_add_rounded, color: Colors.white),
          ),
    );
  }

  Widget _buildInquiryTab() {
    return Stack(
      children: [
        Consumer<InquiryProvider>(
          builder: (context, inquiryProvider, child) {
            if (inquiryProvider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (inquiryProvider.inquiries.isEmpty) {
              return const Center(child: Text('No inquiries found', style: TextStyle(color: AppColors.textSecondary)));
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              itemCount: inquiryProvider.inquiries.length,
              itemBuilder: (context, index) {
                final inquiry = inquiryProvider.inquiries[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InquiryCard(
                    inquiry: inquiry,
                    onJoin: () => _convertInquiryToMember(inquiry),
                    onDelete: () => _handleDeleteInquiry(inquiry),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          top: 20,
          right: 20,
          child: FloatingActionButton.extended(
            heroTag: 'add_inquiry',
            onPressed: _showInquiryForm,
            backgroundColor: AppColors.primary,
            elevation: 4,
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            label: const Text('Add Inquiry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _convertInquiryToMember(InquiryModel inquiry) {
    // Pre-fill member data from inquiry
    final member = MemberModel(
      id: '', // New member
      memberId: 'MEM-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      name: inquiry.name,
      phone: inquiry.phone,
      email: inquiry.email,
      gender: inquiry.gender,
      address: inquiry.address,
      joinDate: DateTime.now(),
      totalFee: 0,
      amountPaid: 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemberFormScreen(member: member),
      ),
    ).then((result) {
      if (result == true) {
        // Successfully joined, maybe update inquiry status
        context.read<InquiryProvider>().updateStatus(inquiry.id, 'Joined');
        context.read<MemberProvider>().fetchMembers();
      }
    });
  }

  void _handleDeleteInquiry(InquiryModel inquiry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Inquiry'),
        content: Text('Are you sure you want to delete inquiry from ${inquiry.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<InquiryProvider>().deleteInquiry(inquiry.id);
    }
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
