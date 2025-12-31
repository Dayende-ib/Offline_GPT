const express = require('express');
const Model = require('../models/Model');

const router = express.Router();

router.get('/', async (req, res, next) => {
  try {
    const models = await Model.find().sort({ sizeMB: 1 });
    return res.json(
      models.map((model) => ({
        id: model.modelId,
        name: model.name,
        sizeMB: model.sizeMB,
        description: model.description,
        recommendedFor: model.recommendedFor,
        sha256: model.sha256,
        downloadUrl: model.downloadUrl,
      }))
    );
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
