const Member = require('../models/memberModel');
const { calculateMemberStatus } = require('../utils/membershipUtils');

exports.addMember = async (req, res) => {
  const { phone, email } = req.body;
  try {
    // Check if member with same phone or email already exists IN THIS GYM
    const existingMember = await Member.findOne({
      gymId: req.gym.id,
      $or: [{ phone }, { email: email || 'never-match' }]
    });

    if (existingMember) {
      return res.status(400).json({ msg: 'Member with this phone or email already exists in your gym' });
    }

    const photoUrl = req.file ? `/uploads/logos/${req.file.filename}` : null;

    const newMember = new Member({
      ...req.body,
      photoUrl,
      gymId: req.gym.id,
    });

    const member = await newMember.save();
    res.json(member);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getMembers = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const total = await Member.countDocuments({ gymId: req.gym.id });
    const members = await Member.find({ gymId: req.gym.id })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const membersWithStatus = members.map(member => {
      const status = calculateMemberStatus(member.paymentDate, member.membershipDuration, member.membershipEndDate);
      return { ...member._doc, status };
    });

    res.json({
      members: membersWithStatus,
      currentPage: page,
      totalPages: Math.ceil(total / limit),
      totalMembers: total
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getExpiringMembers = async (req, res) => {
  try {
    // This is a bit tricky for a simple query because status is calculated dynamically.
    // For large DBs, we'd store status or indexing expiryDate.
    // For now, we fetch all and filter, or use range query if possible.
    
    // Efficient range query: members whose expiry date is between today and today + 2 days
    const allMembers = await Member.find({ gymId: req.gym.id });
    const expiring = allMembers.filter(m => {
      const status = calculateMemberStatus(m.paymentDate, m.membershipDuration, m.membershipEndDate);
      return status === 'EXPIRING SOON';
    });

    res.json(expiring);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.updateMember = async (req, res) => {
  try {
    let member = await Member.findOne({ _id: req.params.id, gymId: req.gym.id });

    if (!member) return res.status(404).json({ msg: 'Member not found or unauthorized' });

    member = await Member.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true }
    );

    res.json(member);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.deleteMember = async (req, res) => {
  try {
    const member = await Member.findOneAndRemove({ _id: req.params.id, gymId: req.gym.id });

    if (!member) return res.status(404).json({ msg: 'Member not found or unauthorized' });

    res.json({ msg: 'Member removed' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
