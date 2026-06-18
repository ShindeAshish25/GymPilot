const mongoose = require('mongoose');

const InquirySchema = new mongoose.Schema({
  gymId: { type: mongoose.Schema.Types.ObjectId, ref: 'gym', required: true },
  name: { type: String, required: true },
  phone: { type: String, required: true },
  email: { type: String },
  gender: { type: String, enum: ['Male', 'Female', 'Other'] },
  inquiryDate: { type: Date, default: Date.now },
  planToJoinDate: { type: Date },
  address: { type: String },
  status: { type: String, enum: ['Pending', 'Joined', 'Cancelled'], default: 'Pending' },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('inquiry', InquirySchema);
