import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_button.dart';

class EditCustomerModal extends StatefulWidget {
  final Map<String, dynamic> customer;
  const EditCustomerModal({super.key, required this.customer});

  @override
  State<EditCustomerModal> createState() => _EditCustomerModalState();
}

class _EditCustomerModalState extends State<EditCustomerModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String _selectedPlan = '1 Month';
  DateTime _joiningDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer['name']);
    _phoneController = TextEditingController(text: widget.customer['phone']);
    _selectedPlan = widget.customer['plan'] ?? '1 Month';
    _joiningDate = widget.customer['joiningDate'] ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: 32,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Customer',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_android)),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPlan,
              dropdownColor: AppColors.surface,
              decoration: const InputDecoration(labelText: 'Plan', prefixIcon: Icon(Icons.card_membership)),
              items: ['1 Month', '3 Month', '6 Month', '12 Month']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(color: AppColors.textPrimary))))
                  .toList(),
              onChanged: (val) => setState(() => _selectedPlan = val!),
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Update Details',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // TODO: Call update API via Provider
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

void showEditCustomerModal(BuildContext context, Map<String, dynamic> customer) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EditCustomerModal(customer: customer),
  );
}
