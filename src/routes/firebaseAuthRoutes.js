const express = require('express');
const router = express.Router();
const { syncProfile } = require('../controllers/firebaseAuthController');
const verifyFirebaseToken = require('../middleware/firebaseAuthMiddleware');

router.post('/sync-profile', verifyFirebaseToken, syncProfile);

module.exports = router;