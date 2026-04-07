// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../providers/member_provider.dart';

// class AddMemberModal extends StatefulWidget {
//   const AddMemberModal({super.key});

//   @override
//   State<AddMemberModal> createState() => _AddMemberModalState();
// }

// class _AddMemberModalState extends State<AddMemberModal> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final _formKey = GlobalKey<FormState>();

//   // --- Personal Tab ---
//   final _fullNameController = TextEditingController();
//   final _mobileController = TextEditingController();
//   final _emailController = TextEditingController();
//   String _selectedGender = 'Male';
//   final _addressController = TextEditingController();

//   XFile? _pickedImage;
//   Uint8List? _imageBytes;
//   final ImagePicker _picker = ImagePicker();

//   // --- Membership Tab ---
//   DateTime _startDate = DateTime.now();
//   String _selectedBatch = 'Morning';
//   double _durationMonths = 3.0; // 1 to 12
//   String _trainingType = 'General Training';

//   final _totalAmountController = TextEditingController(text: '12000');
//   final _paidAmountController = TextEditingController(text: '8000');
//   double _remainingAmount = 4000.0;

//   String _paymentMode = 'Cash';
//   final _assignedTrainerController = TextEditingController();

//   // Custom Colors to match the provided design
//   final Color _primaryRed = const Color(0xFFF5385B);
//   final Color _bgLight = const Color(0xFFF8F5F6);
//   final Color _accentColor = const Color(0xFFE2F1F3);
//   final Color _mutedColor = const Color(0xFF959AA4);

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);

//     _totalAmountController.addListener(_calculateRemaining);
//     _paidAmountController.addListener(_calculateRemaining);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _fullNameController.dispose();
//     _mobileController.dispose();
//     _emailController.dispose();
//     _addressController.dispose();
//     _totalAmountController.dispose();
//     _paidAmountController.dispose();
//     _assignedTrainerController.dispose();
//     super.dispose();
//   }

//   void _calculateRemaining() {
//     final total = double.tryParse(_totalAmountController.text) ?? 0.0;
//     final paid = double.tryParse(_paidAmountController.text) ?? 0.0;
//     setState(() {
//       _remainingAmount = total - paid;
//     });
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: source,
//         imageQuality: 70,
//         maxWidth: 800,
//       );
//       if (image != null) {
//         final bytes = await image.readAsBytes();
//         setState(() {
//           _pickedImage = image;
//           _imageBytes = bytes;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error picking image: \$e');
//     }
//   }

//   void _showImageSourceDialog() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Select Photo Source',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildSourceOption(Icons.camera_alt_outlined, 'Camera', () {
//                   if (Navigator.of(context).canPop()) {
//                     Navigator.of(context).pop();
//                   }
//                   _pickImage(ImageSource.camera);
//                 }),
//                 _buildSourceOption(Icons.photo_library_outlined, 'Gallery', () {
//                   if (Navigator.of(context).canPop()) {
//                     Navigator.of(context).pop();
//                   }
//                   _pickImage(ImageSource.gallery);
//                 }),
//               ],
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: _primaryRed.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: _primaryRed, size: 30),
//           ),
//           const SizedBox(height: 8),
//           Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   void _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;

//     final memberData = {
//       'memberId': 'MEM-\${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
//       'name': _fullNameController.text.trim(),
//       'phone': _mobileController.text,
//       'email': _emailController.text,
//       'gender': _selectedGender,
//       'address': _addressController.text,
//       'joinDate': _startDate.toIso8601String(),
//       'paymentDate': DateTime.now().toIso8601String(),
//       'batch': _selectedBatch,
//       'membershipDuration': _durationMonths.toInt(),
//       'trainingProgram': _trainingType,
//       'paymentMode': _paymentMode,
//       'totalFee': double.tryParse(_totalAmountController.text) ?? 0.0,
//       'amountPaid': double.tryParse(_paidAmountController.text) ?? 0.0,
//       'remainingAmount': _remainingAmount,
//       'paymentStatus': _remainingAmount <= 0 ? 'Paid' : 'Partial',
//       'description': _assignedTrainerController.text.isNotEmpty 
//           ? 'Assigned Trainer: \${_assignedTrainerController.text}' 
//           : null,
//     };

