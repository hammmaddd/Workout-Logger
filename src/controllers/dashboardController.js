const { db } = require('../config/firebaseAdmin');

// =====================================================
// GET USER DASHBOARD
// =====================================================
const getDashboard = async (req, res) => {
  try {
    const userId = req.user;
    const now = new Date();

    // -----------------------------
    // TODAY
    // -----------------------------
    const startOfDay = new Date(now);
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date(now);
    endOfDay.setHours(23, 59, 59, 999);

    // -----------------------------
    // CURRENT WEEK
    // -----------------------------
    const day = now.getDay();
    const daysFromMonday = day === 0 ? 6 : day - 1;

    const startOfWeek = new Date(now);
    startOfWeek.setDate(now.getDate() - daysFromMonday);
    startOfWeek.setHours(0, 0, 0, 0);

    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 7);

    // -----------------------------
    // CURRENT MONTH
    // -----------------------------
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1, 0, 0, 0, 0);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1, 0, 0, 0, 0);

    // -----------------------------
    // CURRENT YEAR
    // -----------------------------
    const startOfYear = new Date(now.getFullYear(), 0, 1, 0, 0, 0, 0);
    const endOfYear = new Date(now.getFullYear() + 1, 0, 1, 0, 0, 0, 0);

    // Query all nutrition and workouts for this user in the current year
    const [nutritionSnapshot, workoutSnapshot] = await Promise.all([
      db.collection('nutritions')
        .where('userId', '==', userId)
        .where('date', '>=', startOfYear)
        .where('date', '<', endOfYear)
        .get(),
      db.collection('workouts')
        .where('userId', '==', userId)
        .where('date', '>=', startOfYear)
        .where('date', '<', endOfYear)
        .get()
    ]);

    const summarizeNutrition = (docs, start, end) => {
      let meals = 0;
      let calories = 0;
      let protein = 0;
      let carbs = 0;
      let fats = 0;

      docs.forEach(doc => {
        const data = doc.data();
        const d = data.date?.toDate ? data.date.toDate() : new Date(data.date);
        if (d >= start && d <= end) {
          meals++;
          calories += Number(data.calories) || 0;
          protein += Number(data.protein) || 0;
          carbs += Number(data.carbs) || 0;
          fats += Number(data.fats) || 0;
        }
      });

      return { meals, calories, protein, carbs, fats };
    };

    const summarizeWorkouts = (docs, start, end) => {
      let workouts = 0;
      let sets = 0;
      let reps = 0;
      let volume = 0;
      let duration = 0;

      docs.forEach(doc => {
        const data = doc.data();
        const d = data.date?.toDate ? data.date.toDate() : new Date(data.date);
        if (d >= start && d <= end) {
          workouts++;
          const s = Number(data.sets) || 0;
          const r = Number(data.reps) || 0;
          const w = Number(data.weight) || 0;
          const dur = Number(data.duration) || 0;

          sets += s;
          reps += r;
          volume += s * r * w;
          duration += dur;
        }
      });

      return { workouts, sets, reps, volume, duration };
    };

    const nDocs = nutritionSnapshot.docs;
    const wDocs = workoutSnapshot.docs;

    res.json({
      success: true,
      data: {
        today: {
          nutrition: summarizeNutrition(nDocs, startOfDay, endOfDay),
          workout: summarizeWorkouts(wDocs, startOfDay, endOfDay)
        },
        weekly: {
          nutrition: summarizeNutrition(nDocs, startOfWeek, endOfWeek),
          workout: summarizeWorkouts(wDocs, startOfWeek, endOfWeek)
        },
        monthly: {
          nutrition: summarizeNutrition(nDocs, startOfMonth, endOfMonth),
          workout: summarizeWorkouts(wDocs, startOfMonth, endOfMonth)
        },
        yearly: {
          nutrition: summarizeNutrition(nDocs, startOfYear, endOfYear),
          workout: summarizeWorkouts(wDocs, startOfYear, endOfYear)
        }
      }
    });
  } catch (error) {
    console.error('getDashboard error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

module.exports = {
  getDashboard
};