const { analyzeFoodPhoto } = require('../config/geminiClient');

const analyzePhoto = async (req, res) => {
  try {
    const { imageBase64, mimeType } = req.body;

    if (!imageBase64 || typeof imageBase64 !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'imageBase64 is required'
      });
    }

    const result = await analyzeFoodPhoto(imageBase64, mimeType || 'image/jpeg');

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Photo analysis error:', error.message);

    const status = error.isTransient ? 503 : 500;
    res.status(status).json({
      success: false,
      message: error.message || 'Could not analyze this photo. Please try again.'
    });
  }
};

module.exports = { analyzePhoto };