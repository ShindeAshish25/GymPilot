// const bcrypt = require('bcryptjs');
// const jwt = require('jsonwebtoken');
// const Gym = require('../models/gymModel');
// const OTP = require('../models/otpModel');
// const BlacklistedToken = require('../models/tokenModel');
// const generateOtp = require('../utils/generateOtp');
// const { sendOtpEmail } = require('../services/emailService');

// exports.registerGym = async (req, res) => {
//     const { gymName, fullName, email, mobileNumber, password, address, subscriptionMonths, isFreeTrial } = req.body;
  
//     try {
//       let gym = await Gym.findOne({ email });
//       if (gym) {
//         return res.status(400).json({ msg: 'Gym already exists' });
//       }
  
//       // Generate Unique Gym ID (e.g., GYM-101)
//       const count = await Gym.countDocuments();
//       const gymId = `GYM-${100 + count + 1}`;
  
//       // Check if email is verified
//       const otpData = await OTP.findOne({ email, verified: true });
//       if (!otpData) {
//         return res.status(400).json({ msg: 'Please verify your email via OTP first' });
//       }
  
//       const salt = await bcrypt.genSalt(10);
//       const passwordHash = await bcrypt.hash(password, salt);
  
//       // Calculate plan end date
//       const planEndDate = new Date();
//       let months = parseInt(subscriptionMonths) || 1;
      
//       if (isFreeTrial) {
//         planEndDate.setDate(planEndDate.getDate() + 30);
//         months = 1; // Free trial is for 1 month
//       } else {
//         planEndDate.setMonth(planEndDate.getMonth() + months);
//       }
  
//       // Get logo URL if file was uploaded
//       const logoUrl = req.file ? `/uploads/logos/${req.file.filename}` : '';
  
//       gym = new Gym({
//         gymId,
//         gymName,
//         fullName,
//         email,
//         mobileNumber,
//         passwordHash,
//         address,
//         subscriptionMonths: months,
//         isFreeTrial: isFreeTrial || false,
//         planEndDate,
//         logoUrl,
//       });

//     await gym.save();

//     // Clean up verified OTP
//     await OTP.deleteOne({ email });

//     const payload = { gym: { id: gym.id } };
//     jwt.sign(
//       payload,
//       process.env.JWT_SECRET || 'secret123',
//       { expiresIn: '5 days' },
//       (err, token) => {
//         if (err) throw err;
//         res.json({ token, gym: {
//           id: gym.id,
//           gymName: gym.gymName,
//           fullName: gym.fullName,
//           email: gym.email,
//           logoUrl: gym.logoUrl
//         } });
//       }
//     );
//   } catch (err) {
//     console.error(err.message);
//     res.status(500).send('Server error');
//   }
// };

// exports.loginGym = async (req, res) => {
//   const { email, password } = req.body;
//   try {
//     let gym = await Gym.findOne({ email });
//     if (!gym) return res.status(400).json({ msg: 'Invalid Credentials' });

//     const isMatch = await bcrypt.compare(password, gym.passwordHash);
//     if (!isMatch) return res.status(400).json({ msg: 'Invalid Credentials' });

//     const payload = { gym: { id: gym.id } };
//     jwt.sign(
//       payload,
//       process.env.JWT_SECRET || 'secret123',
//       { expiresIn: '5 days' },
//       (err, token) => {
//         if (err) throw err;
//         res.json({ token });
//       }
//     );
//   } catch (err) {
//     console.error(err.message);
//     res.status(500).send('Server error');
//   }
// };

// exports.forgotPassword = async (req, res) => {
//   const { email } = req.body;
//   try {
//     const gym = await Gym.findOne({ email });
//     if (!gym) return res.status(404).json({ msg: 'Gym not found' });

//     const otp = generateOtp();
    
//     await OTP.findOneAndUpdate(
//       { email },
//       { otp, createdAt: new Date() },
//       { upsert: true, new: true }
//     );

//     await sendOtpEmail(email, otp);
    
//     res.json({ 
//       success: true, 
//       message: 'OTP sent successfully' 
//     });
//   } catch (err) {
//     console.error(err.message);
//     res.status(500).send('Server error');
//   }
// };

// exports.sendOTP = async (req, res) => {
//   const { email } = req.body;
//   try {
//     const otp = generateOtp();
    
//     await OTP.findOneAndUpdate(
//       { email },
//       { otp, createdAt: new Date() },
//       { upsert: true, new: true }
//     );

//     await sendOtpEmail(email, otp);
    
//     res.json({ 
//       success: true, 
//       message: 'OTP sent successfully' 
//     });
//   } catch (err) {
//     console.error(err.message);
//     res.status(500).json({ 
//       success: false, 
//       message: 'Server error' 
//     });
//   }
// };

// exports.verifyOTP = async (req, res) => {
//   const { email, otp } = req.body;
//   try {
//     const otpData = await OTP.findOne({ email, otp });
//     if (!otpData) {
//       return res.status(400).json({ 
//         success: false, 
//         message: 'Invalid or expired OTP' 
//       });
//     }

//     // Mark as verified
//     otpData.verified = true;
//     await otpData.save();

//     res.json({ 
//       success: true, 
//       message: 'OTP verified' 
//     });
//   } catch (err) {
//     console.error(err.message);
//     res.status(500).json({ 
//       success: false, 
//       message: 'Server error' 
//     });
//   }
// };

// exports.resetPassword = async (req, res) => {
//   const { email, otp, newPassword } = req.body;
//   try {
//     const otpData = await OTP.findOne({ email, otp });
//     if (!otpData) return res.status(400).json({ msg: 'Invalid or expired OTP' });

//     const gym = await Gym.findOne({ email });
//     const salt = await bcrypt.genSalt(10);
//     gym.passwordHash = await bcrypt.hash(newPassword, salt);
//     await gym.save();

