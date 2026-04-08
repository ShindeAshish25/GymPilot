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

  // List filters
  String _listFilter = 'Month';
  DateTimeRange? _customDateRange;

  final List<Color> _chartColors = [
     AppColors.primary,
     const Color(0xFFD0EAE4),
     const Color(0xFF8D8D9A),
     const Color(0xFFE2E4EB),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                 Tab(text: 'Add'),
                 Tab(text: 'List'),
                 Tab(text: 'Analysis'),
              ],
           ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddExpenseTab(),
          _buildListTab(),
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
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFormLabel('Category'),
                TextButton(
                  onPressed: _showAddCategoryDialog,
                  child: const Text('+ Add Type', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
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
                     prefixText: '₹ ',
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
     return Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
           final hasData = provider.analysis.isNotEmpty;
           final total = hasData ? provider.analysis.fold<double>(0, (sum, item) => sum + (item['total'] as num).toDouble()) : 0.0;
           final sortedAnalysis = List<Map<String, dynamic>>.from(provider.analysis)
              ..sort((a, b) => (b['total'] as num).compareTo(a['total'] as num));
           final topCategories = sortedAnalysis.take(2).toList();

           return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(24),
                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                //  children: [
                //     const Text('Monthly Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                //     const SizedBox(height: 24),
                //     hasData ? Row(
                //        crossAxisAlignment: CrossAxisAlignment.center,
                //        children: [
                //           SizedBox(
                //              width: 120,
                //              height: 120,
                //              child: Stack(
                //                 alignment: Alignment.center,
                //                 children: [
                //                    PieChart(
                //                       PieChartData(
                //                          sectionsSpace: 0,
                //                          centerSpaceRadius: 45,
                //                          startDegreeOffset: 180,
                //                          sections: sortedAnalysis.asMap().entries.map((e) {
                //                             final index = e.key;
                //                             return PieChartSectionData(
                //                                color: _chartColors[index % _chartColors.length], 
                //                                value: (e.value['total'] as num).toDouble(), 
                //                                radius: 15, 
                //                                showTitle: false
                //                             );
                //                          }).toList(),
                //                       ),
                //                    ),
                //                    Column(
                //                       mainAxisSize: MainAxisSize.min,
                //                       children: [
                //                          const Text('Total', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                //                          Text('₹${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                //                       ],
                //                    ),
                //                 ],
                //              ),
                //           ),
                //           const SizedBox(width: 24),
                //           Expanded(
                //              child: Column(
                //                 children: topCategories.asMap().entries.map((e) {
                //                   final val = (e.value['total'] as num).toDouble();
                //                   final percent = total > 0 ? (val / total) : 0.0;
                //                   return Padding(
                //                      padding: const EdgeInsets.only(bottom: 16),
                //                      child: _buildMiniBar(e.value['categoryName'] ?? 'Other', '₹${val.toStringAsFixed(0)}', percent, color: _chartColors[e.key % _chartColors.length]),
                //                   );
                //                 }).toList(),
                //              ),
                //           )
                //        ]
                //     ) : const Center(child: Text('No expenses recorded yet', style: TextStyle(color: AppColors.textMuted))),
                //  ],
              ),
           );
        }
     );
  }

  Widget _buildMiniBar(String label, String amount, double percent, {Color color = AppColors.primary}) {
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
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
           ),
        ],
     );
  }

  Widget _buildListTab() {
    return Column(
      children: [
        _buildListFilters(),
        Expanded(
          child: Consumer<ExpenseProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.expenses.isEmpty) {
                 return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              final now = DateTime.now();
              final filtered = provider.expenses.where((e) {
                if (_listFilter == 'Day') {
                  return e.date.year == now.year && e.date.month == now.month && e.date.day == now.day;
                } else if (_listFilter == 'Week') {
                  // A week consists of the last 7 days
                  final weekAgo = now.subtract(const Duration(days: 7));
                  return e.date.isAfter(weekAgo) || e.date.isAtSameMomentAs(weekAgo);
                } else if (_listFilter == 'Month') {
                  return e.date.year == now.year && e.date.month == now.month;
                } else if (_listFilter == 'Custom' && _customDateRange != null) {
                  final start = _customDateRange!.start;
                  final end = _customDateRange!.end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
                  return e.date.isAfter(start.subtract(const Duration(milliseconds: 1))) && e.date.isBefore(end.add(const Duration(milliseconds: 1)));
                }
                return true;
              }).toList();

              if (filtered.isEmpty) {
                 return const Center(child: Text('No expenses found for this period.', style: TextStyle(color: AppColors.textMuted)));
              }

              final groupedExpenses = <String, List<ExpenseModel>>{};
              for (var exp in filtered) {
                 groupedExpenses.putIfAbsent(exp.categoryName, () => []).add(exp);
              }
              final categoryNames = groupedExpenses.keys.toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categoryNames.length,
                itemBuilder: (context, index) {
                  final catName = categoryNames[index];
                  final exps = groupedExpenses[catName]!;
                  final catTotal = exps.fold(0.0, (sum, item) => sum + item.amount);

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                        ),
                        title: Text(catName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                        trailing: Text('₹${catTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                        children: exps.map((exp) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exp.notes != null && exp.notes!.isNotEmpty ? exp.notes! : 'No notes provided',
                                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)
                                      ),
                                      const SizedBox(height: 2),
                                      Text(DateFormat('MMM dd, yyyy').format(exp.date), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                Text('₹${exp.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editExpenseDialog(exp);
                                    } else if (value == 'delete') {
                                      _deleteExpenseConfirm(exp);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListFilters() {
    final filters = ['Day', 'Week', 'Month', 'Custom'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _listFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter, style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                )),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade200)),
                onSelected: (selected) async {
                  if (selected) {
                    if (filter == 'Custom') {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _customDateRange,
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(primary: AppColors.primary),
                          ),
                          child: child!,
                        ),
                      );
                      if (range != null) {
                        setState(() {
                          _listFilter = 'Custom';
                          _customDateRange = range;
                        });
                      }
                    } else {
                      setState(() {
                        _listFilter = filter;
                      });
                    }
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
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
                                   Text('₹${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
                                      Text('₹${val.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  void _showAddCategoryDialog() {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Expense Type'),
        content: TextField(
          controller: catController,
          decoration: InputDecoration(
            hintText: 'e.g. Electricity, Operations',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (catController.text.trim().isEmpty) return;
              final p = Provider.of<ExpenseProvider>(context, listen: false);
              final ok = await p.addCategory({'name': catController.text.trim()});
              if (ok && mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Category added!')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteExpenseConfirm(ExpenseModel exp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text('Are you sure you want to delete this expense of ₹${exp.amount.toStringAsFixed(2)} under ${exp.categoryName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
              final success = await provider.deleteExpense(exp.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense deleted')));
                provider.fetchAnalysis(); // sync pie chart dynamically
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editExpenseDialog(ExpenseModel exp) {
    final editAmountController = TextEditingController(text: exp.amount.toString());
    final editNotesController = TextEditingController(text: exp.notes ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${exp.categoryName} Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: editNotesController,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAmt = double.tryParse(editAmountController.text);
              if (newAmt == null || newAmt <= 0) return;
              
              Navigator.pop(ctx);
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
              final success = await provider.updateExpense(exp.id, {
                'amount': newAmt,
                'notes': editNotesController.text,
              });
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense updated')));
                provider.fetchAnalysis(); // sync pie chart dynamically
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) return;
      
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final data = {
        'category': _selectedCategory!.name, // Submitting name since backend expects string category name usually or update backend model 
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
