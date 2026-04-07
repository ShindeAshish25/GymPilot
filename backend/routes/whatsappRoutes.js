const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const { sendOverdueReminder } = require('../controllers/whatsappController');

// @route   POST api/whatsapp/remind
// @desc    Send overdue payment reminder on WhatsApp
// @access  Private
router.post('/remind', auth, sendOverdueReminder);

module.exports = router;
