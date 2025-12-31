# OfflineGPT

This repository contains the OfflineGPT backend (Node.js + MongoDB) and the Flutter mobile app.

- Backend: `backend/`
- Flutter app: `offline_gpt/`

See `offline_gpt/README.md` for full setup and run instructions.

## Railway deployment (backend)

This repo includes a `railway.json` that installs and runs the backend from `backend/`.

Required Railway variables:
- `MONGODB_URI`
- `JWT_ACCESS_SECRET`
- `JWT_REFRESH_SECRET`
- `ACCESS_TOKEN_TTL`
- `REFRESH_TOKEN_TTL`
- `CORS_ORIGIN`

Health check path: `/health`
