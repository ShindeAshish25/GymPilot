const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const {
  addInquiry,
  getInquiries,
  updateInquiryStatus,
  deleteInquiry
} = require('../controllers/inquiryController');

router.post('/add', auth, addInquiry);
router.get('/', auth, getInquiries);
router.put('/update/:id', auth, updateInquiryStatus);
router.delete('/delete/:id', auth, deleteInquiry);

module.exports = router;
