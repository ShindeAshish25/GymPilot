const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const {
  getCategories,
  addCategory,
  addExpense,
  getExpenses,
  getExpenseAnalysis,
  updateExpense,
  deleteExpense
} = require('../controllers/expenseController');

// Categories
router.get('/categories', auth, getCategories);
router.post('/categories', auth, addCategory);

// Expenses
router.get('/', auth, getExpenses);
router.post('/', auth, addExpense);
router.get('/analysis', auth, getExpenseAnalysis);
router.put('/:id', auth, updateExpense);
router.delete('/:id', auth, deleteExpense);

module.exports = router;
