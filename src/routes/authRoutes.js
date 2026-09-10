const express = require('express');

const router = express.Router();

const {
  register,
  login,
  getProfile,
  forgotPassword,
  resetPassword,
  verifyEmail,
  resendVerificationEmail
} = require('../controllers/authController');

const protect = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const { authSchemas } = require('../validation');


// =====================================================
// AUTH
// =====================================================

// Register
router.post('/register', validateRequest(authSchemas.register), register);

// Login
router.post('/login', validateRequest(authSchemas.login), login);

// Verify Email
router.post('/verify-email', verifyEmail);

// Resend Verification Email
router.post('/resend-verification', validateRequest(authSchemas.passwordReset), resendVerificationEmail);

// Forgot Password (Request Reset Token)
router.post('/forgot-password', validateRequest(authSchemas.passwordReset), forgotPassword);

// Reset Password
router.post('/reset-password', validateRequest(authSchemas.passwordResetConfirm), resetPassword);


// =====================================================
// USER PROFILE
// =====================================================

// Get logged-in user's profile + BMI
router.get('/profile', protect, getProfile);


// =====================================================
// EXPORT
// =====================================================

module.exports = router;