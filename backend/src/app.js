const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { config } = require('./config');
const authRoutes = require('./routes/auth');
const meRoutes = require('./routes/me');
const modelRoutes = require('./routes/models');
const { errorHandler } = require('./middleware/errorHandler');

const app = express();

app.use(helmet());
app.use(
  cors({
    origin: config.corsOrigin,
    credentials: true,
  })
);
app.use(express.json({ limit: '1mb' }));
app.use(morgan('dev'));

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/auth', authLimiter, authRoutes);
app.use('/me', meRoutes);
app.use('/models', modelRoutes);

app.use(errorHandler);

module.exports = app;
