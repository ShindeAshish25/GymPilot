// lib/features/members/member_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/models/member_model.dart';
import 'package:frontend/providers/member_provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/providers/trainer_provider.dart';
import 'package:frontend/data/models/trainer_model.dart';

class MemberFormScreen extends StatefulWidget {
  final MemberModel? member;
  const MemberFormScreen({super.key, this.member});
  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
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
  bool _wantPersonalTraining = false;
  int? _ptDuration;
  String? _trainerId;
  String? _trainerName;
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

  static const _trainingOpts = [
    'General Training', 'Cardio', 'Strength', 'Personal Training',
    'Core Workout', 'Weight Loss', 'Weight Gain',
    'Flexibility and Mobility', 'HIIT', 'Yoga', 'CrossFit', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainerProvider>(context, listen: false).fetchTrainers();
    });
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
    _wantPersonalTraining = m.wantPersonalTraining;
    _ptDuration = m.personalTrainingDuration;
    _trainerId = m.trainerId;
    _duration = m.membershipDuration ?? 1;
    _totalCtrl.text = (m.totalFee > 0) ? m.totalFee.toStringAsFixed(0) : '';
    _paidCtrl.text = (m.amountPaid > 0) ? m.amountPaid.toStringAsFixed(0) : '';
    _payMode = m.paymentMode ?? 'Cash';
    _cashCtrl.text = (m.cashAmount > 0) ? m.cashAmount.toStringAsFixed(0) : '';
    _upiCtrl.text = (m.upiAmount > 0) ? m.upiAmount.toStringAsFixed(0) : '';
    _notesCtrl.text = m.description ?? '';
    _physical = List.from(m.physicalDetails ?? []);
    _remaining = m.totalFee - m.amountPaid;
  }

  void _calc() {
    final t = double.tryParse(_totalCtrl.text) ?? 0;
    final p = double.tryParse(_paidCtrl.text) ?? 0;
    setState(() => _remaining = (t - p).clamp(0, double.infinity));
  }

  DateTime get _endDate {
    try {
      return DateTime(_joinDate.year, _joinDate.month + _duration, _joinDate.day);
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _imageFile = img);
  }

  void _addPhysical() {
    final h = double.tryParse(_htCtrl.text);
    final w = double.tryParse(_wtCtrl.text);
    if (h == null && w == null) return;
    setState(() {
      _physical.insert(
          0,
          PhysicalDetail(
            date: _progressDate,
            height: h,
            weight: w,
            workoutPlan: _workoutCtrl.text,
            dietPlan: _dietCtrl.text,
          ));
      _htCtrl.clear();
      _wtCtrl.clear();
      _workoutCtrl.clear();
      _dietCtrl.clear();
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
      'wantPersonalTraining': _wantPersonalTraining,
      'personalTrainingDuration': _ptDuration,
      'trainerId': _trainerId,
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
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
        ),
        title: Text(
          widget.member == null ? 'New Member' : 'Edit Member',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            _buildPersonalSection(),
            const SizedBox(height: 32),
            _buildMembershipSection(),
            const SizedBox(height: 32),
            _buildPhysicalSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Consumer<MemberProvider>(
          builder: (ctx, p, _) => ElevatedButton(
            onPressed: p.isLoading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: p.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Member Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildPersonalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Personal Information', Icons.person_outline),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Stack(children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: _imageFile != null
                    ? (kIsWeb ? NetworkImage(_imageFile!.path) as ImageProvider : null)
                    : (widget.member?.photoUrl?.isNotEmpty == true ? NetworkImage(widget.member!.photoUrl!) : null),
                child: (_imageFile == null && (widget.member?.photoUrl == null || widget.member!.photoUrl!.isEmpty))
                    ? Icon(Icons.person_rounded, size: 50, color: AppColors.primary.withOpacity(0.35))
                    : null,
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: Text('Tap to change photo', style: TextStyle(fontSize: 12, color: AppColors.textMuted))),
        const SizedBox(height: 28),
        _inp('Full Name', _nameCtrl, icon: Icons.person_outline, required: true),
        const SizedBox(height: 18),
        _inp('Mobile Number', _phoneCtrl, icon: Icons.phone_outlined, type: TextInputType.phone, required: true),
        const SizedBox(height: 18),
        _inp('Email Address (Optional)', _emailCtrl, icon: Icons.email_outlined, type: TextInputType.emailAddress),
        const SizedBox(height: 18),
        _ddStr('Gender', _gender, ['Male', 'Female', 'Other'], (v) => setState(() => _gender = v), icon: Icons.wc_outlined),
        const SizedBox(height: 18),
        _inp('Home Address', _addressCtrl, icon: Icons.location_on_outlined, maxLines: 2),
      ],
    );
  }

  Widget _buildMembershipSection() {
    final fmt = DateFormat('dd MMM yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Membership Details', Icons.card_membership_outlined),
        _lbl('Membership Duration'),
        const SizedBox(height: 10),
        _ddInt(_duration, List.generate(12, (i) => i + 1), (v) => setState(() => _duration = v!), itemLabel: (m) => '$m Month${m > 1 ? 's' : ''}', icon: Icons.timelapse_outlined),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _lbl('Start Date'),
              const SizedBox(height: 10),
              _dateTile(fmt.format(_joinDate), Icons.calendar_today_outlined, AppColors.primary, onTap: () async {
                final d = await _datePick(_joinDate);
                if (d != null) setState(() => _joinDate = d);
              }),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _lbl('End Date (auto)'),
              const SizedBox(height: 10),
              _dateTile(fmt.format(_endDate), Icons.event_outlined, Colors.green, readOnly: true),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        _lbl('Payment Date'),
        const SizedBox(height: 10),
        _dateTile(fmt.format(_payDate), Icons.receipt_outlined, AppColors.textSecondary, onTap: () async {
          final d = await _datePick(_payDate);
          if (d != null) setState(() => _payDate = d);
        }),
        const SizedBox(height: 18),
        _lbl('Preferred Batch'),
        const SizedBox(height: 10),
        Row(
          children: ['Morning', 'Evening'].map((b) {
            final sel = _batch == b;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _batch = b),
                child: Container(
                  margin: EdgeInsets.only(right: b == 'Morning' ? 12 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary.withOpacity(0.08) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? AppColors.primary : Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(b == 'Morning' ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined, size: 16, color: sel ? AppColors.primary : AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(b, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: sel ? AppColors.primary : AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        _ddStr('Training Category', _training, _trainingOpts, (v) => setState(() => _training = v), icon: Icons.fitness_center_outlined),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Personal Training', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Get access to dedicated physical trainer', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ]),
              ),
              Switch(value: _wantPersonalTraining, activeColor: AppColors.primary, onChanged: (val) {
                setState(() {
                  _wantPersonalTraining = val;
                  if (!val) { _trainerId = null; _trainerName = null; _ptDuration = null; }
                  else { _ptDuration = _duration; }
                });
              }),
            ]),
            if (_wantPersonalTraining) ...[
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _showTrainerPopup,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Row(children: [
                    Icon(Icons.person_outline, size: 20, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_trainerName ?? 'Select Trainer', style: TextStyle(color: _trainerName != null ? AppColors.textPrimary : AppColors.textMuted, fontSize: 14, fontWeight: _trainerName != null ? FontWeight.w600 : FontWeight.normal))),
                    Icon(Icons.search, size: 20, color: AppColors.textMuted),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              _ddInt(_ptDuration ?? 1, [1, 2, 3, 6, 12], (val) => setState(() => _ptDuration = val), itemLabel: (m) => '$m Month Training Plan', icon: Icons.timer_outlined),
            ],
          ]),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('PAYMENT DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1.2)),
            const SizedBox(height: 18),
            _amtField(label: 'Total Membership Fee (₹)', controller: _totalCtrl, color: AppColors.textPrimary, icon: Icons.currency_rupee),
            const SizedBox(height: 14),
            _amtField(label: 'Amount Paid (₹)', controller: _paidCtrl, color: Colors.green.shade700, icon: Icons.payments_outlined),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: _remaining > 0 ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: _remaining > 0 ? Colors.red.shade200 : Colors.green.shade200)),
              child: Row(children: [
                Icon(_remaining > 0 ? Icons.money_off_outlined : Icons.check_circle_outline, size: 20, color: _remaining > 0 ? AppColors.error : Colors.green.shade600),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Remaining Balance', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('₹ ${_remaining.toStringAsFixed(0)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _remaining > 0 ? AppColors.error : Colors.green.shade700)),
                ]),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 18),
        _lbl('Payment Method'),
        const SizedBox(height: 10),
        Row(
          children: ['Cash', 'UPI', 'Both'].map((m) {
            final sel = _payMode == m;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _payMode = m),
                child: Container(
                  margin: EdgeInsets.only(right: m != 'Both' ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary.withOpacity(0.08) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? AppColors.primary : Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Text(m, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: sel ? AppColors.primary : AppColors.textSecondary)),
                ),
              ),
            );
          }).toList(),
        ),
        if (_payMode == 'Both') ...[
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _inp('Cash Amount', _cashCtrl, icon: Icons.money, type: TextInputType.number)),
            const SizedBox(width: 14),
            Expanded(child: _inp('UPI Amount', _upiCtrl, icon: Icons.phone_android, type: TextInputType.number)),
          ]),
        ],
        const SizedBox(height: 18),
        _inp('Internal Remarks', _notesCtrl, icon: Icons.notes_outlined, maxLines: 2),
      ],
    );
  }

  Widget _buildPhysicalSection() {
    final fmt = DateFormat('dd MMM yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Physical Statistics', Icons.monitor_weight_outlined),
        if (_physical.isNotEmpty) ...[
          ..._physical.take(3).map((d) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.monitor_weight_outlined, color: Colors.orange.shade600, size: 20),
              ),
              title: Text(fmt.format(d.date), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('Weight: ${d.weight ?? "-"}kg  |  Height: ${d.height ?? "-"}cm', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              trailing: IconButton(icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20), onPressed: () => setState(() => _physical.remove(d))),
            ),
          )),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Record New Body Stats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: _inp('Height (cm)', _htCtrl, icon: Icons.height, type: TextInputType.number)),
              const SizedBox(width: 14),
              Expanded(child: _inp('Weight (kg)', _wtCtrl, icon: Icons.monitor_weight_outlined, type: TextInputType.number)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _inp('Workout Routine', _workoutCtrl, icon: Icons.fitness_center_outlined)),
              const SizedBox(width: 14),
              Expanded(child: _inp('Diet Plan', _dietCtrl, icon: Icons.restaurant_outlined)),
            ]),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addPhysical,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add To Records', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _lbl(String t) => Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  Widget _inp(String label, TextEditingController ctrl, {IconData? icon, TextInputType? type, int maxLines = 1, bool required = false}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(bottom: 6), child: _lbl(label)),
    TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.textMuted) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
    ),
  ]);

  Widget _amtField({required String label, required TextEditingController controller, required Color color, required IconData icon}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color.withOpacity(0.8))),
    const SizedBox(height: 6),
    TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: color.withOpacity(0.7)),
        prefixText: '₹ ',
        prefixStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        hintText: '0',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    ),
  ]);

  Widget _ddStr(String label, String? value, List<String> items, Function(String?) cb, {IconData? icon}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(bottom: 6), child: _lbl(label)),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Row(children: [
        if (icon != null) ...[Icon(icon, size: 18, color: AppColors.textMuted), const SizedBox(width: 8)],
        Expanded(child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, isExpanded: true, hint: const Text('Select', style: TextStyle(color: AppColors.textMuted)), icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: cb))),
      ]),
    ),
  ]);

  Widget _ddInt(int value, List<int> items, Function(int?) cb, {required String Function(int) itemLabel, IconData? icon}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
    child: Row(children: [
      if (icon != null) ...[Icon(icon, size: 18, color: AppColors.textMuted), const SizedBox(width: 8)],
      Expanded(child: DropdownButtonHideUnderline(child: DropdownButton<int>(value: value, isExpanded: true, icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600), items: items.map((m) => DropdownMenuItem(value: m, child: Text(itemLabel(m)))).toList(), onChanged: cb))),
    ]),
  );

  Widget _dateTile(String label, IconData icon, Color color, {VoidCallback? onTap, bool readOnly = false}) => GestureDetector(
    onTap: readOnly ? null : onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(color: readOnly ? color.withOpacity(0.05) : Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: readOnly ? color.withOpacity(0.2) : Colors.grey.shade300)),
      child: Row(children: [
        Icon(icon, size: 15, color: readOnly ? color : AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: readOnly ? FontWeight.w600 : FontWeight.normal, color: readOnly ? color : AppColors.textPrimary))),
        if (!readOnly) Icon(Icons.edit_outlined, size: 12, color: Colors.grey.shade400),
      ]),
    ),
  );

  Future<DateTime?> _datePick(DateTime init) => showDatePicker(context: context, initialDate: init, firstDate: DateTime(2000), lastDate: DateTime(2101), builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white)), child: child!));

  void _showTrainerPopup() {
    showDialog(context: context, builder: (ctx) => Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Container(padding: const EdgeInsets.all(16), constraints: const BoxConstraints(maxHeight: 500), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Select Trainer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx))]),
      const Divider(),
      Expanded(child: Consumer<TrainerProvider>(builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.trainers.isEmpty) return const Center(child: Text('No trainers available'));
        return ListView.builder(itemCount: provider.trainers.length, itemBuilder: (context, index) {
          final trainer = provider.trainers[index];
          return Card(elevation: 0, color: Colors.grey.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)), margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), backgroundImage: trainer.photoUrl != null ? NetworkImage(trainer.photoUrl!) : null, child: trainer.photoUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null), title: Text(trainer.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (trainer.specialization != null) Text(trainer.specialization!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)), const SizedBox(height: 4), Text('Fee: ₹${trainer.feeChargePerPerson} / month', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold))]), isThreeLine: true, trailing: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: const Size(0, 36)), onPressed: () { setState(() { _trainerId = trainer.id; _trainerName = trainer.name; }); Navigator.pop(ctx); }, child: const Text('Select'))));
        });
      })),
    ]))));
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _emailCtrl, _addressCtrl, _totalCtrl, _paidCtrl, _cashCtrl, _upiCtrl, _notesCtrl, _htCtrl, _wtCtrl, _workoutCtrl, _dietCtrl]) { c.dispose(); }
    super.dispose();
  }
}
