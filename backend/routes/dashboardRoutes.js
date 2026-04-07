const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const { getDashboardStats, getChartData } = require('../controllers/dashboardController');

// @route   GET api/dashboard/stats
// @desc    Get dashboard metrics
// @access  Private
router.get('/stats', auth, getDashboardStats);

// @route   GET api/dashboard/charts
// @desc    Get dashboard chart data
// @access  Private
router.get('/charts', auth, getChartData);

module.exports = router;
