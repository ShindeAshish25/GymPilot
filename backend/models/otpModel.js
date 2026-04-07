// const mongoose = require('mongoose');

// const OTPSchema = new mongoose.Schema({
//   email: { type: String, required: true },
//   otp: { type: String, required: true },
//   verified: { type: Boolean, default: false },
//   createdAt: { type: Date, default: Date.now, index: { expires: 600 } }, // Expires in 10 minutes
// });

// module.exports = mongoose.model('otp', OTPSchema);

const mongoose = require('mongoose');

const OTPSchema = new mongoose.Schema({
  email: { type: String, required: true },
  otp: { type: String, required: true },
  verified: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now, expires: 600 },
});

module.exports = mongoose.model('otp', OTPSchema);