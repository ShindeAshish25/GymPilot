const mongoose = require('mongoose');

const AttendanceSchema = new mongoose.Schema({
  gymId: { type: mongoose.Schema.Types.ObjectId, ref: 'gym', required: true },
  memberId: { type: mongoose.Schema.Types.ObjectId, ref: 'member', required: true },
  checkInDate: { type: Date, required: true },
  checkInTime: { type: String, required: true },
});

module.exports = mongoose.model('attendance', AttendanceSchema);
