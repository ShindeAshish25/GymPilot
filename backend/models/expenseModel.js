const mongoose = require('mongoose');

const ExpenseSchema = new mongoose.Schema({
  gymId: { type: mongoose.Schema.Types.ObjectId, ref: 'gym', required: true },
  date: { type: Date, default: Date.now },
  category: { type: String, required: true }, // Name of the category
  amount: { type: Number, required: true },
  notes: { type: String },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('expense', ExpenseSchema);
