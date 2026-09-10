const mongoose = require('mongoose');

const workoutSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    exerciseName: {
      type: String,
      required: true,
      trim: true
    },
    sets: {
      type: Number,
      required: true,
      min: 1
    },
    reps: {
      type: Number,
      required: true,
      min: 1
    },
    weight: {
      type: Number,
      default: 0
    },
    weightUnit: {
      type: String,
      enum: ['kg', 'lbs'],
      default: 'kg'
    },
    duration: {
      type: Number,
      description: 'Duration in minutes'
    },
    notes: {
      type: String,
      trim: true
    },
    difficulty: {
      type: String,
      enum: ['easy', 'medium', 'hard'],
      default: 'medium'
    },
    date: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: true
  }
);

// Index for faster queries
workoutSchema.index({ userId: 1, date: -1 });

module.exports = mongoose.model('Workout', workoutSchema);
