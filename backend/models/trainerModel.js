const mongoose = require('mongoose');

const TrainerSchema = new mongoose.Schema({
  gymId: { type: mongoose.Schema.Types.ObjectId, ref: 'gym', required: true },
  name: { type: String, required: true },
  phone: { type: String, required: true },
  photoUrl: { type: String },
  specialization: { type: String },
  feeChargePerPerson: { type: Number, default: 0 },
  experience: { type: String },
  assignedMembers: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('trainer', TrainerSchema);
