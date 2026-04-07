const mongoose = require('mongoose');

const SubscriptionPlanSchema = new mongoose.Schema({
  planName: { type: String, required: true },
  memberLimit: { type: Number, required: true },
  priceMonthly: { type: Number, required: true },
  features: [{ type: String }],
});

module.exports = mongoose.model('subscription_plan', SubscriptionPlanSchema);
