import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/trainer_provider.dart';
import '../../data/models/trainer_model.dart';
import 'widgets/trainer_form_modal.dart';

class TrainerScreen extends StatefulWidget {
  const TrainerScreen({super.key});

  @override
  State<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends State<TrainerScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainerProvider>(context, listen: false).fetchTrainers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showForm({TrainerModel? trainer}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TrainerFormModal(trainer: trainer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Row(
                       children: const [
                          Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 28),
                          SizedBox(width: 12),
                          Text('Trainers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                       ],
                    ),
                    const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                 ]
              ),
            ),
            
            // Search Bar and Filter
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20),
               child: Row(
                  children: [
                     Expanded(
                        child: Container(
                           decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade200),
                           ),
                           child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                 hintText: 'Search trainers...',
                                 hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                 prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                                 border: InputBorder.none,
                                 contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              onChanged: (val) => setState(() => _searchQuery = val),
                           ),
                        ),
                     ),
                     const SizedBox(width: 12),
                     Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                           color: const Color(0xFFE8F3F1),
                           shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.filter_list_rounded, color: AppColors.primary, size: 20),
                     ),
                  ],
               ),
            ),
            const SizedBox(height: 20),
            
            // Add Trainer Button
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20),
               child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                     onPressed: () => _showForm(),
                     icon: const Icon(Icons.add, size: 22),
                     label: const Text('Add New Trainer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                     style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                     ),
                  ),
               ),
            ),
            const SizedBox(height: 24),

            // Active Staff Title
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20),
               child: Consumer<TrainerProvider>(
                 builder: (context, provider, child) {
                   final count = provider.trainers.length;
                   return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                         Text('Active Staff ($count)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                         const Text('Sort by: Experience', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                   );
                 }
               ),
            ),
            const SizedBox(height: 16),

            // Trainer List
            Expanded(
              child: Consumer<TrainerProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.trainers.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  var trainers = provider.trainers;
                  if (_searchQuery.isNotEmpty) {
                    trainers = trainers.where((t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                  }

                  if (trainers.isEmpty) {
                    return const Center(child: Text('No trainers found.', style: TextStyle(color: AppColors.textSecondary)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    itemCount: trainers.length,
                    itemBuilder: (context, index) {
                      final trainer = trainers[index];
                      return _buildTrainerCard(trainer);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerCard(TrainerModel trainer) {
     return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(24),
           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
           children: [
              Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Stack(
                       children: [
                          ClipRRect(
                             borderRadius: BorderRadius.circular(16),
                             child: Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade200,
                                child: trainer.photoUrl != null && trainer.photoUrl!.isNotEmpty
                                   ? Image.network(trainer.photoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.textMuted))
                                   : const Icon(Icons.person, color: AppColors.textMuted, size: 30),
                             ),
                          ),
                          Positioned(
                             bottom: -2,
                             right: -2,
                             child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                   color: Colors.green,
                                   shape: BoxShape.circle,
                                   border: Border.all(color: Colors.white, width: 2),
                                ),
                             ),
                          ),
                       ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                       child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(trainer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                             const SizedBox(height: 4),
                             Text(trainer.specialization ?? 'Trainer', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                             const SizedBox(height: 8),
                             Row(
                                children: [
                                   const Icon(Icons.phone, size: 12, color: AppColors.textSecondary),
                                   const SizedBox(width: 4),
                                   Text(trainer.phone ?? '+1 (555) 000-0000', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                             ),
                          ],
                       ),
                    ),
                    Column(
                       children: [
                          IconButton(
                             icon: const Icon(Icons.edit, color: AppColors.textMuted, size: 20),
                             onPressed: () => _showForm(trainer: trainer),
                             constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                             padding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 4),
                          IconButton(
                             icon: const Icon(Icons.delete, color: AppColors.textMuted, size: 20),
                             onPressed: () => _confirmDelete(trainer.id),
                             constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                             padding: EdgeInsets.zero,
                          ),
                       ],
                    ),
                 ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.surfaceLight, height: 1),
              const SizedBox(height: 16),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                    _buildStatCol('FEE', '\$${trainer.feeChargePerPerson?.toStringAsFixed(0) ?? 0}/hr'),
                    Container(height: 30, width: 1, color: AppColors.surfaceLight),
                    _buildStatCol('MEMBERS', '${trainer.assignedMembers}'), // Dynamic assigned members count
                    Container(height: 30, width: 1, color: AppColors.surfaceLight),
                    _buildStatCol('EXPERIENCE', '${trainer.experience ?? 0} yrs'),
                 ],
              ),
           ],
        ),
     );
  }

  Widget _buildStatCol(String label, String value) {
     return Column(
        children: [
           Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
           const SizedBox(height: 4),
           Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
     );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trainer'),
        content: const Text('Are you sure you want to remove this trainer?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<TrainerProvider>(context, listen: false).deleteTrainer(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
