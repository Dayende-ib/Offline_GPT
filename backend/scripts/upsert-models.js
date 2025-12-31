const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const readJson = (filePath) => {
  const raw = fs.readFileSync(filePath, 'utf8');
  return JSON.parse(raw);
};

const sha256File = (filePath) =>
  new Promise((resolve, reject) => {
    const hash = crypto.createHash('sha256');
    const stream = fs.createReadStream(filePath);
    stream.on('error', reject);
    stream.on('data', (chunk) => hash.update(chunk));
    stream.on('end', () => resolve(hash.digest('hex')));
  });

const toMB = (bytes) => Math.max(1, Math.round(bytes / (1024 * 1024)));

const normalizeBaseUrl = (url) => url.replace(/\/$/, '');

const validateModel = (model) => {
  const required = ['modelId', 'name', 'description', 'downloadUrl', 'filePath'];
  const missing = required.filter((key) => !model[key]);
  if (missing.length > 0) {
    throw new Error(`Missing fields: ${missing.join(', ')}`);
  }
};

const loadModels = (modelsPath) => {
  const data = readJson(modelsPath);
  return Array.isArray(data) ? data : [data];
};

const buildPayload = async (models) => {
  const payload = [];

  for (const model of models) {
    validateModel(model);
    const resolvedPath = path.resolve(model.filePath);
    if (!fs.existsSync(resolvedPath)) {
      throw new Error(`File not found: ${resolvedPath}`);
    }

    const stat = fs.statSync(resolvedPath);
    const sizeMB = Number.isFinite(model.sizeMB)
      ? model.sizeMB
      : toMB(stat.size);

    const sha256 = await sha256File(resolvedPath);

    payload.push({
      modelId: model.modelId,
      name: model.name,
      sizeMB,
      description: model.description,
      recommendedFor: model.recommendedFor ?? [],
      sha256,
      downloadUrl: model.downloadUrl,
    });
  }

  return payload;
};

const upsertModels = async (apiBaseUrl, adminKey, payload) => {
  const response = await fetch(`${normalizeBaseUrl(apiBaseUrl)}/models/upsert`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-admin-key': adminKey,
    },
    body: JSON.stringify(payload),
  });

  const text = await response.text();
  if (!response.ok) {
    throw new Error(`Upsert failed (${response.status}): ${text}`);
  }

  return text ? JSON.parse(text) : {};
};

const main = async () => {
  const apiBaseUrl = process.env.API_BASE_URL;
  const adminKey = process.env.MODEL_UPSERT_SECRET;
  const modelsPath =
    process.env.MODELS_JSON || path.join(__dirname, 'models.sample.json');

  if (!apiBaseUrl) {
    throw new Error('Missing API_BASE_URL');
  }
  if (!adminKey) {
    throw new Error('Missing MODEL_UPSERT_SECRET');
  }

  const models = loadModels(modelsPath);
  const payload = await buildPayload(models);
  const result = await upsertModels(apiBaseUrl, adminKey, payload);
  console.log('Upsert OK:', result);
};

main().catch((error) => {
  console.error('Upsert failed:', error.message);
  process.exit(1);
});
