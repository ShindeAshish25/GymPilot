const mongoose = require('mongoose');

const PaymentSchema = new mongoose.Schema({
  gymId: { type: mongoose.Schema.Types.ObjectId, ref: 'gym', required: true },
  memberId: { type: mongoose.Schema.Types.ObjectId, ref: 'member', required: true },
  amount: { type: Number, required: true },
  paymentMethod: { type: String, enum: ['Cash', 'Card', 'UPI', 'Bank Transfer'] },
  paymentDate: { type: Date, default: Date.now },
  recordedBy: { type: String },
});

module.exports = mongoose.model('payment', PaymentSchema);
