const jwt = require('jsonwebtoken');
const Gym = require('../models/gymModel');
const BlacklistedToken = require('../models/tokenModel');

module.exports = async function (req, res, next) {
  // Get token from header
  const token = req.header('x-auth-token');

  // Check if not token
  if (!token) {
    return res.status(401).json({ msg: 'No token, authorization denied' });
  }

  // Check if token is blacklisted
  const isBlacklisted = await BlacklistedToken.findOne({ token });
  if (isBlacklisted) {
    return res.status(401).json({ msg: 'Token is no longer valid, please login again' });
  }

  // Verify token
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret123');
    req.gym = decoded.gym;

    // SaaS Check: Verify subscription status
    const gym = await Gym.findById(req.gym.id);
    if (!gym) {
      return res.status(401).json({ msg: 'Authorization denied, gym not found' });
    }

    if (gym.planEndDate && gym.planEndDate < new Date()) {
      return res.status(403).json({ 
        msg: 'Subscription expired', 
        expired: true,
        expiryDate: gym.planEndDate 
      });
    }

    next();
  } catch (err) {
    res.status(401).json({ msg: 'Token is not valid' });
  }
};
