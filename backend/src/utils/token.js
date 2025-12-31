const jwt = require('jsonwebtoken');
const { config } = require('../config');

const createAccessToken = (user) =>
  jwt.sign({ sub: user._id.toString(), email: user.email }, config.jwtAccessSecret, {
    expiresIn: config.accessTokenTtl,
  });

const createRefreshToken = (user) =>
  jwt.sign({ sub: user._id.toString() }, config.jwtRefreshSecret, {
    expiresIn: config.refreshTokenTtl,
  });

module.exports = {
  createAccessToken,
  createRefreshToken,
};
