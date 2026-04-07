const Member = require('../models/memberModel');
const Expense = require('../models/expenseModel');
const Attendance = require('../models/attendanceModel');
const { calculateMemberStatus } = require('../utils/membershipUtils');
const mongoose = require('mongoose');

exports.getDashboardStats = async (req, res) => {
  try {
    const gymId = new mongoose.Types.ObjectId(req.gym.id);
    const now = new Date();
    
    // Current Month
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
    
    // Previous Month
    const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59);

    // 1. New Joiners
    const newJoiners = await Member.countDocuments({
      gymId: req.gym.id,
      joinDate: { $gte: startOfMonth, $lte: endOfMonth },
    });
    const prevJoiners = await Member.countDocuments({
      gymId: req.gym.id,
      joinDate: { $gte: startOfLastMonth, $lte: endOfLastMonth },
    });

    // 2. Active & Overdue (Current)
    const allMembers = await Member.find({ gymId: req.gym.id });
    let activeMembersCount = 0;
    let overdueMembersCount = 0;
    allMembers.forEach(member => {
      const status = calculateMemberStatus(member.paymentDate, member.membershipDuration, member.membershipEndDate);
      if (status === 'ACTIVE' || status === 'EXPIRING SOON') activeMembersCount++;
      if (status === 'OVERDUE') overdueMembersCount++;
    });

    // 3. Revenue
    const revenueData = await Member.aggregate([
      { $match: { gymId, paymentDate: { $gte: startOfMonth, $lte: endOfMonth } } },
      { $group: { _id: null, total: { $sum: { $add: ["$cashAmount", "$upiAmount"] } } } }
    ]);
    const revenue = revenueData.length > 0 ? revenueData[0].total : 0;

    const prevRevenueData = await Member.aggregate([
      { $match: { gymId, paymentDate: { $gte: startOfLastMonth, $lte: endOfLastMonth } } },
      { $group: { _id: null, total: { $sum: { $add: ["$cashAmount", "$upiAmount"] } } } }
    ]);
    const prevRevenue = prevRevenueData.length > 0 ? prevRevenueData[0].total : 0;

    // 4. Expenses
    const expenseData = await Expense.aggregate([
      { $match: { gymId, date: { $gte: startOfMonth, $lte: endOfMonth } } },
      { $group: { _id: null, total: { $sum: "$amount" } } }
    ]);
    const expenses = expenseData.length > 0 ? expenseData[0].total : 0;

    const prevExpenseData = await Expense.aggregate([
      { $match: { gymId, date: { $gte: startOfLastMonth, $lte: endOfLastMonth } } },
      { $group: { _id: null, total: { $sum: "$amount" } } }
    ]);
    const prevExpenses = prevExpenseData.length > 0 ? prevExpenseData[0].total : 0;

    // helper function for trends
    const calcTrend = (curr, prev) => {
      if (prev === 0) return curr > 0 ? 100 : 0;
      return Math.round(((curr - prev) / prev) * 100);
    };

    res.json({
      activeMembers: activeMembersCount,
      overdueMembers: overdueMembersCount,
      newJoiners,
      revenue,
      expenses,
      trends: {
        revenue: calcTrend(revenue, prevRevenue),
        joiners: calcTrend(newJoiners, prevJoiners),
        expenses: calcTrend(expenses, prevExpenses),
        active: calcTrend(activeMembersCount, allMembers.length - newJoiners),
        overdue: calcTrend(overdueMembersCount, 0) // Placeholder or implement previous month overdue if needed
      }
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getChartData = async (req, res) => {
  const { type, filter } = req.query; // type: 'joiners' | 'revenue' | 'expenses' | 'summary', filter: 'week' | 'month' | 'year'
  try {
    const gymId = new mongoose.Types.ObjectId(req.gym.id);
    let startDate;
    const now = new Date();

    if (filter === 'week') {
      startDate = new Date(now.setDate(now.getDate() - 7));
    } else if (filter === 'month') {
      startDate = new Date(now.setMonth(now.getMonth() - 1));
    } else {
      startDate = new Date(now.setFullYear(now.getFullYear() - 1));
    }

    let data = [];

    if (type === 'joiners') {
      data = await Member.aggregate([
        { $match: { gymId, joinDate: { $gte: startDate } } },
        {
          $group: {
            _id: { $dateToString: { format: filter === 'year' ? "%Y-%m" : "%Y-%m-%d", date: "$joinDate" } },
            count: { $sum: 1 }
          }
        },
        { $sort: { _id: 1 } }
      ]);
    } else if (type === 'revenue') {
      data = await Member.aggregate([
        { $match: { gymId, paymentDate: { $gte: startDate } } },
        {
          $group: {
            _id: { $dateToString: { format: filter === 'year' ? "%Y-%m" : "%Y-%m-%d", date: "$paymentDate" } },
            amount: { 
              $sum: { 
                $add: [
                  { $ifNull: ["$cashAmount", 0] }, 
                  { $ifNull: ["$upiAmount", 0] }
                ] 
              } 
            }
          }
        },
        { $sort: { _id: 1 } },
        {
          $project: {
            _id: 1,
            amount: 1,
            label: {
              $cond: {
                if: { $eq: [filter, 'month'] },
                then: { $dateToString: { format: "%d %b", date: { $dateFromString: { dateString: "$_id" } } } },
                else: "$_id"
              }
            }
          }
        }
      ]);
    } else if (type === 'expenses') {
      data = await Expense.aggregate([
        { $match: { gymId, date: { $gte: startDate } } },
        {
          $group: {
            _id: "$category",
            amount: { $sum: "$amount" }
          }
        },
        { $sort: { amount: -1 } },
        { $limit: 3 }
      ]);
    } else if (type === 'attendance') {
      // Last 30 days attendance
      startDate = new Date();
      startDate.setDate(now.getDate() - 30);
      data = await Attendance.aggregate([
        { $match: { gymId, checkInDate: { $gte: startDate } } },
        {
          $group: {
            _id: { $dateToString: { format: "%Y-%m-%d", date: "$checkInDate" } },
            count: { $sum: 1 }
          }
        },
        { $sort: { _id: 1 } }
      ]);
    } else if (type === 'distribution') {
      const all = await Member.find({ gymId: req.gym.id });
      let active = 0;
      let overdue = 0;
      let other = 0;
      
      all.forEach(m => {
        const s = calculateMemberStatus(m.paymentDate, m.membershipDuration, m.membershipEndDate);
        if (s === 'ACTIVE' || s === 'EXPIRING SOON') active++;
        else if (s === 'OVERDUE') overdue++;
        else other++;
      });
      
      data = [
        { label: 'Active', count: active },
        { label: 'Overdue', count: overdue },
        { label: 'Inactive', count: other }
      ];
    } else if (type === 'summary') {
      const revenueTotal = await Member.aggregate([
        { $match: { gymId, paymentDate: { $gte: startDate } } },
        { $group: { _id: null, total: { $sum: { $add: ["$cashAmount", "$upiAmount"] } } } }
      ]);
      const expenseTotal = await Expense.aggregate([
        { $match: { gymId, date: { $gte: startDate } } },
        { $group: { _id: null, total: { $sum: "$amount" } } }
      ]);
      data = [
        { name: 'Revenue', value: revenueTotal.length > 0 ? revenueTotal[0].total : 0 },
        { name: 'Expenses', value: expenseTotal.length > 0 ? expenseTotal[0].total : 0 }
      ];
    }

    res.json(data);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
