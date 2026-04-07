import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/trainer_provider.dart';
import '../../../data/models/trainer_model.dart';
import '../../../core/constants/app_colors.dart';

class TrainerFormModal extends StatefulWidget {
  final TrainerModel? trainer;
  const TrainerFormModal({super.key, this.trainer});

  @override
  State<TrainerFormModal> createState() => _TrainerFormModalState();
}

class _TrainerFormModalState extends State<TrainerFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _specializationController;
  late TextEditingController _experienceController;
  late TextEditingController _feeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.trainer?.name ?? '');
    _phoneController = TextEditingController(text: widget.trainer?.phone ?? '');
    _specializationController = TextEditingController(text: widget.trainer?.specialization ?? '');
    _experienceController = TextEditingController(text: widget.trainer?.experience?.toString() ?? '');
    _feeController = TextEditingController(text: widget.trainer?.feeChargePerPerson?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.trainer == null ? 'Add New Trainer' : 'Edit Trainer',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              _buildField('Full Name', _nameController, Icons.person_outline),
              _buildField('Phone Number', _phoneController, Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              _buildField('Specialization', _specializationController, Icons.workspace_premium_outlined),
              Row(
                children: [
                  Expanded(child: _buildField('Experience (Years)', _experienceController, Icons.timer_outlined, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Fee Per Person', _feeController, Icons.currency_rupee_outlined, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Trainer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TrainerProvider>(context, listen: false);
      final data = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'specialization': _specializationController.text,
        'experience': int.tryParse(_experienceController.text) ?? 0,
        'feeChargePerPerson': double.tryParse(_feeController.text) ?? 0.0,
      };

      bool success;
      if (widget.trainer == null) {
        success = await provider.addTrainer(data);
      } else {
        success = await provider.updateTrainer(widget.trainer!.id, data);
      }

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trainer saved successfully!')));
      }
    }
  }
}
