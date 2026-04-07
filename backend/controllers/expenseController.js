const Expense = require('../models/expenseModel');
const ExpenseCategory = require('../models/expenseCategoryModel');
const mongoose = require('mongoose');

// --- Expense Category Controllers ---

exports.getCategories = async (req, res) => {
  try {
    const categories = await ExpenseCategory.find({ gymId: req.gym.id });
    res.json(categories);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.addCategory = async (req, res) => {
  try {
    const newCategory = new ExpenseCategory({
      ...req.body,
      gymId: req.gym.id
    });
    const category = await newCategory.save();
    res.json(category);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// --- Expense Controllers ---

exports.addExpense = async (req, res) => {
  try {
    const newExpense = new Expense({
      ...req.body,
      gymId: req.gym.id
    });
    const expense = await newExpense.save();
    res.json(expense);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getExpenses = async (req, res) => {
  try {
    const expenses = await Expense.find({ gymId: req.gym.id }).sort({ date: -1 });
    res.json(expenses);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getExpenseAnalysis = async (req, res) => {
  try {
    const gymId = new mongoose.Types.ObjectId(req.gym.id);
    const analysis = await Expense.aggregate([
      { $match: { gymId } },
      {
        $group: {
          _id: "$category",
          total: { $sum: "$amount" }
        }
      }
    ]);
    res.json(analysis);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