//     await OTP.deleteOne({ email });
//     res.json({ 
//       success: true, 
//       message: 'Password reset successful' 
//     });
//   } catch (err) {
//     console.error(err.message);
//     res.status(500).send('Server error');
//   }
// };

// exports.logout = async (req, res) => {
//   try {
//     const token = req.header('x-auth-token');
//     if (!token) return res.status(400).json({ msg: 'No token provided' });

//     // Blacklist the token
//     const blacklistedToken = new BlacklistedToken({ token });
//     await blacklistedToken.save();

//     res.json({ success: true, message: 'Logged out successfully' });
//   } catch (err) {
//     console.error(err.message);
//     res.status(500).send('Server error');
//   }
// };


const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Gym = require('../models/gymModel');
const OTP = require('../models/otpModel');
const BlacklistedToken = require('../models/tokenModel');
const generateOtp = require('../utils/generateOtp');
const { sendOtpEmail } = require('../services/emailService');

exports.registerGym = async (req, res) => {
  const { gymName, fullName, email, mobileNumber, password, address, subscriptionMonths, isFreeTrial } = req.body;

  try {
    let gym = await Gym.findOne({ email });
    if (gym) {
      return res.status(400).json({ msg: 'Gym already exists' });
    }

    const count = await Gym.countDocuments();
    const gymId = `GYM-${100 + count + 1}`;

    const otpData = await OTP.findOne({ email, verified: true });
    if (!otpData) {
      return res.status(400).json({ msg: 'Please verify your email via OTP first' });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const planEndDate = new Date();
    let months = parseInt(subscriptionMonths) || 1;

    if (isFreeTrial) {
      planEndDate.setDate(planEndDate.getDate() + 30);
      months = 1;
    } else {
      planEndDate.setMonth(planEndDate.getMonth() + months);
    }

    const logoUrl = req.file ? `/uploads/logos/${req.file.filename}` : '';

    gym = new Gym({
      gymId,
      gymName,
      fullName,
      email,
      mobileNumber,
      passwordHash,
      address,
      subscriptionMonths: months,
      isFreeTrial: isFreeTrial || false,
      planEndDate,
      logoUrl,
    });

    await gym.save();
    await OTP.deleteOne({ email });

    if (!process.env.JWT_SECRET) throw new Error('JWT_SECRET not set');

    const payload = { gym: { id: gym.id } };
    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '5 days' },
      (err, token) => {
        if (err) throw err;
        res.json({
          token,
          gym: {
            id: gym.id,
            gymName: gym.gymName,
            fullName: gym.fullName,
            email: gym.email,
            logoUrl: gym.logoUrl,
          },
        });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

exports.loginGym = async (req, res) => {
  const { email, password } = req.body;
  try {
    let gym = await Gym.findOne({ email });
    if (!gym) return res.status(400).json({ msg: 'Invalid Credentials' });

    const isMatch = await bcrypt.compare(password, gym.passwordHash);
    if (!isMatch) return res.status(400).json({ msg: 'Invalid Credentials' });

    if (!process.env.JWT_SECRET) throw new Error('JWT_SECRET not set');

    const payload = { gym: { id: gym.id } };
    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '5 days' },
      (err, token) => {
        if (err) throw err;
        res.json({ token });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

exports.forgotPassword = async (req, res) => {
  const { email } = req.body;
  try {
    const gym = await Gym.findOne({ email });
    if (!gym) return res.status(404).json({ msg: 'Gym not found' });

    const otp = generateOtp();

    await OTP.findOneAndUpdate(
      { email },
      { otp, createdAt: new Date(), verified: false },
      { upsert: true, returnDocument: 'after' }
    );

    const emailSent = await sendOtpEmail(email, otp);
    if (!emailSent) {
      return res.status(500).json({ success: false, message: 'Failed to send OTP email' });
    }

    res.json({ success: true, message: 'OTP sent successfully' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

exports.sendOTP = async (req, res) => {
  const { email } = req.body;
  try {
    const otp = generateOtp();

    await OTP.findOneAndUpdate(
      { email },
      { otp, createdAt: new Date(), verified: false },
      { upsert: true, returnDocument: 'after' }
    );

    const emailSent = await sendOtpEmail(email, otp);
    if (!emailSent) {
      return res.status(500).json({ success: false, message: 'Failed to send OTP email' });
    }

    res.json({ success: true, message: 'OTP sent successfully' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.verifyOTP = async (req, res) => {
  const { email, otp } = req.body;
  try {
    const otpData = await OTP.findOne({ email, otp });
    if (!otpData) {
      return res.status(400).json({ success: false, message: 'Invalid or expired OTP' });
    }

    otpData.verified = true;
    await otpData.save();

    res.json({ success: true, message: 'OTP verified' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.resetPassword = async (req, res) => {
  const { email, otp, newPassword } = req.body;
  try {
    const otpData = await OTP.findOne({ email, otp, verified: true });
    if (!otpData) return res.status(400).json({ msg: 'Invalid or expired OTP' });

    const gym = await Gym.findOne({ email });
    if (!gym) return res.status(404).json({ msg: 'Gym not found' });

    const salt = await bcrypt.genSalt(10);
    gym.passwordHash = await bcrypt.hash(newPassword, salt);
    await gym.save();

    await OTP.deleteOne({ email });

    res.json({ success: true, message: 'Password reset successful' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

exports.logout = async (req, res) => {
  try {
    const token = req.header('x-auth-token');
    if (!token) return res.status(400).json({ msg: 'No token provided' });

    const blacklistedToken = new BlacklistedToken({ token });
    await blacklistedToken.save();

    res.json({ success: true, message: 'Logged out successfully' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};