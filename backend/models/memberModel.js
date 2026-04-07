const mongoose = require('mongoose');

const PhysicalDetailSchema = new mongoose.Schema({
  date: { type: Date, default: Date.now },
  height: { type: Number },
  weight: { type: Number },
  workoutPlan: { type: String },
  dietPlan: { type: String },
  description: { type: String }
});

const MemberSchema = new mongoose.Schema({
  gymId: { type: mongoose.Schema.Types.ObjectId, ref: 'gym', required: true },
  memberId: { type: String, required: true },
  name: { type: String, required: true },
  phone: { type: String, required: true },
  email: { type: String },
  gender: { type: String },
  dob: { type: Date },
  address: { type: String },
  photoUrl: { type: String },
  
  // Membership Details
  membershipDuration: { type: Number }, // In months
  membershipStartDate: { type: Date },
  membershipEndDate: { type: Date },
  joinDate: { type: Date, default: Date.now },
  batch: { type: String, enum: ['Morning', 'Evening'] },
  trainingType: { type: String }, // e.g., 'cardio', 'strength', 'personal', etc.
  trainerId: { type: mongoose.Schema.Types.ObjectId, ref: 'trainer' },
  
  // Payment Details
  totalFee: { type: Number },
  amountPaid: { type: Number },
  remainingAmount: { type: Number },
  paymentStatus: { type: String, enum: ['Paid', 'Partial', 'Unpaid'], default: 'Unpaid' },
  paymentDate: { type: Date },
  paymentMode: { type: String, enum: ['UPI', 'Cash', 'Both'] },
  cashAmount: { type: Number, default: 0 },
  upiAmount: { type: Number, default: 0 },
  description: { type: String },
  
  // Physical Details Progress
  physicalDetails: [PhysicalDetailSchema],
  
  createdAt: { type: Date, default: Date.now },
});

MemberSchema.index({ gymId: 1, phone: 1 }, { unique: true });
MemberSchema.index({ gymId: 1, email: 1 }, { sparse: true });

module.exports = mongoose.model('member', MemberSchema);
