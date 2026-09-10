const protect = require('../middleware/authMiddleware');
const express = require('express');

const router = express.Router();

const {
  getDashboard
} = require('../controllers/dashboardController');



// =====================================================
// DASHBOARD
// =====================================================

// Get complete user dashboard
router.get('/dashboard', protect, getDashboard);



// =====================================================
// EXPORT ROUTER
// =====================================================

module.exports = router;