//     final success = await context.read<MemberProvider>().addMember(
//           memberData,
//           imageBytes: _imageBytes,
//           imageName: _pickedImage?.name,
//         );
//     if (success && mounted) {
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Ensure height takes up almost full screen to fit tabs comfortably
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.95,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           _buildAppbar(),
//           _buildTabBar(),
//           Expanded(
//             child: Form(
//               key: _formKey,
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildPersonalTab(),
//                   _buildMembershipTab(),
//                   _buildPhysicalTab(),
//                 ],
//               ),
//             ),
//           ),
//           _buildFooterButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppbar() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           GestureDetector(
//             onTap: () {
//               if (Navigator.of(context).canPop()) {
//                 Navigator.of(context).pop();
//               }
//             },
//             child: const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Icon(Icons.close, color: Colors.black87),
//             ),
//           ),
//           const Text(
//             'Add New Customer',
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
//           ),
//           TextButton(
//             onPressed: _submitForm,
//             child: Text(
//               'Save',
//               style: TextStyle(
//                   color: _primaryRed, fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildTabBar() {
//     return Container(
//       decoration: const BoxDecoration(
//         border: Border(bottom: BorderSide(color: Color(0xFFF4F4F5))),
//       ),
//       child: TabBar(
//         controller: _tabController,
//         labelColor: _primaryRed,
//         unselectedLabelColor: _mutedColor,
//         indicatorColor: _primaryRed,
//         indicatorWeight: 3,
//         labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         tabs: const [
//           Tab(text: 'Personal'),
//           Tab(text: 'Membership'),
//           Tab(text: 'Physical'),
//         ],
//       ),
//     );
//   }

//   Widget _buildPersonalTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           // Profile Photo Area
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 20),
//             decoration: BoxDecoration(
//               color: _accentColor.withOpacity(0.4),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 Center(
//                   child: Stack(
//                     children: [
//                       Container(
//                         width: 110,
//                         height: 110,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFDFCCBD),
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 4),
//                           boxShadow: [
//                             BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 10)
//                           ],
//                           image: _imageBytes != null
//                               ? DecorationImage(
//                                   image: MemoryImage(_imageBytes!),
//                                   fit: BoxFit.cover)
//                               : null,
//                         ),
//                         child: _imageBytes == null
//                             ? const Icon(Icons.person,
//                                 size: 60, color: Colors.white70)
//                             : null,
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: GestureDetector(
//                           onTap: _showImageSourceDialog,
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: _primaryRed,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2))
//                               ],
//                             ),
//                             child: const Icon(Icons.camera_alt,
//                                 size: 16, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text('Profile Photo',
//                     style:
//                         TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 Text('JPG or PNG, max 2MB',
//                     style: TextStyle(fontSize: 12, color: _mutedColor)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           _buildTextField('Full Name', _fullNameController, hint: 'John Doe'),
//           const SizedBox(height: 16),
//           _buildTextField('Mobile Number', _mobileController,
//               hint: '+1 234 567 890', keyboardType: TextInputType.phone),
//           const SizedBox(height: 16),
//           _buildTextField('Email Address', _emailController,
//               hint: 'john@example.com', keyboardType: TextInputType.emailAddress),
//           const SizedBox(height: 16),
//           _buildDropdown('Gender', _selectedGender, ['Male', 'Female', 'Other'],
//               (val) => setState(() => _selectedGender = val!)),
//           const SizedBox(height: 16),
//           _buildTextField('Address', _addressController,
//               hint: '123 Fitness Ave, Gym City', maxLines: 3),
//         ],
//       ),
//     );
//   }

