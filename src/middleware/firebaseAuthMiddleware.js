const { auth } = require('../config/firebaseAdmin');

const verifyFirebaseToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    const idToken = authHeader.split(' ')[1];
    const decoded = await auth.verifyIdToken(idToken);

    req.firebaseUser = {
      uid: decoded.uid,
      email: decoded.email,
      name: decoded.name || decoded.displayName || null,
      picture: decoded.picture || null
    };
    req.user = decoded.uid;

    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired token',
      error: error.message
    });
  }
};

module.exports = verifyFirebaseToken;