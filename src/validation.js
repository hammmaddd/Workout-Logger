const Joi = require('joi');

const authSchemas = {
  register: Joi.object({
    name: Joi.string().min(2).max(50).required(),
    email: Joi.string().email().required(),
    password: Joi.string().min(6).required(),
    age: Joi.number().min(13).required(),
    gender: Joi.string().valid('male', 'female', 'other').required(),
    height: Joi.number().min(50).required(),
    weight: Joi.number().min(20).required(),
    targetWeight: Joi.number().min(20).required(),
    fitnessGoal: Joi.string().valid('weight_loss', 'muscle_gain', 'maintenance', 'general_fitness').required()
  }),

  login: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required()
  })
};

const workoutSchemas = {
  create: Joi.object({
    exerciseName: Joi.string().min(2).max(100).required(),
    sets: Joi.number().min(1).required(),
    reps: Joi.number().min(1).required(),
    weight: Joi.number().min(0).default(0),
    weightUnit: Joi.string().valid('kg', 'lbs').default('kg'),
    duration: Joi.number().min(1),
    notes: Joi.string().max(500),
    difficulty: Joi.string().valid('easy', 'medium', 'hard').default('medium')
  })
};

const nutritionSchemas = {
  create: Joi.object({
    foodName: Joi.string().min(2).max(100).required(),
    calories: Joi.number().min(0).required(),
    protein: Joi.number().min(0).required(),
    carbs: Joi.number().min(0).default(0),
    fats: Joi.number().min(0).default(0),
    quantity: Joi.number().min(0).default(1),
    mealType: Joi.string().valid('breakfast', 'lunch', 'dinner', 'snack').default('snack')
  })
};

module.exports = {
  authSchemas,
  workoutSchemas,
  nutritionSchemas
};