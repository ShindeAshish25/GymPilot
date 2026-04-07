const Attendance = require('../models/attendanceModel');

exports.checkIn = async (req, res) => {
  const { memberId, checkInDate, checkInTime } = req.body;

  try {
    // Verify member belongs to this gym
    const member = await Member.findOne({ _id: memberId, gymId: req.gym.id });
    if (!member) {
      return res.status(404).json({ msg: 'Member not found in your gym' });
    }

    const newAttendance = new Attendance({
      gymId: req.gym.id,
      memberId,
      checkInDate,
      checkInTime,
    });

    const attendance = await newAttendance.save();
    res.json(attendance);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getAttendance = async (req, res) => {
  try {
    const attendances = await Attendance.find({ 
      memberId: req.params.memberId,
      gymId: req.gym.id 
    }).sort({ checkInDate: -1 });
    res.json(attendances);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
