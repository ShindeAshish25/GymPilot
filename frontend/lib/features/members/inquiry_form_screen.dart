import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/inquiry_provider.dart';

class InquiryFormScreen extends StatefulWidget {
  const InquiryFormScreen({super.key});

  @override
  State<InquiryFormScreen> createState() => _InquiryFormScreenState();
}

class _InquiryFormScreenState extends State<InquiryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _gender = 'Male';
  DateTime _inquiryDate = DateTime.now();
  DateTime? _planToJoinDate;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isInquiryDate) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isInquiryDate ? _inquiryDate : (_planToJoinDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (d != null) {
      setState(() {
        if (isInquiryDate) {
          _inquiryDate = d;
        } else {
          _planToJoinDate = d;
        }
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final success = await context.read<InquiryProvider>().addInquiry({
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'gender': _gender,
      'inquiryDate': _inquiryDate.toIso8601String(),
      'planToJoinDate': _planToJoinDate?.toIso8601String(),
      'address': _addressCtrl.text,
    });

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('New Inquiry', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildField('Full Name', _nameCtrl, Icons.person_outline, required: true),
            const SizedBox(height: 16),
            _buildField('Mobile Number', _phoneCtrl, Icons.phone_outlined, type: TextInputType.phone, required: true),
            const SizedBox(height: 16),
            _buildField('Email Address', _emailCtrl, Icons.email_outlined, type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Row(
              children: ['Male', 'Female', 'Other'].map((g) => Expanded(
                child: RadioListTile<String>(
                  title: Text(g, style: const TextStyle(fontSize: 13)),
                  value: g,
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender = v!),
                  contentPadding: EdgeInsets.zero,
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            _buildDateTile('Inquiry Date', _inquiryDate, () => _pickDate(true)),
            const SizedBox(height: 16),
            _buildDateTile('Plan to Join Date', _planToJoinDate, () => _pickDate(false)),
            const SizedBox(height: 16),
            _buildField('Address', _addressCtrl, Icons.location_on_outlined, maxLines: 2),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Inquiry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {TextInputType? type, bool required = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: required ? (v) => v!.isEmpty ? 'Required' : null : null,
        ),
      ],
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 12),
                Text(date != null ? DateFormat('dd MMM yyyy').format(date) : 'Select Date'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
