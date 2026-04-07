const Member = require('../models/memberModel');
const Expense = require('../models/expenseModel');
const Trainer = require('../models/trainerModel');
const { calculateMemberStatus } = require('../utils/membershipUtils');
const mongoose = require('mongoose');

exports.getCustomReport = async (req, res) => {
  const { startDate, endDate } = req.query;
  try {
    const gymId = new mongoose.Types.ObjectId(req.gym.id);
    const start = new Date(startDate);
    const end = new Date(endDate);
    end.setHours(23, 59, 59, 999);

    // Counts & Stats
    const newJoiners = await Member.find({
      gymId: req.gym.id,
      joinDate: { $gte: start, $lte: end }
    });

    const revenueData = await Member.aggregate([
      { $match: { gymId, paymentDate: { $gte: start, $lte: end } } },
      {
        $group: {
          _id: null,
          total: { $sum: { $add: ["$cashAmount", "$upiAmount"] } },
          upi: { $sum: "$upiAmount" },
          cash: { $sum: "$cashAmount" },
          unpaid: { $sum: "$remainingAmount" }
        }
      }
    ]);

    const expenseData = await Expense.aggregate([
      { $match: { gymId, date: { $gte: start, $lte: end } } },
      { $group: { _id: null, total: { $sum: "$amount" } } }
    ]);

    // Active/Overdue (Current state snapshot)
    const allMembers = await Member.find({ gymId: req.gym.id });
    const totalMembers = allMembers.length;
    const totalTrainers = await Trainer.countDocuments({ gymId: req.gym.id });
    const activeMembersList = [];
    let activeCount = 0;
    let overdueCount = 0;

    allMembers.forEach(m => {
      const status = calculateMemberStatus(m.paymentDate, m.membershipDuration, m.membershipEndDate);
      if (status === 'ACTIVE' || status === 'EXPIRING SOON') {
        activeCount++;
        activeMembersList.push(m);
      }
      if (status === 'OVERDUE') overdueCount++;
    });

    const inactiveCount = totalMembers - activeCount;

    res.json({
      summary: {
        totalMembers,
        totalTrainers,
        activeMembers: activeCount,
        inactiveMembers: inactiveCount,
        overdueMembers: overdueCount,
        revenue: revenueData.length > 0 ? revenueData[0].total : 0,
        revenueDetails: {
          upi: revenueData.length > 0 ? revenueData[0].upi : 0,
          cash: revenueData.length > 0 ? revenueData[0].cash : 0,
          totalPaid: revenueData.length > 0 ? revenueData[0].total : 0,
          unpaid: revenueData.length > 0 ? revenueData[0].unpaid : 0
        },
        expenses: expenseData.length > 0 ? expenseData[0].total : 0,
        newJoiners: newJoiners.length,
        unpaidAmount: revenueData.length > 0 ? revenueData[0].unpaid : 0
      },
      lists: {
        activeMembers: activeMembersList,
        newJoiners: newJoiners
      }
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
