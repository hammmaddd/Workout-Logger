const { admin, db } = require('../config/firebaseAdmin');

// =====================================================
// GET ALL NUTRITION RECORDS
// =====================================================
const getNutrition = async (req, res) => {
  try {
    const userId = req.user;
    const { limit = 20, skip = 0, sort = '-date' } = req.query;

    const parsedLimit = parseInt(limit, 10) || 20;
    const parsedSkip = parseInt(skip, 10) || 0;

    let query = db.collection('nutritions').where('userId', '==', userId);

    const isAsc = !sort.startsWith('-');
    const sortField = sort.replace(/^[-+]/, '') || 'date';
    query = query.orderBy(sortField, isAsc ? 'asc' : 'desc');

    const snapshot = await query.get();
    const total = snapshot.size;

    const allDocs = snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        _id: doc.id,
        id: doc.id,
        ...data,
        date: data.date?.toDate ? data.date.toDate().toISOString() : data.date,
        createdAt: data.createdAt?.toDate ? data.createdAt.toDate().toISOString() : data.createdAt,
        updatedAt: data.updatedAt?.toDate ? data.updatedAt.toDate().toISOString() : data.updatedAt
      };
    });

    const paginated = allDocs.slice(parsedSkip, parsedSkip + parsedLimit);

    res.json({
      success: true,
      data: paginated,
      pagination: {
        total,
        limit: parsedLimit,
        skip: parsedSkip
      }
    });
  } catch (error) {
    console.error('getNutrition error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// CREATE NUTRITION RECORD
// =====================================================
const createNutrition = async (req, res) => {
  try {
    const userId = req.user;
    const nutritionData = {
      userId,
      foodName: req.body.foodName || 'Meal',
      calories: Number(req.body.calories) || 0,
      protein: Number(req.body.protein) || 0,
      carbs: Number(req.body.carbs) || 0,
      fats: Number(req.body.fats) || 0,
      quantity: Number(req.body.quantity) || 1,
      mealType: req.body.mealType || 'snack',
      date: req.body.date ? new Date(req.body.date) : new Date(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    const docRef = await db.collection('nutritions').add(nutritionData);
    const savedDoc = await docRef.get();
    const data = savedDoc.data();

    res.status(201).json({
      success: true,
      data: {
        _id: savedDoc.id,
        id: savedDoc.id,
        ...data,
        date: data.date instanceof Date ? data.date.toISOString() : data.date
      }
    });
  } catch (error) {
    console.error('createNutrition error:', error);
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// GET SINGLE NUTRITION RECORD
// =====================================================
const getNutritionById = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('nutritions').doc(id);
    const doc = await docRef.get();

    if (!doc.exists || doc.data().userId !== req.user) {
      return res.status(404).json({
        success: false,
        error: 'Nutrition record not found'
      });
    }

    const data = doc.data();
    res.json({
      success: true,
      data: {
        _id: doc.id,
        id: doc.id,
        ...data,
        date: data.date?.toDate ? data.date.toDate().toISOString() : data.date
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// UPDATE NUTRITION RECORD
// =====================================================
const updateNutrition = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('nutritions').doc(id);
    const doc = await docRef.get();

    if (!doc.exists || doc.data().userId !== req.user) {
      return res.status(404).json({
        success: false,
        error: 'Nutrition record not found'
      });
    }

    const updatePayload = {
      ...req.body,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };
    if (req.body.date) {
      updatePayload.date = new Date(req.body.date);
    }

    await docRef.update(updatePayload);
    const updatedDoc = await docRef.get();
    const data = updatedDoc.data();

    res.json({
      success: true,
      data: {
        _id: updatedDoc.id,
        id: updatedDoc.id,
        ...data,
        date: data.date?.toDate ? data.date.toDate().toISOString() : data.date
      }
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// DELETE NUTRITION RECORD
// =====================================================
const deleteNutrition = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('nutritions').doc(id);
    const doc = await docRef.get();

    if (!doc.exists || doc.data().userId !== req.user) {
      return res.status(404).json({
        success: false,
        error: 'Nutrition record not found'
      });
    }

    await docRef.delete();

    res.json({
      success: true,
      message: 'Nutrition record deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// GET TODAY'S NUTRITION
// =====================================================
const getTodayNutrition = async (req, res) => {
  try {
    const userId = req.user;
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    const snapshot = await db.collection('nutritions')
      .where('userId', '==', userId)
      .where('date', '>=', startOfDay)
      .where('date', '<=', endOfDay)
      .get();

    const nutrition = snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        _id: doc.id,
        id: doc.id,
        ...data,
        date: data.date?.toDate ? data.date.toDate().toISOString() : data.date
      };
    });

    res.json({
      success: true,
      data: nutrition
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// GET TODAY'S NUTRITION TOTALS
// =====================================================
const getNutritionTotals = async (req, res) => {
  try {
    const userId = req.user;
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    const snapshot = await db.collection('nutritions')
      .where('userId', '==', userId)
      .where('date', '>=', startOfDay)
      .where('date', '<=', endOfDay)
      .get();

    let totalCalories = 0;
    let totalProtein = 0;
    let totalCarbs = 0;
    let totalFats = 0;

    snapshot.docs.forEach(doc => {
      const data = doc.data();
      totalCalories += Number(data.calories) || 0;
      totalProtein += Number(data.protein) || 0;
      totalCarbs += Number(data.carbs) || 0;
      totalFats += Number(data.fats) || 0;
    });

    res.json({
      success: true,
      data: {
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFats
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// GET WEEKLY NUTRITION STATISTICS
// =====================================================
const getWeeklyNutrition = async (req, res) => {
  try {
    const userId = req.user;
    const now = new Date();
    const day = now.getDay();
    const daysFromMonday = day === 0 ? 6 : day - 1;

    const startOfWeek = new Date(now);
    startOfWeek.setDate(now.getDate() - daysFromMonday);
    startOfWeek.setHours(0, 0, 0, 0);

    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 7);

    const snapshot = await db.collection('nutritions')
      .where('userId', '==', userId)
      .where('date', '>=', startOfWeek)
      .where('date', '<', endOfWeek)
      .get();

    const mealsThisWeek = snapshot.size;
    let caloriesThisWeek = 0;
    let proteinThisWeek = 0;
    let carbsThisWeek = 0;
    let fatsThisWeek = 0;

    snapshot.docs.forEach(doc => {
      const data = doc.data();
      caloriesThisWeek += Number(data.calories) || 0;
      proteinThisWeek += Number(data.protein) || 0;
      carbsThisWeek += Number(data.carbs) || 0;
      fatsThisWeek += Number(data.fats) || 0;
    });

    res.json({
      success: true,
      data: {
        mealsThisWeek,
        caloriesThisWeek,
        proteinThisWeek,
        carbsThisWeek,
        fatsThisWeek
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// GET MONTHLY NUTRITION STATISTICS
// =====================================================
const getMonthlyNutrition = async (req, res) => {
  try {
    const userId = req.user;
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1, 0, 0, 0, 0);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1, 0, 0, 0, 0);

    const snapshot = await db.collection('nutritions')
      .where('userId', '==', userId)
      .where('date', '>=', startOfMonth)
      .where('date', '<', endOfMonth)
      .get();

    const mealsThisMonth = snapshot.size;
    let caloriesThisMonth = 0;
    let proteinThisMonth = 0;
    let carbsThisMonth = 0;
    let fatsThisMonth = 0;

    snapshot.docs.forEach(doc => {
      const data = doc.data();
      caloriesThisMonth += Number(data.calories) || 0;
      proteinThisMonth += Number(data.protein) || 0;
      carbsThisMonth += Number(data.carbs) || 0;
      fatsThisMonth += Number(data.fats) || 0;
    });

    res.json({
      success: true,
      data: {
        mealsThisMonth,
        caloriesThisMonth,
        proteinThisMonth,
        carbsThisMonth,
        fatsThisMonth
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// GET YEARLY NUTRITION STATISTICS
// =====================================================
const getYearlyNutrition = async (req, res) => {
  try {
    const userId = req.user;
    const now = new Date();
    const startOfYear = new Date(now.getFullYear(), 0, 1, 0, 0, 0, 0);
    const endOfYear = new Date(now.getFullYear() + 1, 0, 1, 0, 0, 0, 0);

    const snapshot = await db.collection('nutritions')
      .where('userId', '==', userId)
      .where('date', '>=', startOfYear)
      .where('date', '<', endOfYear)
      .get();

    const mealsThisYear = snapshot.size;
    let caloriesThisYear = 0;
    let proteinThisYear = 0;
    let carbsThisYear = 0;
    let fatsThisYear = 0;

    snapshot.docs.forEach(doc => {
      const data = doc.data();
      caloriesThisYear += Number(data.calories) || 0;
      proteinThisYear += Number(data.protein) || 0;
      carbsThisYear += Number(data.carbs) || 0;
      fatsThisYear += Number(data.fats) || 0;
    });

    res.json({
      success: true,
      data: {
        mealsThisYear,
        caloriesThisYear,
        proteinThisYear,
        carbsThisYear,
        fatsThisYear
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// GET NUTRITION STREAK
// =====================================================
const getNutritionStreak = async (req, res) => {
  try {
    const userId = req.user;
    const snapshot = await db.collection('nutritions')
      .where('userId', '==', userId)
      .orderBy('date', 'desc')
      .get();

    if (snapshot.empty) {
      return res.json({
        success: true,
        data: {
          currentStreak: 0,
          longestStreak: 0
        }
      });
    }

    const dateSet = new Set();
    snapshot.docs.forEach(doc => {
      const rawDate = doc.data().date;
      const d = rawDate?.toDate ? rawDate.toDate() : new Date(rawDate);
      if (!isNaN(d.getTime())) {
        const dateStr = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
        dateSet.add(dateStr);
      }
    });

    const dates = Array.from(dateSet).map(d => new Date(d)).sort((a, b) => a - b);

    let longestStreak = dates.length > 0 ? 1 : 0;
    let currentSequence = 1;

    for (let i = 1; i < dates.length; i++) {
      const diff = (dates[i] - dates[i - 1]) / (1000 * 60 * 60 * 24);
      if (Math.round(diff) === 1) {
        currentSequence++;
        if (currentSequence > longestStreak) {
          longestStreak = currentSequence;
        }
      } else {
        currentSequence = 1;
      }
    }

    let currentStreak = dates.length > 0 ? 1 : 0;
    for (let i = dates.length - 1; i > 0; i--) {
      const diff = (dates[i] - dates[i - 1]) / (1000 * 60 * 60 * 24);
      if (Math.round(diff) === 1) {
        currentStreak++;
      } else {
        break;
      }
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const latestDate = new Date(dates[dates.length - 1]);
    latestDate.setHours(0, 0, 0, 0);
    const daysSinceLatest = (today - latestDate) / (1000 * 60 * 60 * 24);

    if (daysSinceLatest > 1) {
      currentStreak = 0;
    }

    res.json({
      success: true,
      data: {
        currentStreak,
        longestStreak
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

module.exports = {
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
};