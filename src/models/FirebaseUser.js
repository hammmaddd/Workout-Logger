const mongoose = require('mongoose');

const firebaseUserSchema = new mongoose.Schema(
  {
    firebaseUid: {
      type: String,
      required: true,
      unique: true
    },
    email: {
      type: String,
      trim: true,
      lowercase: true
    },
    displayName: {
      type: String,
      trim: true
    },
    lastSyncedAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('FirebaseUser', firebaseUserSchema);