const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { z } = require('zod');
const User = require('../models/User');
const { config } = require('../config');
const { validateBody } = require('../middleware/validate');
const { createAccessToken, createRefreshToken } = require('../utils/token');
const { hashToken } = require('../utils/hash');

const router = express.Router();

const registerSchema = z.object({
  fullName: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(8),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

router.post('/register', validateBody(registerSchema), async (req, res, next) => {
  try {
    const { fullName, email, password } = req.body;
    const normalizedEmail = email.toLowerCase();

    const existingUser = await User.findOne({ email: normalizedEmail });
    if (existingUser) {
      return res.status(409).json({ error: 'Email already in use' });
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const user = await User.create({
      fullName,
      email: normalizedEmail,
      passwordHash,
    });

    const accessToken = createAccessToken(user);
    const refreshToken = createRefreshToken(user);
    user.refreshTokens.push(hashToken(refreshToken));
    await user.save();

    return res.status(201).json({
      user: { id: user._id, fullName: user.fullName, email: user.email },
      accessToken,
      refreshToken,
    });
  } catch (error) {
    return next(error);
  }
});

router.post('/login', validateBody(loginSchema), async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const normalizedEmail = email.toLowerCase();

    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const passwordMatch = await bcrypt.compare(password, user.passwordHash);
    if (!passwordMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const accessToken = createAccessToken(user);
    const refreshToken = createRefreshToken(user);
    user.refreshTokens.push(hashToken(refreshToken));
    await user.save();

    return res.json({
      user: { id: user._id, fullName: user.fullName, email: user.email },
      accessToken,
      refreshToken,
    });
  } catch (error) {
    return next(error);
  }
});

router.post('/refresh', validateBody(refreshSchema), async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    let payload;
    try {
      payload = jwt.verify(refreshToken, config.jwtRefreshSecret);
    } catch (error) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    const user = await User.findById(payload.sub);
    if (!user) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    const tokenHash = hashToken(refreshToken);
    const tokenIndex = user.refreshTokens.findIndex((token) => token === tokenHash);
    if (tokenIndex < 0) {
      return res.status(401).json({ error: 'Refresh token not recognized' });
    }

    user.refreshTokens.splice(tokenIndex, 1);
    const newRefreshToken = createRefreshToken(user);
    user.refreshTokens.push(hashToken(newRefreshToken));
    await user.save();

    const accessToken = createAccessToken(user);
    return res.json({
      accessToken,
      refreshToken: newRefreshToken,
    });
  } catch (error) {
    return next(error);
  }
});

router.post('/logout', validateBody(refreshSchema), async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    let payload;
    try {
      payload = jwt.verify(refreshToken, config.jwtRefreshSecret);
    } catch (error) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    const user = await User.findById(payload.sub);
    if (!user) {
      return res.status(200).json({ success: true });
    }

    const tokenHash = hashToken(refreshToken);
    user.refreshTokens = user.refreshTokens.filter((token) => token !== tokenHash);
    await user.save();

    return res.status(200).json({ success: true });
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
