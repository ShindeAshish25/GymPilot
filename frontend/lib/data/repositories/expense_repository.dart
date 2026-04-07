import 'dart:convert';
import '../models/expense_model.dart';
import '../services/api_service.dart';

class ExpenseRepository {
  final ApiService _apiService = ApiService();

  Future<List<ExpenseModel>> getExpenses() async {
    final response = await _apiService.get('/expenses');
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ExpenseModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<List<ExpenseCategoryModel>> getCategories() async {
    final response = await _apiService.get('/expenses/categories');
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ExpenseCategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expense categories');
    }
  }

  Future<ExpenseModel> addExpense(Map<String, dynamic> data) async {
    final response = await _apiService.post('/expenses', data);
    if (response.statusCode == 200) {
      return ExpenseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add expense');
    }
  }

  Future<ExpenseCategoryModel> addCategory(Map<String, dynamic> data) async {
    final response = await _apiService.post('/expenses/categories', data);
    if (response.statusCode == 200) {
      return ExpenseCategoryModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add category');
    }
  }

  Future<List<Map<String, dynamic>>> getExpenseAnalysis() async {
    final response = await _apiService.get('/expenses/analysis');
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load expense analysis');
    }
  }
}
