const mongoose = require('mongoose');


// =====================================================
// USER SCHEMA
// =====================================================

const userSchema = new mongoose.Schema(
  {
    // =================================================
    // BASIC INFORMATION
    // =================================================

    name: {
      type: String,
      required: true,
      trim: true
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true
    },

    password: {
      type: String,
      required: true,
      minlength: 6
    },

    // =================================================
    // EMAIL VERIFICATION
    // =================================================

    isEmailVerified: {
      type: Boolean,
      default: false
    },

    emailVerificationToken: {
      type: String,
      default: null
    },

    emailVerificationExpires: {
      type: Date,
      default: null
    },

    // =================================================
    // PERSONAL / FITNESS INFORMATION
    // =================================================

    age: {
      type: Number,
      required: true,
      min: 1
    },

    gender: {
      type: String,
      enum: ['male', 'female', 'other'],
      required: true
    },

    // Height in centimeters
    height: {
      type: Number,
      required: true,
      min: 50
    },

    // Current weight in kilograms
    weight: {
      type: Number,
      required: true,
      min: 20
    },

    // Target weight in kilograms
    targetWeight: {
      type: Number,
      required: true,
      min: 20
    },

    fitnessGoal: {
      type: String,
      enum: [
        'weight_loss',
        'muscle_gain',
        'maintenance',
        'general_fitness'
      ],
      required: true
    }
  },
  {
    timestamps: true
  }
);


// =====================================================
// EXPORT MODEL
// =====================================================

module.exports = mongoose.model('User', userSchema);