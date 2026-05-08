const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Gym = require('../models/gymModel');
const OTP = require('../models/otpModel');
const BlacklistedToken = require('../models/tokenModel');
const generateOtp = require('../utils/generateOtp');
const { sendOtpEmail } = require('../services/emailService');

exports.registerGym = async (req, res) => {
  const { gymName, fullName, email, mobileNumber, password, address, subscriptionMonths, isFreeTrial } = req.body;
  
  console.log(`\n[REGISTRATION ATTEMPT] Gym: ${gymName}, Email: ${email}`);

  try {
    let gym = await Gym.findOne({ email });
    if (gym) {
      console.log(`[REGISTRATION FAILED] Email already exists: ${email}`);
      return res.status(400).json({ msg: 'Gym already exists' });
    }

    const count = await Gym.countDocuments();
    const gymId = `GYM-${100 + count + 1}`;

    const otpData = await OTP.findOne({ email, verified: true });
    if (!otpData) {
      console.log(`[REGISTRATION FAILED] OTP not verified for ${email}`);
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
        if (err) {
          console.error(`[JWT ERROR] ${err.message}`);
          throw err;
        }
        console.log(`[REGISTRATION SUCCESS] Gym Created: ${gym.gymName} (ID: ${gym.gymId})`);
        res.json({
          token,
          gym: {
            id: gym.id,
            gymId: gym.gymId,
            gymName: gym.gymName,
            fullName: gym.fullName,
            email: gym.email,
            mobileNumber: gym.mobileNumber,
            logoUrl: gym.logoUrl,
            planEndDate: gym.planEndDate,
            isFreeTrial: gym.isFreeTrial,
          },
        });
      }
    );
  } catch (err) {
    console.error(`[REGISTRATION ERROR] ${err.message}`);
    res.status(500).send('Server error');
  }
};

exports.loginGym = async (req, res) => {
  const { email, password } = req.body;
  console.log(`\n[LOGIN ATTEMPT] Email: ${email}`);

  try {
    let gym = await Gym.findOne({ email });
    if (!gym) {
      console.log(`[LOGIN FAILED] Gym not found: ${email}`);
      return res.status(400).json({ msg: 'Invalid Credentials' });
    }

    const isMatch = await bcrypt.compare(password, gym.passwordHash);
    if (!isMatch) {
      console.log(`[LOGIN FAILED] Password mismatch: ${email}`);
      return res.status(400).json({ msg: 'Invalid Credentials' });
    }

    if (!process.env.JWT_SECRET) throw new Error('JWT_SECRET not set');

    const payload = { gym: { id: gym.id } };
    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '5 days' },
      (err, token) => {
        if (err) {
          console.error(`[JWT ERROR] ${err.message}`);
          throw err;
        }
        console.log(`[LOGIN SUCCESS] Gym Authenticated: ${gym.gymName}`);
        const responseData = {
          token,
          gym: {
            id: gym.id,
            gymId: gym.gymId,
            gymName: gym.gymName,
            fullName: gym.fullName,
            email: gym.email,
            mobileNumber: gym.mobileNumber,
            logoUrl: gym.logoUrl,
            planEndDate: gym.planEndDate,
            isFreeTrial: gym.isFreeTrial,
          },
        };
        res.json(responseData);
      }
    );
  } catch (err) {
    console.error(`[LOGIN ERROR] ${err.message}`);
    res.status(500).send('Server error');
  }
};

exports.forgotPassword = async (req, res) => {
  const { email } = req.body;
  console.log(`\n[FORGOT PASSWORD REQUEST] Email: ${email}`);
  try {
    const gym = await Gym.findOne({ email });
    if (!gym) {
      console.log(`[FORGOT PASSWORD FAILED] Gym not found: ${email}`);
      return res.status(404).json({ msg: 'Gym not found' });
    }

    const otp = generateOtp();

    await OTP.findOneAndUpdate(
      { email },
      { otp, createdAt: new Date(), verified: false },
      { upsert: true, returnDocument: 'after' }
    );

    await sendOtpEmail(email, otp);
    console.log(`[FORGOT PASSWORD] OTP logic completed for ${email}`);
    res.json({ success: true, message: 'OTP sent successfully (Check server logs if email not received)' });
  } catch (err) {
    console.error(`[FORGOT PASSWORD ERROR] ${err.message}`);
    res.status(500).send('Server error');
  }
};

exports.sendOTP = async (req, res) => {
  const { email } = req.body;
  console.log(`\n[OTP REQUEST] Email: ${email}`);
  try {
    const otp = generateOtp();

    await OTP.findOneAndUpdate(
      { email },
      { otp, createdAt: new Date(), verified: false },
      { upsert: true, returnDocument: 'after' }
    );

    await sendOtpEmail(email, otp);
    console.log(`[OTP SENT] OTP logic completed for ${email}`);
    res.json({ success: true, message: 'OTP sent successfully (Check server logs if email not received)' });
  } catch (err) {
    console.error(`[OTP ERROR] ${err.message}`);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.verifyOTP = async (req, res) => {
  const { email, otp } = req.body;
  console.log(`\n[OTP VERIFICATION ATTEMPT] Email: ${email}, OTP: ${otp}`);
  try {
    const otpData = await OTP.findOne({ email, otp });
    if (!otpData) {
      console.log(`[OTP VERIFICATION FAILED] Invalid or expired OTP for ${email}`);
      return res.status(400).json({ success: false, message: 'Invalid or expired OTP' });
    }

    otpData.verified = true;
    await otpData.save();

    console.log(`[OTP VERIFICATION SUCCESS] Email verified: ${email}`);
    res.json({ success: true, message: 'OTP verified' });
  } catch (err) {
    console.error(`[OTP VERIFICATION ERROR] ${err.message}`);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.resetPassword = async (req, res) => {
  const { email, otp, newPassword } = req.body;
  console.log(`\n[PASSWORD RESET ATTEMPT] Email: ${email}`);
  try {
    const otpData = await OTP.findOne({ email, otp, verified: true });
    if (!otpData) {
      console.log(`[PASSWORD RESET FAILED] OTP not verified or invalid for ${email}`);
      return res.status(400).json({ msg: 'Invalid or expired OTP' });
    }

    const gym = await Gym.findOne({ email });
    if (!gym) {
      console.log(`[PASSWORD RESET FAILED] Gym not found: ${email}`);
      return res.status(404).json({ msg: 'Gym not found' });
    }

    const salt = await bcrypt.genSalt(10);
    gym.passwordHash = await bcrypt.hash(newPassword, salt);
    await gym.save();

    await OTP.deleteOne({ email });

    console.log(`[PASSWORD RESET SUCCESS] Password updated for: ${email}`);
    res.json({ success: true, message: 'Password reset successful' });
  } catch (err) {
    console.error(`[PASSWORD RESET ERROR] ${err.message}`);
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
