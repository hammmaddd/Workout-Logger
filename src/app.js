require('dotenv').config();

const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

const authRoutes = require('./routes/authRoutes');
const workoutRoutes = require('./routes/workoutRoutes');
const nutritionRoutes = require('./routes/nutritionRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const firebaseAuthRoutes = require('./routes/firebaseAuthRoutes');
const nutritionAnalysisRoutes = require('./routes/nutritionAnalysisRoutes');
const coachChatRoutes = require('./routes/coachChatRoutes');

const app = express();

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

app.use((req, res, next) => {
  console.log(
    `[${new Date().toISOString()}] ${req.method} ${req.path}`
  );
  next();
});

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(
      process.env.MONGODB_URI
    );
    console.log(
      `MongoDB connected: ${conn.connection.host}`
    );
  } catch (error) {
    console.error(
      `Error: ${error.message}`
    );
    process.exit(1);
  }
};

app.get('/api/v1/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Workout Logger API is running',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy'
  });
});

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1', workoutRoutes);
app.use('/api/v1', nutritionRoutes);
app.use('/api/v1', dashboardRoutes);
app.use('/api/v1/firebase', firebaseAuthRoutes);
app.use('/api/v1', nutritionAnalysisRoutes);
app.use('/api/v1', coachChatRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Route not found'
  });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message:
      process.env.NODE_ENV === 'development'
        ? err.message
        : 'Something went wrong'
  });
});

const PORT = process.env.PORT || 5000;

if (process.env.MONGODB_URI) {
  connectDB().then(() => {
    app.listen(PORT, () => {
      console.log(
        `🚀 Server running on http://localhost:${PORT}`
      );
      console.log(
        `Environment: ${process.env.NODE_ENV || 'development'}`
      );
    });
  });
} else {
  console.warn(
    '⚠️ MONGODB_URI not set. Running in offline mode.'
  );
  app.listen(PORT, () => {
    console.log(
      `Server running on http://localhost:${PORT} (offline mode)`
    );
  });
}

module.exports = app;