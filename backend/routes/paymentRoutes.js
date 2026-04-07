const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const { addPayment, getPayments } = require('../controllers/paymentController');

// @route   POST api/payments/add
// @desc    Add payment
// @access  Private
router.post('/add', auth, addPayment);

// @route   GET api/payments/member/:memberId
// @desc    Get payments for a member
// @access  Private
router.get('/member/:memberId', auth, getPayments);

module.exports = router;
