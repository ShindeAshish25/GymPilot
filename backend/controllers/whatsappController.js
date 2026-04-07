const Member = require('../models/memberModel');
const { sendWhatsAppMessage } = require('../services/whatsappService');

exports.sendOverdueReminder = async (req, res) => {
  try {
    const { memberId } = req.body;
    
    const member = await Member.findOne({ memberId, gymId: req.gym.id });
    
    if (!member) {
      return res.status(404).json({ message: 'Member not found' });
    }

    if (member.paymentStatus === 'Paid') {
      return res.status(400).json({ message: 'Member has no pending payments.' });
    }

    const pendingAmount = member.totalFee - member.amountPaid;
    const message = `Hello ${member.name}, \n\nThis is a gentle reminder from Power Fitness Gym that your payment of ₹${pendingAmount} is currently overdue. Please clear your dues on your next visit to avoid suspension of membership.\n\nThank you!`;

    await sendWhatsAppMessage(member.phone, message);

    res.status(200).json({ message: 'Reminder sent successfully' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
