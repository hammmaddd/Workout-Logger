const { chatWithCoach } = require('../config/geminiClient');

const MAX_MESSAGE_LENGTH = 500;
const MAX_HISTORY_LENGTH = 20;

const sendMessage = async (req, res) => {
  try {
    const { messages } = req.body;

    if (!Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'messages array is required'
      });
    }

    const trimmed = messages.slice(-MAX_HISTORY_LENGTH);

    for (const m of trimmed) {
      if (typeof m.text !== 'string' || m.text.trim().length === 0) {
        return res.status(400).json({ success: false, message: 'Invalid message in history' });
      }
      if (m.text.length > MAX_MESSAGE_LENGTH) {
        return res.status(400).json({ success: false, message: `Messages must be under ${MAX_MESSAGE_LENGTH} characters` });
      }
    }

    const result = await chatWithCoach(trimmed);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Coach chat error:', error.message);
    const status = error.isTransient ? 503 : 500;
    res.status(status).json({
      success: false,
      message: error.message || 'Could not get a reply right now.'
    });
  }
};

module.exports = { sendMessage };