const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const {
  getTrainers,
  addTrainer,
  updateTrainer,
  deleteTrainer
} = require('../controllers/trainerController');

router.get('/', auth, getTrainers);
router.post('/', auth, addTrainer);
router.put('/:id', auth, updateTrainer);
router.delete('/:id', auth, deleteTrainer);

module.exports = router;
