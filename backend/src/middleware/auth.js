const jwt = require('jsonwebtoken');
const { config } = require('../config');

const requireAuth = (req, res, next) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({ error: 'Missing access token' });
  }

  try {
    const payload = jwt.verify(token, config.jwtAccessSecret);
    req.userId = payload.sub;
    req.userEmail = payload.email;
    return next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid or expired access token' });
  }
};

module.exports = {
  requireAuth,
};
