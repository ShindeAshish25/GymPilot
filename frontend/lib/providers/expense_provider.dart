import 'package:flutter/foundation.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  List<ExpenseModel> _expenses = [];
  List<ExpenseCategoryModel> _categories = [];
  List<Map<String, dynamic>> _analysis = [];
  bool _isLoading = false;

  List<ExpenseModel> get expenses => _expenses;
  List<ExpenseCategoryModel> get categories => _categories;
  List<Map<String, dynamic>> get analysis => _analysis;
  bool get isLoading => _isLoading;

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _expenses = await _repository.getExpenses();
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnalysis() async {
    _isLoading = true;
    notifyListeners();
    try {
      _analysis = await _repository.getExpenseAnalysis();
    } catch (e) {
      debugPrint('Error fetching analysis: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final expense = await _repository.addExpense(data);
      _expenses.insert(0, expense);
      return true;
    } catch (e) {
      debugPrint('Error adding expense: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateExpense(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedExpense = await _repository.updateExpense(id, data);
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
      return true;
    } catch (e) {
      debugPrint('Error updating expense: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteExpense(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      return true;
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final category = await _repository.addCategory(data);
      _categories.add(category);
      return true;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