//   Widget _buildMembershipTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Membership Details',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 20),
//           _buildDateField('Start Date', _startDate, () async {
//             final picked = await showDatePicker(
//               context: context,
//               initialDate: _startDate,
//               firstDate: DateTime(2000),
//               lastDate: DateTime(2101),
//               builder: (context, child) {
//                 return Theme(
//                   data: Theme.of(context).copyWith(
//                     colorScheme: ColorScheme.light(
//                       primary: _primaryRed, 
//                       onPrimary: Colors.white,
//                     ),
//                   ),
//                   child: child!,
//                 );
//               },
//             );
//             if (picked != null) {
//               setState(() => _startDate = picked);
//             }
//           }),
//           const SizedBox(height: 16),
//           const Text('Batch',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildRadioOption('Morning'),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildRadioOption('Evening'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           const Text('Duration (Months)',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//           Slider(
//             value: _durationMonths,
//             min: 1,
//             max: 12,
//             divisions: 11,
//             activeColor: _primaryRed,
//             inactiveColor: Colors.grey.shade300,
//             label: '\${_durationMonths.toInt()}m',
//             onChanged: (val) => setState(() => _durationMonths = val),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('1m', style: TextStyle(fontSize: 10, color: _mutedColor, fontWeight: FontWeight.bold)),
//                 Text('3m', style: TextStyle(fontSize: 10, color: _mutedColor, fontWeight: FontWeight.bold)),
//                 Text('6m', style: TextStyle(fontSize: 10, color: _mutedColor, fontWeight: FontWeight.bold)),
//                 Text('12m', style: TextStyle(fontSize: 10, color: _mutedColor, fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildDropdown(
//             'Training Type',
//             _trainingType,
//             ['General Training', 'Personal Training', 'Yoga', 'CrossFit'],
//             (val) => setState(() => _trainingType = val!),
//           ),
//           const SizedBox(height: 24),
//           // Payment Box
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: _bgLight,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _buildAmountField('TOTAL AMOUNT', _totalAmountController, isEditing: true),
//                 ),
//                 Expanded(
//                   child: _buildAmountField('PAID AMOUNT', _paidAmountController, isEditing: true, textColor: Colors.green),
//                 ),
//                 Expanded(
//                   child: _buildAmountField('REMAINING', null,
//                       isEditing: false, textColor: _primaryRed, displayValue: _remainingAmount.toStringAsFixed(0)),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildDropdown('Payment Mode', _paymentMode,
//               ['Cash', 'UPI', 'Both (Split)'], (val) => setState(() => _paymentMode = val!)),
//           const SizedBox(height: 16),
//           _buildTextField('Assigned Trainer', _assignedTrainerController,
//               hint: 'Search Trainer...'),
//         ],
//       ),
//     );
//   }

//   Widget _buildPhysicalTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Physical Records',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: _primaryRed.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(8)
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.add, size: 16, color: _primaryRed),
//                     const SizedBox(width: 4),
//                     Text('Add Entry', style: TextStyle(color: _primaryRed, fontWeight: FontWeight.bold, fontSize: 13))
//                   ],
//                 ),
//               )
//             ],
//           ),
//           const SizedBox(height: 20),
//           // Record Card
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.grey.shade200),
//               boxShadow: [
//                 BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)
//               ]
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: _accentColor.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(4)
//                       ),
//                       child: Text('CURRENT STATUS - OCT 24, 2023', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
//                     ),
//                     Icon(Icons.more_vert, size: 20, color: _mutedColor)
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.shade50,
//                               borderRadius: BorderRadius.circular(8)
//                             ),
//                             child: Icon(Icons.height, color: Colors.blue.shade600),
//                           ),
//                           const SizedBox(width: 12),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('HEIGHT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _mutedColor)),
//                               const Text('175 cm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.shade50,
//                               borderRadius: BorderRadius.circular(8)
//                             ),
//                             child: Icon(Icons.monitor_weight_outlined, color: Colors.orange.shade600),
//                           ),
//                           const SizedBox(width: 12),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('WEIGHT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _mutedColor)),
//                               const Text('78.5 kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 const Divider(),
//                 const SizedBox(height: 12),
//                 Text('WORKOUT PLAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _mutedColor)),
//                 const SizedBox(height: 4),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: _bgLight,
//                     borderRadius: BorderRadius.circular(8)
//                   ),
//                   child: const Text('Strength Training (Push/Pull/Legs)', style: TextStyle(fontSize: 13, color: Colors.black87)),
//                 ),
//                 const SizedBox(height: 12),
//                 Text('DIET PLAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _mutedColor)),
//                 const SizedBox(height: 4),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: _bgLight,
//                     borderRadius: BorderRadius.circular(8)
//                   ),
//                   child: const Text('High Protein, Low Carb (2400 kcal)', style: TextStyle(fontSize: 13, color: Colors.black87)),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   // --- Build Helpers ---

