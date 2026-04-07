import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/expense_provider.dart';
import '../../data/models/expense_model.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  ExpenseCategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  final List<Color> _chartColors = [
     AppColors.primary,
     const Color(0xFFD0EAE4),
     const Color(0xFF8D8D9A),
     const Color(0xFFE2E4EB),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      provider.fetchExpenses();
      provider.fetchCategories();
      provider.fetchAnalysis();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Expense Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
           icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
           onPressed: () {
             if (GoRouter.of(context).canPop()) {
               GoRouter.of(context).pop();
             } else {
               GoRouter.of(context).go('/dashboard');
             }
           },
        ),
        bottom: PreferredSize(
           preferredSize: const Size.fromHeight(60),
           child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                 Tab(text: 'Add Expense'),
                 Tab(text: 'Analysis'),
              ],
           ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddExpenseTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildAddExpenseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildExpenseForm(),
          const SizedBox(height: 24),
          _buildSmallMonthlyAnalysis(),
        ],
      ),
    );
  }

  Widget _buildExpenseForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormLabel('Date'),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: AppColors.primary),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                   color: AppColors.surfaceLight,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.pink.shade50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(DateFormat('MM/dd/yyyy').format(_selectedDate), style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                     const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            _buildFormLabel('Category'),
            Consumer<ExpenseProvider>(
              builder: (context, provider, _) {
                return Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.pink.shade50),
                   ),
                   child: DropdownButtonHideUnderline(
                     child: DropdownButtonFormField<ExpenseCategoryModel>(
                       value: _selectedCategory,
                       icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                       decoration: const InputDecoration(border: InputBorder.none),
                       hint: const Text('Select a category', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                       items: provider.categories.map((cat) {
                         return DropdownMenuItem(
                           value: cat,
                           child: Text(cat.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                         );
                       }).toList(),
                       onChanged: (val) => setState(() => _selectedCategory = val),
                       validator: (val) => val == null ? 'Please select a category' : null,
                     ),
                   ),
                );
              },
            ),
            const SizedBox(height: 20),

            _buildFormLabel('Amount'),
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 16),
               decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pink.shade50),
               ),
               child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                     prefixText: '\$ ',
                     prefixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                     hintText: '0.00',
                     hintStyle: TextStyle(color: AppColors.textMuted),
                     border: InputBorder.none,
                     contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter amount' : null,
               ),
            ),
            const SizedBox(height: 20),

            _buildFormLabel('Notes (Optional)'),
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 16),
               decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pink.shade50),
               ),
               child: TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                     hintText: 'Add details about this expense...',
                     hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                     border: InputBorder.none,
                     contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
               ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String text) {
     return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
     );
  }

  Widget _buildSmallMonthlyAnalysis() {
     return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(24),
           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              const Text('Monthly Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 24),
              Row(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                    SizedBox(
                       width: 120,
                       height: 120,
                       child: Stack(
                          alignment: Alignment.center,
                          children: [
                             PieChart(
                                PieChartData(
                                   sectionsSpace: 0,
                                   centerSpaceRadius: 45,
                                   startDegreeOffset: 180,
                                   sections: [
                                      PieChartSectionData(color: AppColors.primary, value: 60, radius: 15, showTitle: false),
                                      PieChartSectionData(color: AppColors.primary.withOpacity(0.1), value: 40, radius: 15, showTitle: false),
                                   ],
                                ),
                             ),
                             Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                   Text('Total', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                   Text('\$4,250', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                             ),
                          ],
                       ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                       child: Column(
                          children: [
                             _buildMiniBar('Rent', '\$2,000', 0.6),
                             const SizedBox(height: 16),
                             _buildMiniBar('Staff', '\$1,500', 0.45),
                          ]
                       ),
                    )
                 ]
              )
           ],
        ),
     );
  }

  Widget _buildMiniBar(String label, String amount, double percent) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                 Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
           ),
           const SizedBox(height: 6),
           LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
           ),
        ],
     );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 20),
          _buildAnalysisChart(),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
     return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(30),
           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              Row(
                 children: [
                    const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(DateFormat('MMMM yyyy').format(_selectedDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                 ],
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
           ],
        ),
     );
  }

  Widget _buildAnalysisChart() {
     return Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
           final hasData = provider.analysis.isNotEmpty;
           final total = hasData ? provider.analysis.fold<double>(0, (sum, item) => sum + (item['total'] as num).toDouble()) : 0.0;
           
           return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(30),
                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                 children: [
                    SizedBox(
                       height: 220,
                       child: Stack(
                          alignment: Alignment.center,
                          children: [
                             hasData ? PieChart(
                                PieChartData(
                                   sectionsSpace: 0,
                                   centerSpaceRadius: 75,
                                   startDegreeOffset: 270,
                                   sections: provider.analysis.asMap().entries.map((e) {
                                      final index = e.key;
                                      final data = e.value;
                                      return PieChartSectionData(
                                         color: _chartColors[index % _chartColors.length],
                                         value: (data['total'] as num).toDouble(),
                                         radius: 35,
                                         showTitle: false,
                                      );
                                   }).toList(),
                                ),
                             ) : CircularProgressIndicator(color: AppColors.primary),
                             Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                   const Text('Spent Total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                   const SizedBox(height: 4),
                                   Text('\$${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                             )
                          ],
                       ),
                    ),
                    const SizedBox(height: 32),
                    if (hasData)
                       Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: provider.analysis.asMap().entries.take(4).map((e) {
                             return Row(
                                children: [
                                   Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: _chartColors[e.key % _chartColors.length])),
                                   const SizedBox(width: 6),
                                   Text(e.value['categoryName'] ?? 'Other', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                ],
                             );
                          }).toList(),
                       )
                 ],
              ),
           );
        }
     );
  }

  Widget _buildCategoryBreakdown() {
     return Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
           if (provider.analysis.isEmpty) return const SizedBox();
           final total = provider.analysis.fold<double>(0, (sum, item) => sum + (item['total'] as num).toDouble());
           
           return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(30),
                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    const Text('Category Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 24),
                    ...provider.analysis.asMap().entries.map((e) {
                       final index = e.key;
                       final data = e.value;
                       final val = (data['total'] as num).toDouble();
                       final percent = total > 0 ? (val / total) : 0.0;
                       return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                                Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                      Text(data['categoryName'] ?? 'Other', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text('\$${val.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                   ],
                                ),
                                const SizedBox(height: 4),
                                Text('${(percent * 100).toStringAsFixed(0)}% OF TOTAL', style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                   value: percent == 0 ? 0.05 : percent,
                                   backgroundColor: AppColors.surfaceLight,
                                   valueColor: AlwaysStoppedAnimation<Color>(_chartColors[index % _chartColors.length]),
                                   minHeight: 8,
                                   borderRadius: BorderRadius.circular(4),
                                ),
                             ],
                          ),
                       );
                    }).toList()
                 ],
              ),
           );
        }
     );
  }

  void _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) return;
      
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final data = {
        'categoryId': _selectedCategory!.id,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'date': _selectedDate.toIso8601String(),
        'notes': _notesController.text,
      };

      final success = await provider.addExpense(data);
      if (success && mounted) {
        _amountController.clear();
        _notesController.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense saved!')));
        provider.fetchAnalysis(); // Refresh analysis
      }
    }
  }
}
