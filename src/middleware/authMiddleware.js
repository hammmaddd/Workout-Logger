const jwt = require('jsonwebtoken');
const { auth } = require('../config/firebaseAdmin');

const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    const token = authHeader.split(' ')[1];

    // First attempt Firebase ID Token verification
    try {
      const decodedFirebase = await auth.verifyIdToken(token);
      req.user = decodedFirebase.uid;
      req.firebaseUser = {
        uid: decodedFirebase.uid,
        email: decodedFirebase.email,
        name: decodedFirebase.name || null,
        picture: decodedFirebase.picture || null
      };
      return next();
    } catch (firebaseErr) {
      // Fallback to legacy JWT verification if configured
      if (process.env.JWT_SECRET) {
        try {
          const decoded = jwt.verify(token, process.env.JWT_SECRET);
          req.user = decoded.userId || decoded.id;
          return next();
        } catch (jwtErr) {
          // Fall through to error response
        }
      }
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired authentication token',
        error: firebaseErr.message
      });
    }
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired token',
      error: error.message
    });
  }
};

module.exports = protect;