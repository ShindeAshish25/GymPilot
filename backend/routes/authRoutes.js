const express = require('express');
const router = express.Router();
const { registerGym, loginGym, forgotPassword, sendOTP, verifyOTP, resetPassword, logout } = require('../controllers/authController');
const upload = require('../middleware/uploadMiddleware');
const auth = require('../middleware/authMiddleware');

// @route   POST api/auth/register-gym
router.post('/register-gym', upload.single('gymLogo'), registerGym);

// @route   POST api/auth/login
router.post('/login', loginGym);

// @route   POST api/auth/forgot-password
router.post('/forgot-password', forgotPassword);

// @route   POST api/auth/send-otp
router.post('/send-otp', sendOTP);

// @route   POST api/auth/verify-otp
router.post('/verify-otp', verifyOTP);

// @route   POST api/auth/reset-password
router.post('/reset-password', resetPassword);

// @route   POST api/auth/logout
router.post('/logout', auth, logout);

module.exports = router;
