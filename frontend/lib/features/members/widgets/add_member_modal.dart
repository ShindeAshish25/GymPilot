import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/providers/member_provider.dart';

class AddMemberModal extends StatefulWidget {
  const AddMemberModal({super.key});
  @override
  State<AddMemberModal> createState() => _AddMemberModalState();
}

class _AddMemberModalState extends State<AddMemberModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Personal
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _gender = 'Male';
  Uint8List? _imageBytes;
  XFile? _pickedImage;
  final _picker = ImagePicker();

  // Membership
  DateTime _startDate = DateTime.now();
  int _durationMonths = 1;
  String _batch = 'Morning';
  String _trainingType = 'General Training';
  final _totalCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  double _remaining = 0;
  String _paymentMode = 'Cash';
  final _trainerCtrl = TextEditingController();

  // Physical
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _workoutCtrl = TextEditingController();
  final _dietCtrl = TextEditingController();

  static const Color _red = Color(0xFFE8324B);
  static const Color _bg = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _totalCtrl.addListener(_calc);
    _paidCtrl.addListener(_calc);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [_nameCtrl, _mobileCtrl, _emailCtrl, _addressCtrl,
        _totalCtrl, _paidCtrl, _trainerCtrl, _heightCtrl, _weightCtrl,
        _workoutCtrl, _dietCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  DateTime get _endDate => DateTime(_startDate.year, _startDate.month + _durationMonths, _startDate.day);

  void _calc() {
    final t = double.tryParse(_totalCtrl.text) ?? 0;
    final p = double.tryParse(_paidCtrl.text) ?? 0;
    setState(() => _remaining = t - p);
  }

  Future<void> _pickStartDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000), lastDate: DateTime(2101),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _red, onPrimary: Colors.white)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _submit() async {
    final physical = <Map<String, dynamic>>[];
    if (_heightCtrl.text.isNotEmpty || _weightCtrl.text.isNotEmpty) {
      physical.add({
        'date': DateTime.now().toIso8601String(),
        'height': double.tryParse(_heightCtrl.text),
        'weight': double.tryParse(_weightCtrl.text),
        'workoutPlan': _workoutCtrl.text,
        'dietPlan': _dietCtrl.text,
      });
    }

    final data = {
      'memberId': 'MEM-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      'name': _nameCtrl.text.trim(),
      'phone': _mobileCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'gender': _gender,
      'address': _addressCtrl.text.trim(),
      'joinDate': _startDate.toIso8601String(),
      'paymentDate': DateTime.now().toIso8601String(),
      'batch': _batch,
      'membershipDuration': _durationMonths,
      'trainingType': _trainingType,
      'paymentMode': _paymentMode,
      'totalFee': double.tryParse(_totalCtrl.text) ?? 0.0,
      'amountPaid': double.tryParse(_paidCtrl.text) ?? 0.0,
      'remainingAmount': _remaining,
      'paymentStatus': _remaining <= 0 ? 'Paid' : 'Partial',
      'description': _trainerCtrl.text.isNotEmpty ? 'Assigned Trainer: ${_trainerCtrl.text}' : null,
      'physicalDetails': physical,
    };

    final ok = await context.read<MemberProvider>().addMember(data,
        imageBytes: _imageBytes, imageName: _pickedImage?.name);
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _handle(),
          _header(),
          _tabs(),
          Expanded(
            child: Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _personalTab(),
                  _membershipTab(),
                  _physicalTab(),
                ],
              ),
            ),
          ),
          _footer(),
        ],
      ),
    );
  }

  Widget _handle() => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
      ),
    ),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 20),
          style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
        ),
        const Expanded(
          child: Text('Register Member', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 48),
      ],
    ),
  );

  Widget _tabs() => TabBar(
    controller: _tabController,
    labelColor: _red,
    unselectedLabelColor: Colors.grey,
    indicatorColor: _red,
    indicatorWeight: 2,
    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    tabs: const [Tab(text: 'Personal'), Tab(text: 'Membership'), Tab(text: 'Physical')],
  );

  Widget _footer() => Container(
    padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Colors.grey.shade100)),
    ),
    child: Consumer<MemberProvider>(
      builder: (ctx, p, _) => ElevatedButton(
        onPressed: p.isLoading ? null : _validateAndSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: p.isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Save Member Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ),
  );

  void _validateAndSubmit() {
    if (_nameCtrl.text.trim().isEmpty) { _showAlert('Full Name'); _tabController.animateTo(0); return; }
    if (_mobileCtrl.text.trim().isEmpty) { _showAlert('Mobile Number'); _tabController.animateTo(0); return; }
    if (_emailCtrl.text.trim().isEmpty) { _showAlert('Email'); _tabController.animateTo(0); return; }
    if (_addressCtrl.text.trim().isEmpty) { _showAlert('Address'); _tabController.animateTo(0); return; }

    if (_totalCtrl.text.trim().isEmpty) { _showAlert('Total Fee'); _tabController.animateTo(1); return; }
    if (_paidCtrl.text.trim().isEmpty) { _showAlert('Paid Amount'); _tabController.animateTo(1); return; }

    if (_heightCtrl.text.trim().isEmpty) { _showAlert('Height'); _tabController.animateTo(2); return; }
    if (_weightCtrl.text.trim().isEmpty) { _showAlert('Weight'); _tabController.animateTo(2); return; }

    _submit();
  }

  void _showAlert(String field) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill $field'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _personalTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _field('Full Name', _nameCtrl, hint: 'Rahul Sharma', dense: true),
        const SizedBox(height: 10),
        _field('Mobile Number', _mobileCtrl, hint: '9876543210', type: TextInputType.phone, dense: true),
        const SizedBox(height: 10),
        _field('Email', _emailCtrl, hint: 'rahul@example.com', type: TextInputType.emailAddress, dense: true),
        const SizedBox(height: 10),
        _drop('Gender', _gender, ['Male', 'Female', 'Other'], (v) => setState(() => _gender = v!), dense: true),
        const SizedBox(height: 10),
        _field('Address', _addressCtrl, hint: 'Pune, Maharashtra', maxLines: 2, dense: true),
      ],
    ),
  );

  Widget _membershipTab() {
    final fmt = DateFormat('dd MMM yyyy');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _lbl('Duration')),
              const SizedBox(width: 10),
              Expanded(
                child: _intDrop(_durationMonths, List.generate(12, (i) => i + 1),
                    (v) => setState(() => _durationMonths = v!),
                    itemLabel: (m) => '$m Month${m > 1 ? 's' : ''}', dense: true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _dateAction('Start Date', fmt.format(_startDate), _pickStartDate)),
              const SizedBox(width: 10),
              Expanded(child: _infoBox('End Date (auto)', fmt.format(_endDate))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _infoBox('Payment Date', fmt.format(DateTime.now()))),
              const SizedBox(width: 10),
              Expanded(child: _drop('Batch', _batch, ['Morning', 'Evening'], (v) => setState(() => _batch = v!), dense: true)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _drop('Training Type', _trainingType, ['General', 'Cardio', 'Strength', 'Yoga'], (v) => setState(() => _trainingType = v!), dense: true)),
              const SizedBox(width: 10),
              Expanded(child: _lbl('Want Personal Training?')),
              Switch(value: _trainingType == 'Personal Training', onChanged: (v) => setState(() => _trainingType = v ? 'Personal Training' : 'General'), activeColor: _red),
            ],
          ),
          const SizedBox(height: 10),
          _paymentGrid(),
          const SizedBox(height: 10),
          _drop('Payment Mode', _paymentMode, ['Cash', 'UPI', 'Both'], (v) => setState(() => _paymentMode = v!), dense: true),
        ],
      ),
    );
  }

  Widget _paymentGrid() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        Expanded(child: _inlineField('Total Fee', _totalCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _inlineField('Paid Amt', _paidCtrl)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Remaining', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text('₹${_remaining.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _remaining > 0 ? _red : Colors.green)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _physicalTab() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: _field('Height (cm)', _heightCtrl, hint: '175', type: TextInputType.number, dense: true)),
            const SizedBox(width: 10),
            Expanded(child: _field('Weight (kg)', _weightCtrl, hint: '70', type: TextInputType.number, dense: true)),
          ],
        ),
        const SizedBox(height: 10),
        _field('Workout Plan (optional)', _workoutCtrl, hint: 'Strength Training', maxLines: 2, dense: true),
        const SizedBox(height: 10),
        _field('Diet Plan (optional)', _dietCtrl, hint: 'High Protein', maxLines: 2, dense: true),
      ],
    ),
  );

  Widget _lbl(String t) => Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold));

  Widget _field(String label, TextEditingController ctrl, {String? hint, TextInputType? type, int maxLines = 1, bool dense = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _lbl(label),
      const SizedBox(height: 4),
      TextFormField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          isDense: dense,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: _bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    ],
  );

  Widget _inlineField(String label, TextEditingController ctrl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
      ),
    ],
  );

  Widget _drop(String label, String value, List<String> items, Function(String?) onChanged, {bool dense = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _lbl(label),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isDense: dense,
            isExpanded: true,
            style: const TextStyle(fontSize: 13, color: Colors.black),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );

  Widget _intDrop(int value, List<int> items, Function(int?) onChanged, {required String Function(int) itemLabel, bool dense = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: value,
        isDense: dense,
        isExpanded: true,
        style: const TextStyle(fontSize: 13, color: Colors.black),
        items: items.map((m) => DropdownMenuItem(value: m, child: Text(itemLabel(m)))).toList(),
        onChanged: onChanged,
      ),
    ),
  );

  Widget _dateAction(String label, String val, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: _infoBox(label, val, icon: Icons.calendar_today_rounded),
  );

  Widget _infoBox(String label, String val, {IconData? icon}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _lbl(label),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(child: Text(val, style: const TextStyle(fontSize: 12))),
            if (icon != null) Icon(icon, size: 14, color: Colors.grey),
          ],
        ),
      ),
    ],
  );
}
