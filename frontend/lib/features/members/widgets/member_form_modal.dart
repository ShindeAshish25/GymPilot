import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/providers/member_provider.dart';
import 'package:frontend/core/constants/app_colors.dart';

class MemberFormModal extends StatefulWidget {
  final MemberModel? member;

  const MemberFormModal({super.key, this.member});

  @override
  State<MemberFormModal> createState() => _MemberFormModalState();
}

class _MemberFormModalState extends State<MemberFormModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Tab 1: Personal
  XFile? _imageFile;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedGender;

  // Tab 2: Membership
  DateTime _joiningDate = DateTime.now();
  DateTime _paymentDate = DateTime.now();
  String? _selectedBatch;
  int _selectedDuration = 1;
  String? _selectedTraining;
  final _totalAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _remainingAmountController = TextEditingController();
  String _paymentMode = 'Cash';
  final _cashAmountController = TextEditingController();
  final _upiAmountController = TextEditingController();
  final _membershipDescriptionController = TextEditingController();

  // Tab 3: Physical Details
  List<PhysicalDetail> _physicalDetailsList = [];
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _workoutPlanController = TextEditingController();
  final _dietPlanController = TextEditingController();
  DateTime _progressDate = DateTime.now();
  final _physicalDescriptionController = TextEditingController();

  final List<String> _trainingOptions = [
    'Cardio', 'Strength', 'Personal', 'Core Workout', 'Weight Loss', 
    'Weight Gain', 'Flexibility and Mobility', 'HIIT', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (widget.member != null) {
      _loadMemberData();
    }

    _totalAmountController.addListener(_calculateRemaining);
    _paidAmountController.addListener(_calculateRemaining);
  }

  void _loadMemberData() {
    final m = widget.member!;
    _nameController.text = m.name;
    _phoneController.text = m.phone;
    _emailController.text = m.email ?? '';
    _addressController.text = m.address ?? '';
    _selectedGender = m.gender;
    
    _joiningDate = m.joinDate ?? DateTime.now();
    _selectedBatch = m.batch;
    _selectedTraining = m.trainingType;
    _totalAmountController.text = m.totalFee.toString();
    _paidAmountController.text = m.amountPaid.toString();
    _paymentMode = m.paymentMode ?? 'Cash';
    _cashAmountController.text = m.cashAmount.toString();
    _upiAmountController.text = m.upiAmount.toString();
    _membershipDescriptionController.text = m.description ?? '';
    
    _physicalDetailsList = List.from(m.physicalDetails);
  }

  void _calculateRemaining() {
    double total = double.tryParse(_totalAmountController.text) ?? 0;
    double paid = double.tryParse(_paidAmountController.text) ?? 0;
    _remainingAmountController.text = (total - paid).toStringAsFixed(2);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void _addPhysicalDetail() {
    if (_heightController.text.isEmpty && _weightController.text.isEmpty) return;

    setState(() {
      _physicalDetailsList.add(PhysicalDetail(
        date: _progressDate,
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        workoutPlan: _workoutPlanController.text,
        dietPlan: _dietPlanController.text,
        description: _physicalDescriptionController.text,
      ));
      
      // Clear inputs
      _heightController.clear();
      _weightController.clear();
      _workoutPlanController.clear();
      _dietPlanController.clear();
      _physicalDescriptionController.clear();
      _progressDate = DateTime.now();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<MemberProvider>(context, listen: false);
    
    Map<String, dynamic> data = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'address': _addressController.text,
      'gender': _selectedGender,
      'joinDate': _joiningDate.toIso8601String(),
      'paymentDate': _paymentDate.toIso8601String(),
      'batch': _selectedBatch,
      'membershipDuration': _selectedDuration,
      'trainingType': _selectedTraining,
      'totalFee': double.tryParse(_totalAmountController.text) ?? 0,
      'amountPaid': double.tryParse(_paidAmountController.text) ?? 0,
      'remainingAmount': double.tryParse(_remainingAmountController.text) ?? 0,
      'paymentMode': _paymentMode,
      'cashAmount': double.tryParse(_cashAmountController.text) ?? 0,
      'upiAmount': double.tryParse(_upiAmountController.text) ?? 0,
      'description': _membershipDescriptionController.text,
      'physicalDetails': _physicalDetailsList.map((e) => e.toJson()).toList(),
      'memberId': widget.member?.memberId ?? 'MEM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    };

    bool success;
    if (widget.member == null) {
      success = await provider.addMember(data);
    } else {
      success = await provider.updateMember(widget.member!.id, data);
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.member == null ? 'New Member' : 'Edit Member',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            // Tab bar
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Personal'),
                Tab(text: 'Membership'),
                Tab(text: 'Physical'),
              ],
            ),
            const SizedBox(height: 8),
            // Tab content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPersonalTab(),
                    _buildMembershipTab(),
                    _buildPhysicalTab(),
                  ],
                ),
              ),
            ),
            const Divider(height: 8),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imageFile != null 
                      ? (kIsWeb ? NetworkImage(_imageFile!.path) : null)
                      : (widget.member?.photoUrl != null && widget.member!.photoUrl!.isNotEmpty)
                          ? NetworkImage(widget.member!.photoUrl!)
                          : null,
                  child: (_imageFile == null && (widget.member?.photoUrl == null || widget.member!.photoUrl!.isEmpty))
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) 
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
              validator: (val) => val!.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile', prefixIcon: Icon(Icons.phone)),
              validator: (val) => val!.isEmpty ? 'Enter phone' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email (Optional)', prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc)),
              items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) => setState(() => _selectedGender = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker('Joining Date', _joiningDate, (d) => setState(() => _joiningDate = d)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDatePicker('Payment Date', _paymentDate, (d) => setState(() => _paymentDate = d)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedBatch,
                    decoration: const InputDecoration(labelText: 'Batch'),
                    items: ['Morning', 'Evening'].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (val) => setState(() => _selectedBatch = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedDuration,
                    decoration: const InputDecoration(labelText: 'Membership'),
                    items: List.generate(12, (i) => i + 1).map((m) => DropdownMenuItem(value: m, child: Text('$m Month'))).toList(),
                    onChanged: (val) => setState(() => _selectedDuration = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTraining,
              decoration: const InputDecoration(labelText: 'Training'),
              items: _trainingOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _selectedTraining = val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total Fee'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _paidAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Paid'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _remainingAmountController,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Remaining'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _paymentMode,
              decoration: const InputDecoration(labelText: 'Payment Mode'),
              items: ['UPI', 'Cash', 'Both'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _paymentMode = val!),
            ),
            if (_paymentMode == 'Both') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cashAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cash Amt'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _upiAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'UPI Amt'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _membershipDescriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalTab() {
    return Column(
      children: [
        Expanded(
          child: _physicalDetailsList.isEmpty 
            ? const Center(child: Text('No physical details added yet.'))
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: _physicalDetailsList.length,
                itemBuilder: (context, index) {
                  final d = _physicalDetailsList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('Date: ${DateFormat('dd MMM yyyy').format(d.date)}'),
                      subtitle: Text('Wt: ${d.weight}kg, Ht: ${d.height}cm'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                        onPressed: () => setState(() => _physicalDetailsList.removeAt(index)),
                      ),
                    ),
                  );
                },
              ),
        ),
        const Divider(),
        const Text('Add New Stats', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight'))),
            const SizedBox(width: 8),
            Expanded(child: _buildDatePicker('Date', _progressDate, (d) => setState(() => _progressDate = d))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _workoutPlanController, decoration: const InputDecoration(labelText: 'Workout'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _dietPlanController, decoration: const InputDecoration(labelText: 'Diet'))),
          ],
        ),
        TextFormField(controller: _physicalDescriptionController, decoration: const InputDecoration(labelText: 'Description')),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _addPhysicalDetail, 
                icon: const Icon(Icons.add), 
                label: const Text('Add Entry'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime selectedDate, Function(DateTime) onSelected) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context, 
          initialDate: selectedDate, 
          firstDate: DateTime(2000), 
          lastDate: DateTime(2100)
        );
        if (date != null) onSelected(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        child: Text(DateFormat('dd/MM/yy').format(selectedDate), style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    _remainingAmountController.dispose();
    _cashAmountController.dispose();
    _upiAmountController.dispose();
    _membershipDescriptionController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _workoutPlanController.dispose();
    _dietPlanController.dispose();
    _physicalDescriptionController.dispose();
    super.dispose();
  }
}
