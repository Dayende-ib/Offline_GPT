const mongoose = require('mongoose');

const modelSchema = new mongoose.Schema(
  {
    modelId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    sizeMB: {
      type: Number,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    recommendedFor: {
      type: [String],
      default: [],
    },
    sha256: {
      type: String,
      required: true,
    },
    downloadUrl: {
      type: String,
      required: true,
    },
  },
  { timestamps: true }
);

const Model = mongoose.model('Model', modelSchema);

module.exports = Model;
