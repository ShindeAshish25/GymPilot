import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/trainer_provider.dart';
import '../../core/constants/app_colors.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _feeController = TextEditingController();
  final _amountPaidController = TextEditingController();

  String? _selectedGender;
  int? _selectedDuration;
  String? _selectedTrainingType;
  
  bool _wantPersonalTraining = false;
  int? _ptDuration;
  String? _trainerId;
  String? _trainerName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainerProvider>(context, listen: false).fetchTrainers();
    });
  }
  
  void _saveMember() async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    
    final memberData = {
      'memberId': 'MEM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'gender': _selectedGender,
      'membershipDuration': _selectedDuration,
      'trainingType': _selectedTrainingType,
      'wantPersonalTraining': _wantPersonalTraining,
      'personalTrainingDuration': _ptDuration,
      'trainerId': _trainerId,
      'totalFee': double.tryParse(_feeController.text),
      'amountPaid': double.tryParse(_amountPaidController.text),
      'paymentStatus': (double.tryParse(_amountPaidController.text) ?? 0) >= (double.tryParse(_feeController.text) ?? 1) ? 'Paid' : 'Unpaid'
    };

    final result = await memberProvider.addMember(memberData);
    if (result && mounted) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add member'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Member')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.camera_alt, size: 30),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            // Gender Dropdown Placeholder
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Gender'),
              value: _selectedGender,
              items: ['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedGender = val),
            ),
            const SizedBox(height: 12),
            // Duration Dropdown Placeholder
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Membership Duration (Months)'),
              value: _selectedDuration,
              items: [1, 3, 6, 12].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value Months'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedDuration = val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Start Date'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'End Date', enabled: false))),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Training Type'),
              value: _selectedTrainingType,
              items: ['General', 'Weight Loss', 'Strength', 'Cardio'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedTrainingType = val),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Want Personal Training?', style: TextStyle(fontSize: 14)),
                Switch(
                  value: _wantPersonalTraining,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _wantPersonalTraining = val;
                      if (!val) {
                        _trainerId = null;
                        _trainerName = null;
                        _ptDuration = null;
                      } else {
                        _ptDuration = _selectedDuration ?? 1;
                      }
                    });
                  },
                ),
              ],
            ),
            if (_wantPersonalTraining) ...[
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_trainerName ?? 'Select Trainer'),
                leading: const Icon(Icons.person),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showTrainerPopup,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'PT Duration (Months)'),
                value: _ptDuration,
                items: [1, 2, 3, 6, 12].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value Months'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _ptDuration = val),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _feeController, decoration: const InputDecoration(labelText: 'Total Fee'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _amountPaidController, decoration: const InputDecoration(labelText: 'Amount Paid'))),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Consumer<MemberProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveMember,
                    child: provider.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Save Member'),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainerPopup() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Trainer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Consumer<TrainerProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                      if (provider.trainers.isEmpty) return const Center(child: Text('No trainers available'));
                      
                      return ListView.builder(
                        itemCount: provider.trainers.length,
                        itemBuilder: (context, index) {
                          final trainer = provider.trainers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(trainer.name),
                              subtitle: Text('Fee: ₹${trainer.feeChargePerPerson}/month'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _trainerId = trainer.id;
                                    _trainerName = trainer.name;
                                  });
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Select'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
