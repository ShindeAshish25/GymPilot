const mongoose = require('mongoose');

const GymSchema = new mongoose.Schema({
  gymId: { type: String, unique: true },
  gymName: { type: String, required: true },
  fullName: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  mobileNumber: { type: String, required: true }, // renamed from phone to match request
  gender: { type: String, enum: ['Male', 'Female', 'Other'] },
  dateOfBirth: { type: Date },
  passwordHash: { type: String, required: true },
  logoUrl: { type: String },
  address: { type: String },
  subscriptionMonths: { type: Number, required: true, min: 1, max: 12 },
  isFreeTrial: { type: Boolean, default: false },
  planStartDate: { type: Date, default: Date.now },
  planEndDate: { type: Date },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('gym', GymSchema);
