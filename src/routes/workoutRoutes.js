const protect = require('../middleware/authMiddleware');
const express = require('express');
const router = express.Router();

const {
  getWorkouts,
  createWorkout,
  getWorkoutById,
  updateWorkout,
  deleteWorkout,
  getStats,
  getWeeklyStats,
  getStreak
} = require('../controllers/workoutController');

const validateRequest = require('../middleware/validationMiddleware');
const { workoutSchemas } = require('../validation');


// =====================================================
// USER WORKOUTS
// =====================================================

// Get all workouts
router.get('/workouts', protect, getWorkouts);

// Create workout
router.post('/workouts', protect, validateRequest(workoutSchemas.create), createWorkout);


// =====================================================
// INDIVIDUAL WORKOUT
// =====================================================

// Get single workout
router.get('/workouts/:id', protect, getWorkoutById);

// Update workout
router.put('/workouts/:id', protect, updateWorkout);

// Delete workout
router.delete('/workouts/:id', protect, deleteWorkout);


// =====================================================
// STATISTICS
// =====================================================

// Get all workout statistics
router.get('/stats', protect, getStats);

// Get current week's statistics
router.get('/stats/weekly', protect, getWeeklyStats);

// Get workout streak
router.get('/stats/streak', protect, getStreak);


module.exports = router;