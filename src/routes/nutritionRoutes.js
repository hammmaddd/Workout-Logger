const express = require('express');

const router = express.Router();

const {
  getNutrition,
  createNutrition,
  getNutritionById,
  updateNutrition,
  deleteNutrition,
  getTodayNutrition,
  getNutritionTotals,
  getWeeklyNutrition,
  getMonthlyNutrition,
  getYearlyNutrition,
  getNutritionStreak
} = require('../controllers/nutritionController');

const protect = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const { nutritionSchemas } = require('../validation');


// =====================================================
// NUTRITION
// =====================================================

// Get all nutrition records
router.get('/nutrition', protect, getNutrition);

// Create nutrition record
router.post('/nutrition', protect, validateRequest(nutritionSchemas.create), createNutrition);

// Get today's nutrition
router.get('/nutrition/today', protect, getTodayNutrition);

// Get today's nutrition totals
router.get('/nutrition/totals', protect, getNutritionTotals);


// =====================================================
// NUTRITION PERIOD STATISTICS
// =====================================================

// Get current week's nutrition statistics
router.get('/nutrition/weekly', protect, getWeeklyNutrition);

// Get current month's nutrition statistics
router.get('/nutrition/monthly', protect, getMonthlyNutrition);

// Get current year's nutrition statistics
router.get('/nutrition/yearly', protect, getYearlyNutrition);


// =====================================================
// NUTRITION STREAK
// =====================================================

// IMPORTANT: This must come BEFORE /nutrition/:id
router.get('/nutrition/streak', protect, getNutritionStreak);


// =====================================================
// INDIVIDUAL NUTRITION RECORD
// =====================================================

// Get single nutrition record
router.get('/nutrition/:id', protect, getNutritionById);

// Update nutrition record
router.put('/nutrition/:id', protect, updateNutrition);

// Delete nutrition record
router.delete('/nutrition/:id', protect, deleteNutrition);


// =====================================================
// EXPORT ROUTER
// =====================================================

module.exports = router;