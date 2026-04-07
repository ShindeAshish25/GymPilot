// const Gym = require('../models/gymModel');
// const OTP = require('../models/otpModel');

// exports.getProfile = async (req, res) => {
//   try {
//     const gym = await Gym.findById(req.gym.id).select('-passwordHash');
//     if (!gym) return res.status(404).json({ msg: 'Profile not found' });
//     res.json(gym);
//   } catch (err) {
//     console.error(err.message);
//     res.status(500).send('Server error');
//   }
// };

// exports.updateProfile = async (req, res) => {
//   const { fullName, email, mobileNumber } = req.body;
//   try {
//     const gym = await Gym.findById(req.gym.id);
//     if (!gym) return res.status(404).json({ msg: 'Profile not found' });

//     // If email is changing, verify OTP
//     if (email && email !== gym.email) {
//       const otpData = await OTP.findOne({ email, verified: true });
//       if (!otpData) {
//         return res.status(400).json({ msg: 'Please verify your new email via OTP first' });
//       }
//       gym.email = email;
//       // Clean up verified OTP
//       await OTP.deleteOne({ email });
//     }

//     if (fullName) gym.fullName = fullName;
//     if (mobileNumber) gym.mobileNumber = mobileNumber;

//     await gym.save();
//     res.json(gym);
//   } catch (err) {
//     console.error(err.message);
//     res.status(500).send('Server error');
//   }
// };

// // Update Gym Name and Logo
// exports.updateGymInfo = async (req, res) => {
//   try {
//     const { gymName } = req.body;
//     const gym = await Gym.findById(req.gym.id);
//     if (!gym) return res.status(404).json({ msg: 'Gym not found' });

//     if (gymName) gym.gymName = gymName;
//     if (req.file) gym.logoUrl = `/uploads/logos/${req.file.filename}`;

//     await gym.save();
//     res.json(gym);
//   } catch (err) {
//     console.error(err.message);
//     res.status(500).send('Server error');
//   }
// };

// // Update Membership
// exports.updateMembership = async (req, res) => {
//   try {
//     const { months } = req.body;
//     if (!months || months < 1 || months > 12) {
//       return res.status(400).json({ msg: 'Please select valid months (1-12)' });
//     }

//     const gym = await Gym.findById(req.gym.id);
//     if (!gym) return res.status(404).json({ msg: 'Gym not found' });

//     const currentEnd = gym.planEndDate ? new Date(gym.planEndDate) : new Date();
//     const startFrom = currentEnd > new Date() ? currentEnd : new Date();

//     const newEnd = new Date(startFrom);
//     newEnd.setMonth(newEnd.getMonth() + parseInt(months));

//     gym.planEndDate = newEnd;
//     gym.subscriptionMonths = (gym.subscriptionMonths || 0) + parseInt(months);

//     await gym.save();
//     res.json({ 
//       success: true, 
//       message: 'Membership extended successfully',
//       planEndDate: gym.planEndDate 
//     });
//   } catch (err) {
//     console.error(err.message);
//     res.status(500).send('Server error');
//   }
// };

const Gym = require('../models/gymModel');
const OTP = require('../models/otpModel');

exports.getProfile = async (req, res) => {
  try {
    const gym = await Gym.findById(req.gym.id).select('-passwordHash');
    if (!gym) return res.status(404).json({ msg: 'Profile not found' });
    res.json(gym);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

exports.updateProfile = async (req, res) => {
  const { fullName, email, mobileNumber } = req.body;
  try {
    const gym = await Gym.findById(req.gym.id);
    if (!gym) return res.status(404).json({ msg: 'Profile not found' });

    if (email && email !== gym.email) {
      const otpData = await OTP.findOne({ email, verified: true });
      if (!otpData) {
        return res.status(400).json({ msg: 'Please verify your new email via OTP first' });
      }
      gym.email = email;
      await OTP.deleteOne({ email });
    }

    if (fullName) gym.fullName = fullName;
    if (mobileNumber) gym.mobileNumber = mobileNumber;

    await gym.save();
    res.json(gym);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

exports.updateGymInfo = async (req, res) => {
  try {
    const { gymName } = req.body;
    const gym = await Gym.findById(req.gym.id);
    if (!gym) return res.status(404).json({ msg: 'Gym not found' });

    if (gymName) gym.gymName = gymName;
    if (req.file) gym.logoUrl = `/uploads/logos/${req.file.filename}`;

    await gym.save();
    res.json(gym);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

exports.updateMembership = async (req, res) => {
  try {
    const { months } = req.body;
    if (!months || months < 1 || months > 12) {
      return res.status(400).json({ msg: 'Please select valid months (1-12)' });
    }

    const gym = await Gym.findById(req.gym.id);
    if (!gym) return res.status(404).json({ msg: 'Gym not found' });

    const currentEnd = gym.planEndDate ? new Date(gym.planEndDate) : new Date();
    const startFrom = currentEnd > new Date() ? currentEnd : new Date();

    const newEnd = new Date(startFrom);
    newEnd.setMonth(newEnd.getMonth() + parseInt(months));

    gym.planEndDate = newEnd;
    gym.subscriptionMonths = (gym.subscriptionMonths || 0) + parseInt(months);

    await gym.save();
    res.json({
      success: true,
      message: 'Membership extended successfully',
      planEndDate: gym.planEndDate,
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};