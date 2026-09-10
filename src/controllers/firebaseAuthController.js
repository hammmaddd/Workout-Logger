const { admin, db } = require('../config/firebaseAdmin');

const syncProfile = async (req, res) => {
  try {
    const { uid, email } = req.firebaseUser;
    const { displayName, photoURL } = req.body;

    const userRef = db.collection('users').doc(uid);
    const userData = {
      firebaseUid: uid,
      email: email || null,
      displayName: displayName || null,
      photoURL: photoURL || null,
      lastSyncedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    await userRef.set(userData, { merge: true });
    const userDoc = await userRef.get();

    res.status(200).json({
      success: true,
      data: {
        id: userDoc.id,
        ...userDoc.data()
      }
    });
  } catch (error) {
    console.error('Firebase profile sync error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Server error'
    });
  }
};

module.exports = { syncProfile };