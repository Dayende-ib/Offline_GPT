# OfflineGPT

This repository contains the OfflineGPT backend (Node.js + MongoDB) and the Flutter mobile app.

- Backend: `backend/`
- Flutter app: `offline_gpt/`

See `offline_gpt/README.md` for full setup and run instructions.

## Railway deployment (backend)

Set the Railway root directory to `backend/`. The backend has its own `railway.json`.

Required Railway variables:
- `MONGODB_URI`
- `JWT_ACCESS_SECRET`
- `JWT_REFRESH_SECRET`
- `ACCESS_TOKEN_TTL`
- `REFRESH_TOKEN_TTL`
- `CORS_ORIGIN`
- `MODEL_UPSERT_SECRET`

Health check path: `/health`

## Models admin upsert

Use `POST /models/upsert` with header `x-admin-key: <MODEL_UPSERT_SECRET>` to create/update models in bulk.

### Scripted upsert with SHA256

Run from `backend/` after downloading the GGUF files locally:

```
set API_BASE_URL=https://offlinegpt-production.up.railway.app
set MODEL_UPSERT_SECRET=your_admin_key
set MODELS_JSON=./scripts/models.sample.json
npm run upsert-models
```
