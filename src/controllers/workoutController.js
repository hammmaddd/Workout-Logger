const { admin, db } = require('../config/firebaseAdmin');

// =====================================================
// GET ALL WORKOUTS FOR AUTHENTICATED USER
// =====================================================
const getWorkouts = async (req, res) => {
  try {
    const userId = req.user;
    const { limit = 20, skip = 0, sort = '-date' } = req.query;

    const parsedLimit = parseInt(limit, 10) || 20;
    const parsedSkip = parseInt(skip, 10) || 0;

    let query = db.collection('workouts').where('userId', '==', userId);

    // Default sort by date desc
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
    console.error('getWorkouts error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// CREATE NEW WORKOUT
// =====================================================
const createWorkout = async (req, res) => {
  try {
    const userId = req.user;
    const workoutData = {
      userId,
      exerciseName: req.body.exerciseName || req.body.name || 'Workout',
      sets: Number(req.body.sets) || 1,
      reps: Number(req.body.reps) || 1,
      weight: Number(req.body.weight) || 0,
      weightUnit: req.body.weightUnit || 'kg',
      duration: req.body.duration !== undefined ? Number(req.body.duration) : 0,
      notes: req.body.notes || '',
      difficulty: req.body.difficulty || 'medium',
      date: req.body.date ? new Date(req.body.date) : new Date(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    const docRef = await db.collection('workouts').add(workoutData);
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
    console.error('createWorkout error:', error);
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// GET SINGLE WORKOUT
// =====================================================
const getWorkoutById = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('workouts').doc(id);
    const doc = await docRef.get();

    if (!doc.exists || doc.data().userId !== req.user) {
      return res.status(404).json({
        success: false,
        error: 'Workout not found'
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
// UPDATE WORKOUT
// =====================================================
const updateWorkout = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('workouts').doc(id);
    const doc = await docRef.get();

    if (!doc.exists || doc.data().userId !== req.user) {
      return res.status(404).json({
        success: false,
        error: 'Workout not found'
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
// DELETE WORKOUT
// =====================================================
const deleteWorkout = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('workouts').doc(id);
    const doc = await docRef.get();

    if (!doc.exists || doc.data().userId !== req.user) {
      return res.status(404).json({
        success: false,
        error: 'Workout not found'
      });
    }

    await docRef.delete();

    res.json({
      success: true,
      message: 'Workout deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// =====================================================
// GET WORKOUT STATISTICS
// =====================================================
const getStats = async (req, res) => {
  try {
    const userId = req.user;
    const snapshot = await db.collection('workouts').where('userId', '==', userId).get();

    const totalWorkouts = snapshot.size;
    let totalSets = 0;
    let totalReps = 0;
    let totalWeight = 0;
    let totalVolume = 0;
    let totalDuration = 0;

    snapshot.docs.forEach(doc => {
      const data = doc.data();
      const sets = Number(data.sets) || 0;
      const reps = Number(data.reps) || 0;
      const weight = Number(data.weight) || 0;
      const duration = Number(data.duration) || 0;

      totalSets += sets;
      totalReps += reps;
      totalWeight += weight;
      totalVolume += sets * reps * weight;
      totalDuration += duration;
    });

    const avgWeight = totalWorkouts > 0 ? totalWeight / totalWorkouts : 0;

    res.json({
      success: true,
      data: {
        totalWorkouts,
        totalSets,
        totalReps,
        avgWeight,
        totalVolume,
        totalDuration
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
// GET WEEKLY WORKOUT STATISTICS
// =====================================================
const getWeeklyStats = async (req, res) => {
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

    const snapshot = await db.collection('workouts')
      .where('userId', '==', userId)
      .where('date', '>=', startOfWeek)
      .where('date', '<', endOfWeek)
      .get();

    const workoutsThisWeek = snapshot.size;
    let setsThisWeek = 0;
    let repsThisWeek = 0;
    let volumeThisWeek = 0;
    let durationThisWeek = 0;

    snapshot.docs.forEach(doc => {
      const data = doc.data();
      const sets = Number(data.sets) || 0;
      const reps = Number(data.reps) || 0;
      const weight = Number(data.weight) || 0;
      const duration = Number(data.duration) || 0;

      setsThisWeek += sets;
      repsThisWeek += reps;
      volumeThisWeek += sets * reps * weight;
      durationThisWeek += duration;
    });

    res.json({
      success: true,
      data: {
        workoutsThisWeek,
        setsThisWeek,
        repsThisWeek,
        volumeThisWeek,
        durationThisWeek
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
// GET WORKOUT STREAK
// =====================================================
const getStreak = async (req, res) => {
  try {
    const userId = req.user;
    const snapshot = await db.collection('workouts')
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
  getWorkouts,
  createWorkout,
  getWorkoutById,
  updateWorkout,
  deleteWorkout,
  getStats,
  getWeeklyStats,
  getStreak
};