const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const { checkIn, getAttendance } = require('../controllers/attendanceController');

// @route   POST api/attendance/checkin
// @desc    Check-in member
// @access  Private
router.post('/checkin', auth, checkIn);

// @route   GET api/attendance/member/:memberId
// @desc    Get attendance for a member
// @access  Private
router.get('/member/:memberId', auth, getAttendance);

module.exports = router;
