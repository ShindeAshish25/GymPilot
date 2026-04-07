const mongoose = require('mongoose');

const ExpenseCategorySchema = new mongoose.Schema({
  gymId: { type: mongoose.Schema.Types.ObjectId, ref: 'gym', required: true },
  name: { type: String, required: true },
  logo: { type: String }, // URL or Base64, if empty frontend will use first letter
  isDefault: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

// Avoid duplicate categories for same gym
ExpenseCategorySchema.index({ gymId: 1, name: 1 }, { unique: true });

module.exports = mongoose.model('expenseCategory', ExpenseCategorySchema);
