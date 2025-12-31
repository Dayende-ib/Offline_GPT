const express = require('express');
const { z } = require('zod');
const Model = require('../models/Model');
const { config } = require('../config');
const { validateBody } = require('../middleware/validate');

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

const modelSchema = z.object({
  modelId: z.string().min(1),
  name: z.string().min(1),
  sizeMB: z.number().int().positive(),
  description: z.string().min(1),
  recommendedFor: z.array(z.string()).default([]),
  sha256: z.string().min(1),
  downloadUrl: z.string().url(),
});

const upsertSchema = z.union([modelSchema, z.array(modelSchema)]);

router.post('/upsert', validateBody(upsertSchema), async (req, res, next) => {
  try {
    if (!config.modelUpsertSecret) {
      return res.status(500).json({ error: 'MODEL_UPSERT_SECRET not set' });
    }

    const apiKey = req.headers['x-admin-key'];
    if (apiKey !== config.modelUpsertSecret) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const payload = Array.isArray(req.body) ? req.body : [req.body];
    const operations = payload.map((model) => ({
      updateOne: {
        filter: { modelId: model.modelId },
        update: { $set: model },
        upsert: true,
      },
    }));

    const result = await Model.bulkWrite(operations);
    return res.json({
      matched: result.matchedCount,
      modified: result.modifiedCount,
      upserted: result.upsertedCount,
    });
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
