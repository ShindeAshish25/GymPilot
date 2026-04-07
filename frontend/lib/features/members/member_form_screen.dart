// lib/features/members/member_form_screen.dart
// ✅ Fixed: AppBar Save button width crash | Editable amount fields | Null-safe dates

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/providers/member_provider.dart';
import 'package:frontend/core/constants/app_colors.dart';

class MemberFormScreen extends StatefulWidget {
  final MemberModel? member;
  const MemberFormScreen({super.key, this.member});
  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Personal
  XFile? _imageFile;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _gender;

  // Membership
  DateTime _joinDate = DateTime.now();
  DateTime _payDate = DateTime.now();
  String? _batch;
  int _duration = 1;
  String? _training;
  final _totalCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  double _remaining = 0;
  String _payMode = 'Cash';
  final _cashCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Physical
  List<PhysicalDetail> _physical = [];
  final _htCtrl = TextEditingController();
  final _wtCtrl = TextEditingController();
  final _workoutCtrl = TextEditingController();
  final _dietCtrl = TextEditingController();
  DateTime _progressDate = DateTime.now();
  final _physDescCtrl = TextEditingController();

  static const _trainingOpts = [
    'General Training', 'Cardio', 'Strength', 'Personal Training',
    'Core Workout', 'Weight Loss', 'Weight Gain',
    'Flexibility and Mobility', 'HIIT', 'Yoga', 'CrossFit', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.member != null) _load();
    _totalCtrl.addListener(_calc);
    _paidCtrl.addListener(_calc);
  }

  void _load() {
    final m = widget.member!;
    _nameCtrl.text = m.name;
    _phoneCtrl.text = m.phone;
    _emailCtrl.text = m.email ?? '';
    _addressCtrl.text = m.address ?? '';
    _gender = m.gender;
    _joinDate = m.joinDate ?? DateTime.now();
    _payDate = m.paymentDate ?? DateTime.now();
    _batch = m.batch;
    _training = m.trainingType;
    _duration = m.membershipDuration ?? 1;
    _totalCtrl.text = (m.totalFee > 0) ? m.totalFee.toStringAsFixed(0) : '';
    _paidCtrl.text = (m.amountPaid > 0) ? m.amountPaid.toStringAsFixed(0) : '';
    _payMode = m.paymentMode ?? 'Cash';
    _cashCtrl.text = (m.cashAmount > 0) ? m.cashAmount.toStringAsFixed(0) : '';
    _upiCtrl.text = (m.upiAmount > 0) ? m.upiAmount.toStringAsFixed(0) : '';
    _notesCtrl.text = m.description ?? '';
    _physical = List.from(m.physicalDetails);
    // Calculate remaining after loading
    _remaining = m.totalFee - m.amountPaid;
  }

  void _calc() {
    final t = double.tryParse(_totalCtrl.text) ?? 0;
    final p = double.tryParse(_paidCtrl.text) ?? 0;
    setState(() => _remaining = t - p);
  }

  DateTime get _endDate {
    try {
      return DateTime(_joinDate.year, _joinDate.month + _duration, _joinDate.day);
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _pickImage() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _imageFile = f);
  }

  void _addPhysical() {
    if (_htCtrl.text.isEmpty && _wtCtrl.text.isEmpty) return;
    setState(() {
      _physical.add(PhysicalDetail(
        date: _progressDate,
        height: double.tryParse(_htCtrl.text),
        weight: double.tryParse(_wtCtrl.text),
        workoutPlan: _workoutCtrl.text,
        dietPlan: _dietCtrl.text,
        description: _physDescCtrl.text,
      ));
      _htCtrl.clear();
      _wtCtrl.clear();
      _workoutCtrl.clear();
      _dietCtrl.clear();
      _physDescCtrl.clear();
      _progressDate = DateTime.now();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final p = Provider.of<MemberProvider>(context, listen: false);
    final data = {
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'address': _addressCtrl.text,
      'gender': _gender,
      'joinDate': _joinDate.toIso8601String(),
      'paymentDate': _payDate.toIso8601String(),
      'batch': _batch,
      'membershipDuration': _duration,
      'trainingType': _training,
      'totalFee': double.tryParse(_totalCtrl.text) ?? 0,
      'amountPaid': double.tryParse(_paidCtrl.text) ?? 0,
      'remainingAmount': _remaining,
      'paymentMode': _payMode,
      'cashAmount': double.tryParse(_cashCtrl.text) ?? 0,
      'upiAmount': double.tryParse(_upiCtrl.text) ?? 0,
      'description': _notesCtrl.text,
      'physicalDetails': _physical.map((e) => e.toJson()).toList(),
      'memberId': widget.member?.memberId ??
          'MEM-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
    };
    final ok = widget.member == null
        ? await p.addMember(data)
        : await p.updateMember(widget.member!.id, data);
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
        ),
        title: Text(
          widget.member == null ? 'New Member' : 'Edit Member',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        // ✅ FIX: Wrap button in SizedBox to prevent infinite width constraint
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: Consumer<MemberProvider>(
              builder: (ctx, p, _) => SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: p.isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: p.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Personal'),
            Tab(text: 'Membership'),
            Tab(text: 'Physical'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [_personalTab(), _membershipTab(), _physicalTab()],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<MemberProvider>(
          builder: (ctx, p, _) => ElevatedButton(
            onPressed: p.isLoading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: p.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Save Member Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  // ─── Personal Tab ───────────────────────────────────────────────────────────
  Widget _personalTab() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: _imageFile != null
                      ? (kIsWeb
                          ? NetworkImage(_imageFile!.path) as ImageProvider
                          : null)
                      : (widget.member?.photoUrl?.isNotEmpty == true
                          ? NetworkImage(widget.member!.photoUrl!)
                          : null),
                  child: (_imageFile == null &&
                          (widget.member?.photoUrl == null ||
                              widget.member!.photoUrl!.isEmpty))
                      ? Icon(Icons.person_rounded,
                          size: 50,
                          color: AppColors.primary.withOpacity(0.35))
                      : null,
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 14, color: Colors.white),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text('Tap to change photo',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 22),
          _inp('Full Name', _nameCtrl,
              icon: Icons.person_outline, required: true),
          const SizedBox(height: 14),
          _inp('Mobile Number', _phoneCtrl,
              icon: Icons.phone_outlined,
              type: TextInputType.phone,
              required: true),
          const SizedBox(height: 14),
          _inp('Email (Optional)', _emailCtrl,
              icon: Icons.email_outlined,
              type: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _ddStr('Gender', _gender, ['Male', 'Female', 'Other'],
              (v) => setState(() => _gender = v),
              icon: Icons.wc_outlined),
          const SizedBox(height: 14),
          _inp('Address', _addressCtrl,
              icon: Icons.location_on_outlined, maxLines: 2),
        ]),
      );

  // ─── Membership Tab ─────────────────────────────────────────────────────────
  Widget _membershipTab() {
    final fmt = DateFormat('dd MMM yyyy');
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Duration dropdown
        _lbl('Membership Duration'),
        const SizedBox(height: 8),
        _ddInt(
          _duration,
          List.generate(12, (i) => i + 1),
          (v) => setState(() => _duration = v!),
          itemLabel: (m) => '$m Month${m > 1 ? 's' : ''}',
          icon: Icons.timelapse_outlined,
        ),
        const SizedBox(height: 14),

        // Start + auto end date
        Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lbl('Start Date'),
                  const SizedBox(height: 8),
                  _dateTile(
                    fmt.format(_joinDate),
                    Icons.calendar_today_outlined,
                    AppColors.primary,
                    onTap: () async {
                      final d = await _datePick(_joinDate);
                      if (d != null) setState(() => _joinDate = d);
                    },
                  ),
                ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lbl('End Date (auto)'),
                  const SizedBox(height: 8),
                  _dateTile(
                    fmt.format(_endDate),
                    Icons.event_outlined,
                    Colors.green,
                    readOnly: true,
                  ),
                ]),
          ),
        ]),
        const SizedBox(height: 14),

        // Payment date
        _lbl('Payment Date'),
        const SizedBox(height: 8),
        _dateTile(
          fmt.format(_payDate),
          Icons.receipt_outlined,
          AppColors.textSecondary,
          onTap: () async {
            final d = await _datePick(_payDate);
            if (d != null) setState(() => _payDate = d);
          },
        ),
        const SizedBox(height: 14),

        // Batch selector
        _lbl('Batch'),
        const SizedBox(height: 8),
        Row(
          children: ['Morning', 'Evening'].map((b) {
            final sel = _batch == b;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _batch = b),
                child: Container(
                  margin: EdgeInsets.only(right: b == 'Morning' ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel
                            ? AppColors.primary
                            : Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        b == 'Morning'
                            ? Icons.wb_sunny_outlined
                            : Icons.nights_stay_outlined,
                        size: 15,
                        color: sel ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(b,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: sel
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          )),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Training type
        _ddStr('Training Type', _training, _trainingOpts,
            (v) => setState(() => _training = v),
            icon: Icons.fitness_center_outlined),
        const SizedBox(height: 14),

        // ✅ FIX: Payment amount fields with full visible borders & proper input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PAYMENT',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 1.2)),
              const SizedBox(height: 14),
              // Total Fee field
              _amtField(
                label: 'Total Fee (₹)',
                controller: _totalCtrl,
                color: AppColors.textPrimary,
                icon: Icons.currency_rupee,
              ),
              const SizedBox(height: 12),
              // Paid field
              _amtField(
                label: 'Paid Amount (₹)',
                controller: _paidCtrl,
                color: Colors.green.shade700,
                icon: Icons.payments_outlined,
              ),
              const SizedBox(height: 14),
              // Remaining display
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _remaining > 0
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _remaining > 0
                        ? Colors.red.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Row(children: [
                  Icon(
                    _remaining > 0
                        ? Icons.money_off_outlined
                        : Icons.check_circle_outline,
                    size: 18,
                    color: _remaining > 0
                        ? AppColors.error
                        : Colors.green.shade600,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Remaining',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        '₹ ${_remaining.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _remaining > 0
                              ? AppColors.error
                              : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Payment mode selector
        _lbl('Payment Mode'),
        const SizedBox(height: 8),
        Row(
          children: ['Cash', 'UPI', 'Both'].map((m) {
            final sel = _payMode == m;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _payMode = m),
                child: Container(
                  margin: EdgeInsets.only(right: m != 'Both' ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: sel
                            ? AppColors.primary
                            : Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Text(m,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: sel
                              ? AppColors.primary
                              : AppColors.textSecondary)),
                ),
              ),
            );
          }).toList(),
        ),

        if (_payMode == 'Both') ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _inp('Cash Amount', _cashCtrl,
                  icon: Icons.money,
                  type: TextInputType.number),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _inp('UPI Amount', _upiCtrl,
                  icon: Icons.phone_android,
                  type: TextInputType.number),
            ),
          ]),
        ],
        const SizedBox(height: 14),
        _inp('Notes (Optional)', _notesCtrl,
            icon: Icons.notes_outlined, maxLines: 2),
      ]),
    );
  }

  // ─── Physical Tab ────────────────────────────────────────────────────────────
  Widget _physicalTab() {
    final fmt = DateFormat('dd MMM yyyy');
    return Column(children: [
      Expanded(
        child: _physical.isEmpty
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.monitor_weight_outlined,
                        size: 52, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    const Text('No physical records yet',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 14)),
                  ]))
            : ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: _physical.length,
                itemBuilder: (ctx, i) {
                  final d = _physical[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.monitor_weight_outlined,
                            color: Colors.orange.shade600, size: 18),
                      ),
                      title: Text(fmt.format(d.date),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(
                          'Wt: ${d.weight ?? '-'}kg  |  Ht: ${d.height ?? '-'}cm',
                          style: const TextStyle(fontSize: 12)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: AppColors.error, size: 18),
                        onPressed: () =>
                            setState(() => _physical.removeAt(i)),
                      ),
                    ),
                  );
                },
              ),
      ),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add Stats Entry',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _inp('Height (cm)', _htCtrl,
                    icon: Icons.height,
                    type: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inp('Weight (kg)', _wtCtrl,
                    icon: Icons.monitor_weight_outlined,
                    type: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateTile(
                  DateFormat('dd/MM/yy').format(_progressDate),
                  Icons.calendar_today_outlined,
                  AppColors.textMuted,
                  onTap: () async {
                    final d = await _datePick(_progressDate);
                    if (d != null) setState(() => _progressDate = d);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: _inp('Workout Plan', _workoutCtrl,
                    icon: Icons.fitness_center_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inp('Diet Plan', _dietCtrl,
                    icon: Icons.restaurant_outlined),
              ),
            ]),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addPhysical,
              icon: const Icon(Icons.add),
              label: const Text('Add Entry',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  // ─── Reusable Helpers ────────────────────────────────────────────────────────

  Widget _lbl(String t) => Text(t,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary));

  /// Standard labelled text input field
  Widget _inp(
    String label,
    TextEditingController ctrl, {
    IconData? icon,
    TextInputType? type,
    int maxLines = 1,
    bool required = false,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 6), child: _lbl(label)),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: AppColors.textMuted)
                : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: required
              ? (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
        ),
      ]);

  /// ✅ NEW: Full-width amount input field with visible border (replaces _amtTile)
  Widget _amtField({
    required String label,
    required TextEditingController controller,
    required Color color,
    required IconData icon,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.8))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: color.withOpacity(0.7)),
            prefixText: '₹ ',
            prefixStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color),
            hintText: '0',
            hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
                fontWeight: FontWeight.normal),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: color, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ]);

  Widget _ddStr(
    String label,
    String? value,
    List<String> items,
    Function(String?) cb, {
    IconData? icon,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 6), child: _lbl(label)),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  hint: const Text('Select',
                      style: TextStyle(color: AppColors.textMuted)),
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600),
                  items: items
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: cb,
                ),
              ),
            ),
          ]),
        ),
      ]);

  Widget _ddInt(
    int value,
    List<int> items,
    Function(int?) cb, {
    required String Function(int) itemLabel,
    IconData? icon,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600),
                items: items
                    .map((m) => DropdownMenuItem(
                        value: m, child: Text(itemLabel(m))))
                    .toList(),
                onChanged: cb,
              ),
            ),
          ),
        ]),
      );

  Widget _dateTile(
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
    bool readOnly = false,
  }) =>
      GestureDetector(
        onTap: readOnly ? null : onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: readOnly ? color.withOpacity(0.05) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: readOnly
                    ? color.withOpacity(0.2)
                    : Colors.grey.shade300),
          ),
          child: Row(children: [
            Icon(icon,
                size: 15,
                color: readOnly ? color : AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          readOnly ? FontWeight.w600 : FontWeight.normal,
                      color: readOnly ? color : AppColors.textPrimary)),
            ),
            if (!readOnly)
              Icon(Icons.edit_outlined,
                  size: 12, color: Colors.grey.shade400),
          ]),
        ),
      );

  Future<DateTime?> _datePick(DateTime init) => showDatePicker(
        context: context,
        initialDate: init,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        ),
      );

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [
      _nameCtrl, _phoneCtrl, _emailCtrl, _addressCtrl,
      _totalCtrl, _paidCtrl, _cashCtrl, _upiCtrl, _notesCtrl,
      _htCtrl, _wtCtrl, _workoutCtrl, _dietCtrl, _physDescCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}