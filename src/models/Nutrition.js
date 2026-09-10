const mongoose = require('mongoose');

const nutritionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: 'User'
    },

    foodName: {
      type: String,
      required: true,
      trim: true
    },

    calories: {
      type: Number,
      required: true,
      min: 0
    },

    protein: {
      type: Number,
      required: true,
      min: 0
    },

    carbs: {
      type: Number,
      default: 0,
      min: 0
    },

    fats: {
      type: Number,
      default: 0,
      min: 0
    },

    quantity: {
      type: Number,
      default: 1,
      min: 0
    },

    mealType: {
      type: String,
      enum: [
        'breakfast',
        'lunch',
        'dinner',
        'snack'
      ],
      default: 'snack'
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

module.exports = mongoose.model('Nutrition', nutritionSchema);