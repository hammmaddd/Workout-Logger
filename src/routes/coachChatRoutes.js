const express = require('express');
const router = express.Router();
const { sendMessage } = require('../controllers/coachChatController');
const verifyFirebaseToken = require('../middleware/firebaseAuthMiddleware');

router.post('/coach/chat', verifyFirebaseToken, sendMessage);

module.exports = router;