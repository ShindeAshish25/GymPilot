const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const Gym = require('./models/gymModel');
const Member = require('./models/memberModel');
const Trainer = require('./models/trainerModel');
const Payment = require('./models/paymentModel');
// Optional: const Attendance = require('./models/attendanceModel');
// Optional: const SubscriptionPlan = require('./models/subscriptionPlanModel');

const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/gymsaas';
    await mongoose.connect(mongoUri);
    console.log('MongoDB Connected for Seeding...');
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
};

const importData = async () => {
  try {
    await connectDB();

    // Clear existing data
    await Gym.deleteMany();
    await Member.deleteMany();
    await Trainer.deleteMany();
    await Payment.deleteMany();

    console.log('Data Cleared!');

    // Create Dummy Gym
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash('password123', salt);

    const gym = await Gym.create({
      gymName: 'Power Fitness Gym',
      ownerName: 'Rahul Sharma',
      email: 'owner@gym.com',
      phone: '9876543210',
      passwordHash: passwordHash,
      address: 'Pune, India',
      subscriptionPlan: 'PRO',
    });

    console.log('Gym Created:', gym.gymName);

    // Create Trainers
    const trainer1 = await Trainer.create({
      gymId: gym._id,
      name: 'Raj Trainer',
      phone: '9999999991',
      specialization: 'Strength',
    });

    const trainer2 = await Trainer.create({
      gymId: gym._id,
      name: 'Priya Coach',
      phone: '9999999992',
      specialization: 'Cardio',
    });

    console.log('Trainers Created!');

    // Create Members
    const member1 = await Member.create({
      gymId: gym._id,
      memberId: 'MEM-001',
      name: 'Amit Patil',
      phone: '8888888881',
      email: 'amit@example.com',
      gender: 'Male',
      membershipDuration: 6,
      trainingType: 'Strength',
      trainerId: trainer1._id,
      totalFee: 10000,
      amountPaid: 8000,
      paymentStatus: 'Partial',
      membershipEndDate: new Date(new Date().setMonth(new Date().getMonth() + 6)),
    });

    const member2 = await Member.create({
      gymId: gym._id,
      memberId: 'MEM-002',
      name: 'Sneha Joshi',
      phone: '8888888882',
      email: 'sneha@example.com',
      gender: 'Female',
      membershipDuration: 3,
      trainingType: 'Weight Loss',
      trainerId: trainer2._id,
      totalFee: 5000,
      amountPaid: 5000,
      paymentStatus: 'Paid',
      membershipEndDate: new Date(new Date().setMonth(new Date().getMonth() + 3)),
    });

    const member3 = await Member.create({
      gymId: gym._id,
      memberId: 'MEM-003',
      name: 'Vikram Singh',
      phone: '8888888883',
      gender: 'Male',
      membershipDuration: 1,
      trainingType: 'General',
      totalFee: 2000,
      amountPaid: 0,
      paymentStatus: 'Unpaid',
      membershipEndDate: new Date(new Date().setMonth(new Date().getMonth() + 1)),
    });

    console.log('Members Created!');

    // Create Payments
    await Payment.create({
      gymId: gym._id,
      memberId: member1._id,
      amount: 8000,
      paymentMethod: 'UPI',
    });

    await Payment.create({
      gymId: gym._id,
      memberId: member2._id,
      amount: 5000,
      paymentMethod: 'Card',
    });

    console.log('Payments Created!');
    console.log('Data Import SUCCESSFUL! Default Login is owner@gym.com / password123');

    process.exit();
  } catch (error) {
    console.error('Error importing data:', error.message);
    process.exit(1);
  }
};

importData();
