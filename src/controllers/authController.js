const { admin, db, auth } = require('../config/firebaseAdmin');

// =====================================================
// REGISTER (FIREBASE AUTH + FIRESTORE)
// =====================================================
const register = async (req, res) => {
  try {
    const {
      name,
      displayName,
      email,
      password,
      age,
      gender,
      height,
      weight,
      targetWeight,
      fitnessGoal
    } = req.body;

    const userName = name || displayName;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    let firebaseUserRecord;

    if (password) {
      // Create user in Firebase Authentication
      firebaseUserRecord = await auth.createUser({
        email,
        password,
        displayName: userName
      });
    } else {
      // User might already be authenticated via Google / ID Token
      firebaseUserRecord = req.firebaseUser || { uid: req.user, email };
    }

    const uid = firebaseUserRecord.uid;

    const userData = {
      firebaseUid: uid,
      name: userName || null,
      displayName: userName || null,
      email,
      age: age ? Number(age) : null,
      gender: gender || null,
      height: height ? Number(height) : null,
      weight: weight ? Number(weight) : null,
      targetWeight: targetWeight ? Number(targetWeight) : null,
      fitnessGoal: fitnessGoal || 'general_fitness',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    await db.collection('users').doc(uid).set(userData, { merge: true });

    res.status(201).json({
      success: true,
      message: 'User registered successfully in Firebase',
      data: {
        id: uid,
        uid: uid,
        name: userName,
        email
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    if (error.code === 'auth/email-already-exists') {
      return res.status(409).json({
        success: false,
        message: 'Email already registered'
      });
    }
    res.status(500).json({
      success: false,
      message: error.message || 'Server error'
    });
  }
};

// =====================================================
// LOGIN (STATUS CHECK / FIREBASE TOKEN EXCHANGE)
// =====================================================
const login = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    // Get user from Firebase Auth
    const userRecord = await auth.getUserByEmail(email);
    const userDoc = await db.collection('users').doc(userRecord.uid).get();

    res.json({
      success: true,
      message: 'User authenticated via Firebase',
      user: {
        id: userRecord.uid,
        uid: userRecord.uid,
        name: userRecord.displayName || userDoc.data()?.name,
        email: userRecord.email,
        isEmailVerified: userRecord.emailVerified
      }
    });
  } catch (error) {
    console.error('Login check error:', error);
    res.status(401).json({
      success: false,
      message: 'Authentication failed',
      error: error.message
    });
  }
};

// =====================================================
// GET USER PROFILE (FROM FIRESTORE)
// =====================================================
const getProfile = async (req, res) => {
  try {
    const userId = req.user;
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      // Fallback check in Firebase Auth
      try {
        const authRecord = await auth.getUser(userId);
        return res.json({
          success: true,
          data: {
            id: authRecord.uid,
            name: authRecord.displayName,
            email: authRecord.email,
            isEmailVerified: authRecord.emailVerified,
            bmi: null,
            bmiCategory: 'Not available',
            weightToTarget: null
          }
        });
      } catch (_) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }
    }

    const user = userDoc.data();

    let bmi = null;
    let bmiCategory = 'Not available';

    if (
      user.height &&
      user.weight &&
      user.height > 0 &&
      user.weight > 0
    ) {
      const heightInMeters = user.height / 100;
      bmi = Number((user.weight / (heightInMeters * heightInMeters)).toFixed(1));

      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
      } else if (bmi < 25) {
        bmiCategory = 'Normal weight';
      } else if (bmi < 30) {
        bmiCategory = 'Overweight';
      } else {
        bmiCategory = 'Obese';
      }
    }

    let weightToTarget = null;
    if (
      user.weight !== undefined &&
      user.weight !== null &&
      user.targetWeight !== undefined &&
      user.targetWeight !== null
    ) {
      weightToTarget = Number(
        Math.abs(user.targetWeight - user.weight).toFixed(1)
      );
    }

    res.json({
      success: true,
      data: {
        id: userDoc.id,
        name: user.name || user.displayName,
        email: user.email,
        age: user.age,
        gender: user.gender,
        height: user.height,
        weight: user.weight,
        targetWeight: user.targetWeight,
        fitnessGoal: user.fitnessGoal,
        isEmailVerified: user.isEmailVerified || false,
        bmi,
        bmiCategory,
        weightToTarget
      }
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// =====================================================
// FORGOT PASSWORD
// =====================================================
const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, message: 'Email required' });
    }

    const link = await auth.generatePasswordResetLink(email);

    res.json({
      success: true,
      message: 'Password reset link generated',
      resetLink: link
    });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Server error'
    });
  }
};

// =====================================================
// RESET PASSWORD / VERIFY EMAIL STUBS
// =====================================================
const resetPassword = async (req, res) => {
  res.json({
    success: true,
    message: 'Please use Firebase client password reset or reset link'
  });
};

const verifyEmail = async (req, res) => {
  res.json({
    success: true,
    message: 'Firebase handles email verification automatically via client SDK'
  });
};

const resendVerificationEmail = async (req, res) => {
  try {
    const { email } = req.body;
    const link = await auth.generateEmailVerificationLink(email);
    res.json({
      success: true,
      message: 'Email verification link generated',
      verificationLink: link
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

module.exports = {
  register,
  login,
  getProfile,
  forgotPassword,
  resetPassword,
  verifyEmail,
  resendVerificationEmail
};