//   Widget _buildTextField(String label, TextEditingController controller,
//       {String? hint, int maxLines = 1, TextInputType? keyboardType}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
//           child: Text(label,
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//         ),
//         TextFormField(
//           controller: controller,
//           maxLines: maxLines,
//           keyboardType: keyboardType,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.grey.shade300)),
//             enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.grey.shade300)),
//             focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: _primaryRed)),
//           ),
//           validator: (val) => val == null || val.isEmpty ? 'Required' : null,
//         )
//       ],
//     );
//   }

//   Widget _buildDropdown(
//       String label, String value, List<String> items, Function(String?) onChanged) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
//           child: Text(label,
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.shade300)),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: value,
//               isExpanded: true,
//               icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
//               items: items
//                   .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                   .toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _buildDateField(String label, DateTime date, VoidCallback onTap) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
//           child: Text(label,
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//         ),
//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade300)),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(DateFormat('MM/dd/yyyy').format(date),
//                     style: const TextStyle(fontSize: 14, color: Colors.black87)),
//                 Icon(Icons.calendar_today_outlined,
//                     size: 18, color: Colors.grey.shade600),
//               ],
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _buildRadioOption(String label) {
//     final isSelected = _selectedBatch == label;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedBatch = label),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? _primaryRed.withOpacity(0.1) : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: isSelected ? _primaryRed : Colors.grey.shade300),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           label,
//           style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: isSelected ? _primaryRed : Colors.black87),
//         ),
//       ),
//     );
//   }

//   Widget _buildAmountField(String label, TextEditingController? controller,
//       {required bool isEditing, Color textColor = Colors.black87, String displayValue = ''}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 color: _mutedColor,
//                 letterSpacing: 0.5)),
//         const SizedBox(height: 4),
//         if (isEditing)
//           TextFormField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
//             decoration: const InputDecoration(
//                 isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
//           )
//         else
//           Text(
//             displayValue,
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
//           )
//       ],
//     );
//   }

//   Widget _buildFooterButton() {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.9),
//         border: Border(top: BorderSide(color: Colors.grey.shade200)),
//       ),
//       child: Consumer<MemberProvider>(
//         builder: (context, provider, _) {
//           return ElevatedButton(
//             onPressed: provider.isLoading ? null : _submitForm,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _primaryRed,
//               foregroundColor: Colors.white,
//               minimumSize: const Size(double.infinity, 56),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               elevation: 4,
//               shadowColor: _primaryRed.withOpacity(0.4),
//             ),
//             child: provider.isLoading
//                 ? const SizedBox(
//                     height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                 : const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.person_add, size: 20),
//                       SizedBox(width: 8),
//                       Text('Register Customer',
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//           );
//         },
//       ),
//     );
//   }
// }


// lib/features/members/widgets/add_member_modal.dart
// ✅ Duration dropdown (1-12 months) | Auto end-date | Start date picker | Professional design

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
  int _durationMonths = 1; // ← dropdown value
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

  // End date is always derived from start + duration
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

  Future<void> _pickImage(ImageSource src) async {
    try {
      final img = await _picker.pickImage(source: src, imageQuality: 70, maxWidth: 800);
      if (img != null) {
        final bytes = await img.readAsBytes();
        setState(() { _pickedImage = img; _imageBytes = bytes; });
      }
    } catch (e) { debugPrint('img err: $e'); }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Select Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _PickOpt(icon: Icons.camera_alt_outlined, label: 'Camera', color: _red,
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
            _PickOpt(icon: Icons.photo_library_outlined, label: 'Gallery', color: _red,
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
          ]),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) { _tabController.animateTo(0); return; }

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

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          _handle(),
          _header(),
          _tabs(),
          Expanded(
            child: Form(
              key: _formKey,
              child: TabBarView(controller: _tabController, children: [
                _personalTab(), _membershipTab(), _physicalTab(),
              ]),
            ),
          ),
          _footer(),
        ],
      ),
    );
  }

  Widget _handle() => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Center(child: Container(width: 44, height: 4,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.close, size: 18, color: AppColors.textMuted)),
      ),
      const Expanded(child: Text('Add New Member', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
      TextButton(
        onPressed: _submit,
        style: TextButton.styleFrom(
          backgroundColor: _red.withOpacity(0.1), foregroundColor: _red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ]),
  );

  Widget _tabs() => Container(
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
    child: TabBar(
      controller: _tabController,
      labelColor: _red, unselectedLabelColor: AppColors.textMuted,
      indicatorColor: _red, indicatorWeight: 3,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      tabs: const [Tab(text: 'Personal'), Tab(text: 'Membership'), Tab(text: 'Physical')],
    ),
  );

  Widget _footer() => Container(
    padding: EdgeInsets.only(left: 16, right: 16, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12),
    decoration: BoxDecoration(color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100))),
    child: Consumer<MemberProvider>(
      builder: (ctx, p, _) => ElevatedButton.icon(
        onPressed: p.isLoading ? null : _submit,
        icon: p.isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.person_add_rounded, size: 20),
        label: Text(p.isLoading ? 'Saving...' : 'Save Member',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _red, foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
        ),
      ),
    ),
  );

  // ── Personal tab ─────────────────────────────────────────────
  Widget _personalTab() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
    child: Column(
      children: [
        GestureDetector(
          onTap: _showImagePicker,
          child: Stack(alignment: Alignment.center, children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _red.withOpacity(0.07),
                border: Border.all(color: _red.withOpacity(0.25), width: 2),
                image: _imageBytes != null
                    ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover) : null,
              ),
              child: _imageBytes == null
                  ? Icon(Icons.person_rounded, size: 46, color: _red.withOpacity(0.35)) : null,
            ),
            Positioned(bottom: 2, right: 2,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: _red, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        Text('Tap to add photo', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 20),
        _field('Full Name', _nameCtrl, hint: 'e.g. Rahul Sharma', icon: Icons.person_outline, required: true),
        const SizedBox(height: 12),
        _field('Mobile Number', _mobileCtrl, hint: '+91 98765 43210', icon: Icons.phone_outlined,
            type: TextInputType.phone, required: true),
        const SizedBox(height: 12),
        _field('Email Address', _emailCtrl, hint: 'rahul@example.com', icon: Icons.email_outlined,
            type: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _drop('Gender', _gender, ['Male', 'Female', 'Other'],
            (v) => setState(() => _gender = v!), icon: Icons.wc_outlined),
        const SizedBox(height: 12),
        _field('Address', _addressCtrl, hint: '123 Fitness Colony, Pune',
            icon: Icons.location_on_outlined, maxLines: 2),
      ],
    ),
  );

  // ── Membership tab ────────────────────────────────────────────
  Widget _membershipTab() {
    final fmt = DateFormat('dd MMM yyyy');
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Duration dropdown ──────────────────────────────
          _lbl('Membership Duration'),
          const SizedBox(height: 8),
          _intDrop(_durationMonths, List.generate(12, (i) => i + 1),
              (v) => setState(() => _durationMonths = v!),
              itemLabel: (m) => '$m Month${m > 1 ? 's' : ''}',
              icon: Icons.timelapse_outlined),
          const SizedBox(height: 14),

          // ── Start & Auto End date ──────────────────────────
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _lbl('Start Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickStartDate,
                  child: _DateTile(label: fmt.format(_startDate), icon: Icons.calendar_today_outlined,
                      color: AppColors.primary, editable: true),
                ),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _lbl('End Date (auto)'),
                const SizedBox(height: 8),
                _DateTile(label: fmt.format(_endDate), icon: Icons.event_outlined,
                    color: Colors.green, editable: false),
              ])),
            ],
          ),
          const SizedBox(height: 14),

          // Batch
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
                      color: sel ? _red.withOpacity(0.08) : _bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? _red : Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(b == 'Morning' ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                          size: 15, color: sel ? _red : AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(b, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                          color: sel ? _red : AppColors.textSecondary)),
                    ]),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          _drop('Training Type', _trainingType, [
            'General Training', 'Personal Training', 'Cardio', 'Strength',
            'Weight Loss', 'Weight Gain', 'Yoga', 'CrossFit', 'HIIT', 'Other',
          ], (v) => setState(() => _trainingType = v!), icon: Icons.fitness_center_outlined),
          const SizedBox(height: 18),

          // Payment box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('PAYMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                  color: AppColors.textMuted, letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _InlineAmt(label: 'Total (₹)', ctrl: _totalCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _InlineAmt(label: 'Paid (₹)', ctrl: _paidCtrl, valColor: Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Remaining', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                      color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text('₹${_remaining.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                          color: _remaining > 0 ? _red : Colors.green)),
                ])),
              ]),
            ]),
          ),
          const SizedBox(height: 14),

          _lbl('Payment Mode'),
          const SizedBox(height: 8),
          Row(
            children: ['Cash', 'UPI', 'Both'].map((m) {
              final sel = _paymentMode == m;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _paymentMode = m),
                  child: Container(
                    margin: EdgeInsets.only(right: m != 'Both' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: sel ? _red.withOpacity(0.08) : _bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? _red : Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Text(m, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                        color: sel ? _red : AppColors.textSecondary)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _field('Assigned Trainer (optional)', _trainerCtrl,
              hint: 'e.g. Deepak Patil', icon: Icons.person_pin_outlined),
        ],
      ),
    );
  }

  // ── Physical tab ──────────────────────────────────────────────
  Widget _physicalTab() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
          const SizedBox(width: 10),
          const Expanded(child: Text('Physical details are optional. You can add or update anytime.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        ]),
      ),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: _field('Height (cm)', _heightCtrl, hint: '170',
            icon: Icons.height, type: TextInputType.number)),
        const SizedBox(width: 12),
        Expanded(child: _field('Weight (kg)', _weightCtrl, hint: '70',
            icon: Icons.monitor_weight_outlined, type: TextInputType.number)),
      ]),
      const SizedBox(height: 12),
      _field('Workout Plan', _workoutCtrl, hint: 'e.g. Strength Training — Push/Pull/Legs',
          icon: Icons.fitness_center_outlined, maxLines: 2),
      const SizedBox(height: 12),
      _field('Diet Plan', _dietCtrl, hint: 'e.g. High Protein, Low Carb (2400 kcal)',
          icon: Icons.restaurant_outlined, maxLines: 2),
    ]),
  );

  // ── Helpers ───────────────────────────────────────────────────
  Widget _lbl(String t) => Text(t,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  Widget _field(String label, TextEditingController ctrl, {
    String? hint, TextInputType? type, int maxLines = 1, IconData? icon, bool required = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.only(bottom: 6), child: _lbl(label)),
      TextFormField(
        controller: ctrl, keyboardType: type, maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.textMuted) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          filled: true, fillColor: _bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
      ),
    ],
  );

  Widget _drop(String label, String value, List<String> items, Function(String?) onChanged, {IconData? icon}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.only(bottom: 6), child: _lbl(label)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300)),
        child: Row(children: [
          if (icon != null) ...[Icon(icon, size: 18, color: AppColors.textMuted), const SizedBox(width: 8)],
          Expanded(child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: value, isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ))),
        ]),
      ),
    ],
  );

  Widget _intDrop(int value, List<int> items, Function(int?) onChanged,
      {required String Function(int) itemLabel, IconData? icon}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300)),
    child: Row(children: [
      if (icon != null) ...[Icon(icon, size: 18, color: AppColors.textMuted), const SizedBox(width: 8)],
      Expanded(child: DropdownButtonHideUnderline(child: DropdownButton<int>(
        value: value, isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
        items: items.map((m) => DropdownMenuItem(value: m, child: Text(itemLabel(m)))).toList(),
        onChanged: onChanged,
      ))),
    ]),
  );
}

// Sub-widgets
class _DateTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool editable;
  const _DateTile({required this.label, required this.icon, required this.color, required this.editable});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.22)),
    ),
    child: Row(children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color))),
      if (editable) Icon(Icons.edit_outlined, size: 13, color: color.withOpacity(0.6)),
    ]),
  );
}

class _InlineAmt extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final Color valColor;
  const _InlineAmt({required this.label, required this.ctrl, this.valColor = AppColors.textPrimary});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
      const SizedBox(height: 4),
      TextFormField(
        controller: ctrl, keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valColor),
        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4), border: InputBorder.none),
      ),
    ],
  );
}

class _PickOpt extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PickOpt({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 26)),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    ]),
  );
}