const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const gymController = require('../controllers/gymController');

// @route   GET api/gym/profile
// @desc    Get current gym profile
// @access  Private
router.get('/profile', auth, gymController.getProfile);

// @route   PUT api/gym/profile
// @desc    Update gym profile (Name, Email, Phone)
// @access  Private
router.put('/profile', auth, gymController.updateProfile);

// @route   PUT api/gym/info
// @desc    Update gym name and logo
// @access  Private
router.put('/info', [auth, upload.single('logo')], gymController.updateGymInfo);

// @route   PUT api/gym/membership
// @desc    Extend membership
// @access  Private
router.put('/membership', auth, gymController.updateMembership);

module.exports = router;
