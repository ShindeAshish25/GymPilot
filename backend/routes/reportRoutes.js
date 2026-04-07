const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const { getCustomReport } = require('../controllers/reportController');

// @route   GET api/reports/custom
// @desc    Generate report based on date range
// @access  Private
router.get('/custom', auth, getCustomReport);

module.exports = router;
