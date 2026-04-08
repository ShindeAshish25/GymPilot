const Trainer = require('../models/trainerModel');

exports.getTrainers = async (req, res) => {
  try {
    const trainers = await Trainer.find({ gymId: req.gym.id }).sort({ createdAt: -1 });
    res.json(trainers);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.addTrainer = async (req, res) => {
  try {
    const newTrainer = new Trainer({
      ...req.body,
      gymId: req.gym.id
    });
    const trainer = await newTrainer.save();
    res.json(trainer);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.updateTrainer = async (req, res) => {
  try {
    let trainer = await Trainer.findOne({ _id: req.params.id, gymId: req.gym.id });
    if (!trainer) return res.status(404).json({ msg: 'Trainer not found or unauthorized' });

    trainer = await Trainer.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true }
    );
    res.json(trainer);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.deleteTrainer = async (req, res) => {
  try {
    const trainer = await Trainer.findOneAndRemove({ _id: req.params.id, gymId: req.gym.id });
    if (!trainer) return res.status(404).json({ msg: 'Trainer not found or unauthorized' });
    res.json({ msg: 'Trainer removed' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
