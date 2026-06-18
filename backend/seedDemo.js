const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import Models
const Gym = require('./models/gymModel');
const Member = require('./models/memberModel');
const Trainer = require('./models/trainerModel');
const Payment = require('./models/paymentModel');
const Attendance = require('./models/attendanceModel');
const Expense = require('./models/expenseModel');
const ExpenseCategory = require('./models/expenseCategoryModel');

const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/gympilot';
    await mongoose.connect(mongoUri);
    console.log('MongoDB Connected for Seeding...');
  } catch (err) {
    console.error('MongoDB Connection Error:', err.message);
    process.exit(1);
  }
};

const seedDemoData = async () => {
  try {
    await connectDB();

    // 1. Clear existing data for a clean slate (Optional: Only for demo user)
    // For safety, we only clear if explicitly told, but here we'll clear everything as requested for "one demo user with ALL data"
    await Gym.deleteMany({});
    await Member.deleteMany({});
    await Trainer.deleteMany({});
    await Payment.deleteMany({});
    await Attendance.deleteMany({});
    await Expense.deleteMany({});
    await ExpenseCategory.deleteMany({});

    console.log('Database cleared.');

    // 2. Create Demo Gym Owner
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash('demo123', salt);

    const demoGym = await Gym.create({
      gymId: 'GYM-001',
      gymName: 'Titan Fitness Hub',
      fullName: 'Vikram Malhotra',
      email: 'demo@gympilot.com',
      mobileNumber: '9988776655',
      address: 'Suite 405, Active Plaza, Mumbai, Maharashtra',
      passwordHash: passwordHash,
      subscriptionMonths: 12,
      planEndDate: new Date(new Date().setFullYear(new Date().getFullYear() + 1)),
      logoUrl: '/uploads/logos/demo-logo.png'
    });

    console.log('Demo Gym Created: demo@gympilot.com / demo123');

    // 3. Create Trainers
    const trainers = await Trainer.insertMany([
      {
        gymId: demoGym._id,
        name: 'Arjun Khanna',
        phone: '9000000001',
        specialization: 'Bodybuilding & Powerlifting',
        feeChargePerPerson: 5000,
        experience: '8 Years'
      },
      {
        gymId: demoGym._id,
        name: 'Sara Ali',
        phone: '9000000002',
        specialization: 'Yoga & Pilates',
        feeChargePerPerson: 4000,
        experience: '5 Years'
      }
    ]);

    console.log(`${trainers.length} Trainers created.`);

    // 4. Create Members
    const membersData = [
      {
        gymId: demoGym._id,
        memberId: 'MEM-101',
        name: 'Rohan Sharma',
        phone: '8000000001',
        email: 'rohan@example.com',
        gender: 'Male',
        membershipDuration: 6,
        membershipStartDate: new Date(),
        membershipEndDate: new Date(new Date().setMonth(new Date().getMonth() + 6)),
        joinDate: new Date(),
        trainingType: 'Strength',
        trainerId: trainers[0]._id,
        totalFee: 15000,
        amountPaid: 15000,
        remainingAmount: 0,
        paymentStatus: 'Paid',
        paymentDate: new Date(),
        paymentMode: 'UPI',
        upiAmount: 15000,
        cashAmount: 0
      },
      {
        gymId: demoGym._id,
        memberId: 'MEM-102',
        name: 'Anjali Gupta',
        phone: '8000000002',
        email: 'anjali@example.com',
        gender: 'Female',
        membershipDuration: 3,
        membershipStartDate: new Date(),
        membershipEndDate: new Date(new Date().setMonth(new Date().getMonth() + 3)),
        joinDate: new Date(),
        trainingType: 'Yoga',
        trainerId: trainers[1]._id,
        totalFee: 12000,
        amountPaid: 5000,
        remainingAmount: 7000,
        paymentStatus: 'Partial',
        paymentDate: new Date(),
        paymentMode: 'Cash',
        upiAmount: 0,
        cashAmount: 5000
      },
      {
        gymId: demoGym._id,
        memberId: 'MEM-103',
        name: 'Kabir Singh',
        phone: '8000000003',
        email: 'kabir@example.com',
        gender: 'Male',
        membershipDuration: 1,
        membershipStartDate: new Date(new Date().setDate(new Date().getDate() - 25)),
        membershipEndDate: new Date(new Date().setDate(new Date().getDate() + 5)),
        joinDate: new Date(new Date().setDate(new Date().getDate() - 25)),
        trainingType: 'Cardio',
        totalFee: 3000,
        amountPaid: 0,
        remainingAmount: 3000,
        paymentStatus: 'Unpaid',
        paymentDate: null,
        upiAmount: 0,
        cashAmount: 0
      },
      {
        gymId: demoGym._id,
        memberId: 'MEM-104',
        name: 'Suresh Raina',
        phone: '8000000004',
        email: 'suresh@example.com',
        gender: 'Male',
        membershipDuration: 12,
        membershipStartDate: new Date(new Date().setMonth(new Date().getMonth() - 2)),
        membershipEndDate: new Date(new Date().setMonth(new Date().getMonth() + 10)),
        joinDate: new Date(new Date().setMonth(new Date().getMonth() - 2)),
        trainingType: 'Strength',
        totalFee: 25000,
        amountPaid: 25000,
        remainingAmount: 0,
        paymentStatus: 'Paid',
        paymentDate: new Date(new Date().setMonth(new Date().getMonth() - 2)),
        paymentMode: 'UPI',
        upiAmount: 25000,
        cashAmount: 0
      },
      {
        gymId: demoGym._id,
        memberId: 'MEM-105',
        name: 'Priya Verma',
        phone: '8000000005',
        email: 'priya@example.com',
        gender: 'Female',
        membershipDuration: 1,
        membershipStartDate: new Date(new Date().setDate(new Date().getDate() - 10)),
        membershipEndDate: new Date(new Date().setDate(new Date().getDate() + 20)),
        joinDate: new Date(new Date().setDate(new Date().getDate() - 10)),
        trainingType: 'Yoga',
        totalFee: 4000,
        amountPaid: 4000,
        remainingAmount: 0,
        paymentStatus: 'Paid',
        paymentDate: new Date(new Date().setDate(new Date().getDate() - 10)),
        paymentMode: 'Cash',
        upiAmount: 0,
        cashAmount: 4000
      },
      {
        gymId: demoGym._id,
        memberId: 'MEM-106',
        name: 'Virat Kohli',
        phone: '8000000006',
        email: 'virat@example.com',
        gender: 'Male',
        membershipDuration: 6,
        membershipStartDate: new Date(new Date().setMonth(new Date().getMonth() - 1)),
        membershipEndDate: new Date(new Date().setMonth(new Date().getMonth() + 5)),
        joinDate: new Date(new Date().setMonth(new Date().getMonth() - 1)),
        trainingType: 'Strength',
        totalFee: 18000,
        amountPaid: 18000,
        remainingAmount: 0,
        paymentStatus: 'Paid',
        paymentDate: new Date(new Date().setMonth(new Date().getMonth() - 1)),
        paymentMode: 'UPI',
        upiAmount: 18000,
        cashAmount: 0
      },
      {
        gymId: demoGym._id,
        memberId: 'MEM-107',
        name: 'Hardik Pandya',
        phone: '8000000007',
        email: 'hardik@example.com',
        gender: 'Male',
        membershipDuration: 3,
        membershipStartDate: new Date(new Date().setDate(new Date().getDate() - 40)),
        membershipEndDate: new Date(new Date().setDate(new Date().getDate() + 50)),
        joinDate: new Date(new Date().setDate(new Date().getDate() - 40)),
        trainingType: 'Crossfit',
        totalFee: 12000,
        amountPaid: 12000,
        remainingAmount: 0,
        paymentStatus: 'Paid',
        paymentDate: new Date(new Date().setDate(new Date().getDate() - 40)),
        paymentMode: 'UPI',
        upiAmount: 12000,
        cashAmount: 0
      },
      {
        gymId: demoGym._id,
        memberId: 'MEM-108',
        name: 'MS Dhoni',
        phone: '8000000008',
        email: 'msd@example.com',
        gender: 'Male',
        membershipDuration: 12,
        membershipStartDate: new Date(new Date().setMonth(new Date().getMonth() - 5)),
        membershipEndDate: new Date(new Date().setMonth(new Date().getMonth() + 7)),
        joinDate: new Date(new Date().setMonth(new Date().getMonth() - 5)),
        trainingType: 'Strength',
        totalFee: 30000,
        amountPaid: 30000,
        remainingAmount: 0,
        paymentStatus: 'Paid',
        paymentDate: new Date(new Date().setMonth(new Date().getMonth() - 5)),
        paymentMode: 'Cash',
        upiAmount: 0,
        cashAmount: 30000
      },
      {
        gymId: demoGym._id,
        memberId: 'MEM-109',
        name: 'Smriti Mandhana',
        phone: '8000000009',
        email: 'smriti@example.com',
        gender: 'Female',
        membershipDuration: 6,
        membershipStartDate: new Date(new Date().setMonth(new Date().getMonth() - 3)),
        membershipEndDate: new Date(new Date().setMonth(new Date().getMonth() + 3)),
        joinDate: new Date(new Date().setMonth(new Date().getMonth() - 3)),
        trainingType: 'Yoga',
        totalFee: 15000,
        amountPaid: 10000,
        remainingAmount: 5000,
        paymentStatus: 'Partial',
        paymentDate: new Date(new Date().setMonth(new Date().getMonth() - 3)),
        paymentMode: 'UPI',
        upiAmount: 10000,
        cashAmount: 0
      },
      {
        gymId: demoGym._id,
        memberId: 'MEM-110',
        name: 'KL Rahul',
        phone: '8000000010',
        email: 'klr@example.com',
        gender: 'Male',
        membershipDuration: 1,
        membershipStartDate: new Date(new Date().setDate(new Date().getDate() - 3)),
        membershipEndDate: new Date(new Date().setDate(new Date().getDate() + 27)),
        joinDate: new Date(new Date().setDate(new Date().getDate() - 3)),
        trainingType: 'Cardio',
        totalFee: 3500,
        amountPaid: 3500,
        remainingAmount: 0,
        paymentStatus: 'Paid',
        paymentDate: new Date(new Date().setDate(new Date().getDate() - 3)),
        paymentMode: 'UPI',
        upiAmount: 3500,
        cashAmount: 0
      }
    ];

    const members = await Member.insertMany(membersData);
    console.log(`${members.length} Members created.`);

    // 5. Create Payments (Staggered across 6 months)
    const paymentsData = [];
    const months = [0, 1, 2, 3, 4, 5];
    months.forEach(m => {
        const date = new Date();
        date.setMonth(date.getMonth() - m);
        paymentsData.push(
            { gymId: demoGym._id, memberId: members[0]._id, amount: 2500, paymentMethod: 'UPI', recordedBy: 'Admin', createdAt: date },
            { gymId: demoGym._id, memberId: members[3]._id, amount: 2000, paymentMethod: 'UPI', recordedBy: 'Admin', createdAt: date },
            { gymId: demoGym._id, memberId: members[5]._id, amount: 3000, paymentMethod: 'Cash', recordedBy: 'Admin', createdAt: date }
        );
    });

    await Payment.insertMany(paymentsData);
    console.log('Payment records created.');

    // 6. Create Attendance (Last 30 days for all members)
    const attendanceRecords = [];
    for (let i = 0; i < 30; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      
      members.forEach(m => {
        if (Math.random() > 0.3) {
            attendanceRecords.push({
                gymId: demoGym._id,
                memberId: m._id,
                checkInDate: new Date(date),
                checkInTime: '07:' + (Math.floor(Math.random() * 30) + 10) + ' AM'
            });
        }
      });
    }
    await Attendance.insertMany(attendanceRecords);
    console.log('Attendance records created.');

    // 7. Create Expense Categories & Expenses
    const categories = await ExpenseCategory.insertMany([
      { gymId: demoGym._id, name: 'Electricity', isDefault: true },
      { gymId: demoGym._id, name: 'Rent', isDefault: true },
      { gymId: demoGym._id, name: 'Maintenance', isDefault: true },
      { gymId: demoGym._id, name: 'Salaries', isDefault: true },
      { gymId: demoGym._id, name: 'Marketing', isDefault: true }
    ]);

    const expensesData = [];
    months.forEach(m => {
        const date = new Date();
        date.setMonth(date.getMonth() - m);
        expensesData.push(
            { gymId: demoGym._id, category: 'Rent', amount: 50000, date: date, notes: 'Monthly rent' },
            { gymId: demoGym._id, category: 'Electricity', amount: 7000 + Math.random() * 2000, date: date, notes: 'Electricity bill' },
            { gymId: demoGym._id, category: 'Salaries', amount: 35000, date: date, notes: 'Staff salaries' }
        );
    });
    await Expense.insertMany(expensesData);

    console.log('Expenses and Categories created.');

    console.log('\n=========================================');
    console.log('DEMO DATA SEEDED SUCCESSFULLY');
    console.log('Gym Email: demo@gympilot.com');
    console.log('Password:  demo123');
    console.log('=========================================\n');

    process.exit(0);
  } catch (error) {
    console.error('Error seeding data:', error);
    process.exit(1);
  }
};

seedDemoData();
