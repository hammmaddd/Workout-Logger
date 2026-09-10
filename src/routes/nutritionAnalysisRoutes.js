const express = require('express');
const router = express.Router();
const { analyzePhoto } = require('../controllers/nutritionAnalysisController');
const verifyFirebaseToken = require('../middleware/firebaseAuthMiddleware');

router.post('/nutrition/analyze-photo', verifyFirebaseToken, analyzePhoto);

module.exports = router;