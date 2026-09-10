const axios = require('axios');

const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-3.7-flash';
const GEMINI_ENDPOINT = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

const RESPONSE_SCHEMA = {
  type: 'OBJECT',
  properties: {
    items: {
      type: 'ARRAY',
      items: {
        type: 'OBJECT',
        properties: {
          name: { type: 'STRING' },
          confidence: { type: 'NUMBER' },
          servingDescription: { type: 'STRING' },
          calories: { type: 'NUMBER' },
          protein: { type: 'NUMBER' },
          carbs: { type: 'NUMBER' },
          fats: { type: 'NUMBER' }
        },
        propertyOrdering: ['name', 'confidence', 'servingDescription', 'calories', 'protein', 'carbs', 'fats']
      }
    }
  },
  propertyOrdering: ['items']
};

const ANALYSIS_PROMPT = `You are a nutrition estimation assistant analyzing a food photo.

Identify each distinct food item visible in the photo. For each item, estimate a realistic calorie and macro breakdown (protein, carbs, fats in grams) for the serving size shown.

Rules:
- These are estimates, not lab measurements — be reasonable and conservative, not exact.
- Recognize South Asian / Pakistani dishes by their real names when visible (e.g. "Chicken Karahi", "Daal Chana", "Biryani", "Roti") rather than generic Western labels.
- If the photo shows no food at all, return an empty "items" array — do not invent a food item.
- confidence is a number from 0 to 1 reflecting how sure you are of the identification.
- servingDescription should be a short human-readable portion estimate, e.g. "1 plate, ~250g".

Respond only with JSON matching the provided schema.`;

const COACH_SYSTEM_INSTRUCTION = `You are Coach Glow, a friendly fitness and nutrition assistant inside the Workout Logger app.

You help with: workouts, exercise technique, training programs, muscle recovery, nutrition, macros, calories, meal planning, hydration, weight management, and using this app's features.

If asked something unrelated to fitness, nutrition, or this app — general trivia, coding, news, entertainment, anything else — politely decline and steer back. Say something like "I'm focused on your fitness and nutrition journey — happy to help with workouts, nutrition, or the app!" Do not answer unrelated questions even if you know the answer.

You are not a doctor. Never diagnose injuries, diseases, or prescribe medication. If someone describes pain, dizziness, fainting, chest pain, a serious injury, or other concerning symptoms, tell them to stop the activity and seek appropriate professional medical attention — do not try to assess or treat it yourself.

Keep answers concise and practical — this is a mobile chat, not an essay.`;

function clampNumber(value, min, max, fallback) {
  const num = typeof value === 'number' ? value : parseFloat(value);
  if (isNaN(num)) return fallback;
  return Math.min(Math.max(num, min), max);
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

const RETRYABLE_STATUS_CODES = [429, 503];
const MAX_ATTEMPTS = 3;
const RETRY_DELAYS_MS = [1000, 2000];

async function postToGeminiWithRetry(requestBody, apiKey) {
  let lastError;

  for (let attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
    try {
      return await axios.post(GEMINI_ENDPOINT, requestBody, {
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey
        },
        timeout: 20000
      });
    } catch (error) {
      lastError = error;
      const status = error.response?.status;

      if (RETRYABLE_STATUS_CODES.includes(status) && attempt < MAX_ATTEMPTS - 1) {
        console.warn(`Gemini returned ${status} — retrying (attempt ${attempt + 2}/${MAX_ATTEMPTS})...`);
        await sleep(RETRY_DELAYS_MS[attempt]);
        continue;
      }

      throw error;
    }
  }

  throw lastError;
}

function requireApiKey() {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey === 'your_gemini_api_key_here') {
    throw new Error('GEMINI_API_KEY is not configured on the server');
  }
  return apiKey;
}

function extractText(response) {
  const candidates = response.data?.candidates;
  if (!candidates || candidates.length === 0) {
    throw new Error('No response from Gemini');
  }
  const parts = candidates[0]?.content?.parts;
  const textPart = parts?.find((p) => typeof p.text === 'string');
  if (!textPart) {
    throw new Error('Gemini response contained no text');
  }
  return textPart.text;
}

async function analyzeFoodPhoto(base64Image, mimeType = 'image/jpeg') {
  const apiKey = requireApiKey();

  const requestBody = {
    contents: [
      {
        parts: [
          { text: ANALYSIS_PROMPT },
          { inline_data: { mime_type: mimeType, data: base64Image } }
        ]
      }
    ],
    generationConfig: {
      responseMimeType: 'application/json',
      responseSchema: RESPONSE_SCHEMA
    }
  };

  let response;
  try {
    response = await postToGeminiWithRetry(requestBody, apiKey);
  } catch (error) {
    const status = error.response?.status;
    console.error('Gemini request error:', error.response?.data || error.message);
    if (status === 503 || status === 429) {
      const busyError = new Error('The AI service is busy right now. Please try again in a moment.');
      busyError.isTransient = true;
      throw busyError;
    }
    throw new Error('Could not reach the AI service.');
  }

  const text = extractText(response);
  let parsed;
  try {
    parsed = JSON.parse(text);
  } catch (err) {
    throw new Error('Could not parse Gemini response as JSON');
  }

  const rawItems = Array.isArray(parsed.items) ? parsed.items : [];
  const items = rawItems.map((item) => ({
    name: typeof item.name === 'string' && item.name.trim() ? item.name.trim() : 'Unknown item',
    confidence: clampNumber(item.confidence, 0, 1, 0.3),
    servingDescription: typeof item.servingDescription === 'string' ? item.servingDescription : '',
    calories: clampNumber(item.calories, 0, 5000, 0),
    protein: clampNumber(item.protein, 0, 500, 0),
    carbs: clampNumber(item.carbs, 0, 500, 0),
    fats: clampNumber(item.fats, 0, 500, 0)
  }));

  return { items };
}

async function chatWithCoach(messages) {
  const apiKey = requireApiKey();

  // Gemini uses "model" for the assistant's own turns, not "assistant".
  const contents = messages.map((m) => ({
    role: m.role === 'assistant' ? 'model' : 'user',
    parts: [{ text: m.text }]
  }));

  const requestBody = {
    systemInstruction: {
      parts: [{ text: COACH_SYSTEM_INSTRUCTION }]
    },
    contents
  };

  let response;
  try {
    response = await postToGeminiWithRetry(requestBody, apiKey);
  } catch (error) {
    const status = error.response?.status;
    console.error('Gemini chat error:', error.response?.data || error.message);
    if (status === 503 || status === 429) {
      const busyError = new Error('Coach Glow is a bit busy right now. Please try again in a moment.');
      busyError.isTransient = true;
      throw busyError;
    }
    throw new Error('Could not reach Coach Glow.');
  }

  const text = extractText(response);
  return { reply: text.trim() };
}

module.exports = { analyzeFoodPhoto, chatWithCoach };