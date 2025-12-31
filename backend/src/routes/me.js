const express = require('express');
const User = require('../models/User');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.get('/', requireAuth, async (req, res, next) => {
  try {
    const user = await User.findById(req.userId).select('fullName email');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    return res.json({
      id: user._id,
      fullName: user.fullName,
      email: user.email,
    });
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
