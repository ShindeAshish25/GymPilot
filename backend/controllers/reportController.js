const Member = require('../models/memberModel');
const Expense = require('../models/expenseModel');
const Trainer = require('../models/trainerModel');
const { calculateMemberStatus } = require('../utils/membershipUtils');
const mongoose = require('mongoose');

exports.getCustomReport = async (req, res) => {
  const { startDate, endDate } = req.query;
  try {
    if (!startDate || !endDate) {
      return res.status(400).json({ msg: 'Please provide both startDate and endDate' });
    }

    const start = new Date(startDate);
    const end = new Date(endDate);
    
    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return res.status(400).json({ msg: 'Invalid date format' });
    }
    
    end.setHours(23, 59, 59, 999);

    const gymId = new mongoose.Types.ObjectId(req.gym.id);

    // Counts & Stats
    const newJoiners = await Member.find({
      gymId: gymId,
      joinDate: { $gte: start, $lte: end }
    });

    const revenueData = await Member.aggregate([
      { $match: { gymId, paymentDate: { $gte: start, $lte: end } } },
      {
        $group: {
          _id: null,
          total: { 
            $sum: { 
              $add: [
                { $ifNull: ["$cashAmount", 0] }, 
                { $ifNull: ["$upiAmount", 0] }
              ] 
            } 
          },
          upi: { $sum: { $ifNull: ["$upiAmount", 0] } },
          cash: { $sum: { $ifNull: ["$cashAmount", 0] } },
          unpaid: { $sum: { $ifNull: ["$remainingAmount", 0] } }
        }
      }
    ]);

    const expenseData = await Expense.aggregate([
      { $match: { gymId, date: { $gte: start, $lte: end } } },
      { $group: { _id: null, total: { $sum: { $ifNull: ["$amount", 0] } } } }
    ]);

    // Active/Overdue (Current state snapshot)
    const allMembers = await Member.find({ gymId: gymId });
    const totalMembers = allMembers.length;
    const totalTrainers = await Trainer.countDocuments({ gymId: gymId });
    
    const activeMembersList = [];
    const overdueMembersList = [];
    let activeCount = 0;
    let overdueCount = 0;

    allMembers.forEach(m => {
      const status = calculateMemberStatus(m.paymentDate, m.membershipDuration, m.membershipEndDate);
      if (status === 'ACTIVE' || status === 'EXPIRING SOON') {
        activeCount++;
        activeMembersList.push(m);
      } else if (status === 'OVERDUE') {
        overdueCount++;
        overdueMembersList.push(m);
      }
    });

    // Recent Renewals (Payments within the range)
    const recentRenewalsList = await Member.find({
      gymId: gymId,
      paymentDate: { $gte: start, $lte: end }
    }).sort({ paymentDate: -1 });

    const inactiveCount = totalMembers - activeCount - overdueCount;

    res.json({
      summary: {
        totalMembers,
        totalTrainers,
        activeMembers: activeCount,
        inactiveMembers: inactiveCount,
        overdueMembers: overdueCount,
        revenue: revenueData.length > 0 ? (revenueData[0].total || 0) : 0,
        revenueDetails: {
          upi: revenueData.length > 0 ? (revenueData[0].upi || 0) : 0,
          cash: revenueData.length > 0 ? (revenueData[0].cash || 0) : 0,
          totalPaid: revenueData.length > 0 ? (revenueData[0].total || 0) : 0,
          unpaid: revenueData.length > 0 ? (revenueData[0].unpaid || 0) : 0
        },
        expenses: expenseData.length > 0 ? (expenseData[0].total || 0) : 0,
        newJoiners: newJoiners.length,
        unpaidAmount: revenueData.length > 0 ? (revenueData[0].unpaid || 0) : 0
      },
      lists: {
        activeMembers: activeMembersList,
        newJoiners: newJoiners,
        overdueMembers: overdueMembersList,
        recentRenewals: recentRenewalsList
      }
    });
  } catch (err) {
    console.error('Report Generation Error:', err);
    res.status(500).json({ error: 'Server Error during report generation', details: err.message });
  }
};
