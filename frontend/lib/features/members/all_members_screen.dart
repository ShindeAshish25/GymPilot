

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/providers/member_provider.dart';
import 'package:frontend/features/members/widgets/member_card.dart';
import 'package:frontend/features/members/member_form_screen.dart';

enum MemberFilter { all, active, expiringSoon, overdue, inactive }

class AllMembersScreen extends StatefulWidget {
  const AllMembersScreen({super.key});
  @override
  State<AllMembersScreen> createState() => _AllMembersScreenState();
}

class _AllMembersScreenState extends State<AllMembersScreen> {
  MemberFilter _filter = MemberFilter.all;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _refresh() => Provider.of<MemberProvider>(context, listen: false).fetchMembers();

  void _showForm({MemberModel? member}) async {
    final ok = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => MemberFormScreen(member: member)));
    if (ok == true && mounted) _refresh();
  }

  List<MemberModel> _filtered(List<MemberModel> all) {
    var list = switch (_filter) {
      MemberFilter.active => all.where((m) => m.isActive).toList(),
      MemberFilter.expiringSoon => all.where((m) => m.isExpiringSoon).toList(),
      MemberFilter.overdue => all.where((m) => m.isRecentlyOverdue).toList(),
      MemberFilter.inactive => all.where((m) => m.isCriticallyOverdue).toList(),
      MemberFilter.all => all.where((m) => !m.isCriticallyOverdue).toList(), // Keep the list clean
    };
    if (_query.isNotEmpty) {
      list = list.where((m) =>
          m.name.toLowerCase().contains(_query.toLowerCase()) ||
          m.phone.contains(_query)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('All Members',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Manage your gym members and subscriptions.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ]),
            ),
            const SizedBox(height: 14),

            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _Chip(label: 'All', sel: _filter == MemberFilter.all,
                      onTap: () => setState(() => _filter = MemberFilter.all)),
                  const SizedBox(width: 8),
                  _Chip(label: 'Active', sel: _filter == MemberFilter.active,
                      color: Colors.green, onTap: () => setState(() => _filter = MemberFilter.active)),
                  const SizedBox(width: 8),
                  _Chip(label: 'Expiring', sel: _filter == MemberFilter.expiringSoon,
                      color: Colors.orange, onTap: () => setState(() => _filter = MemberFilter.expiringSoon)),
                  const SizedBox(width: 8),
                  _Chip(label: 'Overdue', sel: _filter == MemberFilter.overdue,
                      color: Colors.red, onTap: () => setState(() => _filter = MemberFilter.overdue)),
                  const SizedBox(width: 8),
                  _Chip(label: 'Inactive', sel: _filter == MemberFilter.inactive,
                      color: Colors.grey, onTap: () => setState(() => _filter = MemberFilter.inactive)),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))]),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search by name or phone…',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Consumer<MemberProvider>(
                builder: (ctx, provider, _) {
                  if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  final list = _filtered(provider.members);
                  if (list.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.people_outline, size: 60, color: AppColors.textMuted.withOpacity(0.4)),
                    const SizedBox(height: 12),
                    const Text('No members found', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  ]));

                  return Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                          child: Text('${list.length} member${list.length == 1 ? '' : 's'}',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final m = list[i];
                          return MemberCard(
                            member: m,
                            onEdit: () => _showForm(member: m),
                            onDelete: () => _handleDelete(m, provider),
                            onRenewed: _refresh,
                          );
                        },
                      ),
                    ),
                  ]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Member', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _handleDelete(MemberModel m, MemberProvider p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Member', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Remove ${m.name} from the gym?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await p.deleteMember(m.id);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool sel;
  final VoidCallback onTap;
  final Color color;
  const _Chip({required this.label, required this.sel, required this.onTap, this.color = AppColors.primary});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: sel ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sel ? color : AppColors.textMuted.withOpacity(0.25)),
        boxShadow: sel ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
      ),
      child: Text(label, style: TextStyle(
          color: sel ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600, fontSize: 13)),
    ),
  );
}