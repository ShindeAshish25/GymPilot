const Payment = require('../models/paymentModel');
const Member = require('../models/memberModel');

exports.addPayment = async (req, res) => {
  const { memberId, amount, paymentMethod } = req.body;

  try {
    // Verify member belongs to this gym
    const member = await Member.findOne({ _id: memberId, gymId: req.gym.id });
    if (!member) {
      return res.status(404).json({ msg: 'Member not found in your gym' });
    }

    const newPayment = new Payment({
      gymId: req.gym.id,
      memberId,
      amount,
      paymentMethod,
    });

    const payment = await newPayment.save();

    // Update the member's paid amount tracking
    member.amountPaid += amount;
    member.lastPaymentDate = new Date();
    await member.save();

    res.json(payment);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getPayments = async (req, res) => {
  try {
    const payments = await Payment.find({ 
      memberId: req.params.memberId, 
      gymId: req.gym.id 
    }).sort({ paymentDate: -1 });
    res.json(payments);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
