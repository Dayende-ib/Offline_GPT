# OfflineGPT

OfflineGPT is a Flutter + Node.js project for offline-friendly chat, with models fetched from a secure backend.

## Repository layout

- `backend/`: Node.js + Express API (MongoDB Atlas, JWT auth)
- `offline_gpt/`: Flutter app (Riverpod + go_router + dio)

## Backend setup (Express + MongoDB)

1) Install dependencies:

```
cd backend
npm install
```

2) Configure environment:

```
cp .env.example .env
```

Update the values in `.env`:

- `MONGODB_URI`
- `JWT_ACCESS_SECRET`
- `JWT_REFRESH_SECRET`
- `ACCESS_TOKEN_TTL`
- `REFRESH_TOKEN_TTL`
- `PORT`
- `CORS_ORIGIN`

3) Run the API:

```
npm run dev
```

4) Run tests:

```
npm test
```

## Flutter setup

1) Install dependencies:

```
cd offline_gpt
flutter pub get
```

2) Run the app and point to your API:

```
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Notes:

- Android emulator uses `10.0.2.2` for localhost.
- For iOS simulator, you can use `http://localhost:4000`.
- On a physical device, use your machine LAN IP (e.g. `http://192.168.1.10:4000`).

## API endpoints

- `POST /auth/register` {fullName, email, password}
- `POST /auth/login` {email, password}
- `POST /auth/refresh` {refreshToken}
- `POST /auth/logout` {refreshToken}
- `GET /me` (access token required)
- `GET /models`

## Security notes

- The Flutter app never embeds the MongoDB URI.
- JWT access + refresh tokens are stored in `flutter_secure_storage`.
- Input validation is enforced in the backend using zod.
