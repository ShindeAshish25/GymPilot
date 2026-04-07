const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const {
  addMember,
  getMembers,
  updateMember,
  deleteMember,
  getExpiringMembers
} = require('../controllers/memberController');

const upload = require('../middleware/uploadMiddleware');

// @route   POST api/members/add
// @desc    Add new member
// @access  Private
router.post('/add', auth, upload.single('photo'), addMember);

// @route   GET api/members
// @desc    Get all members for the logged-in gym
// @access  Private
router.get('/', auth, getMembers);

// @route   PUT api/members/update/:id
// @desc    Update a member
// @access  Private
router.put('/update/:id', auth, updateMember);

// @route   DELETE api/members/delete/:id
// @desc    Delete a member
// @access  Private
router.delete('/delete/:id', auth, deleteMember);

// @route   GET api/members/expiring
// @desc    Get members whose membership is expiring in 2 days
// @access  Private
router.get('/expiring/list', auth, getExpiringMembers);

module.exports = router;
