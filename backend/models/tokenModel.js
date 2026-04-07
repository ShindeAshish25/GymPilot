const mongoose = require('mongoose');

const BlacklistedTokenSchema = new mongoose.Schema({
  token: {
    type: String,
    required: true,
    index: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
    expires: '5d', // Automatically remove after 5 days (matching JWT expiry)
  },
});

module.exports = mongoose.model('blacklistedToken', BlacklistedTokenSchema);
