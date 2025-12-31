process.env.JWT_ACCESS_SECRET = 'test_access_secret';
process.env.JWT_REFRESH_SECRET = 'test_refresh_secret';
process.env.ACCESS_TOKEN_TTL = '15m';
process.env.REFRESH_TOKEN_TTL = '30d';
process.env.CORS_ORIGIN = '*';

const request = require('supertest');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../src/app');
const { connectToDatabase, disconnectFromDatabase } = require('../src/db');

let mongoServer;

describe('Auth endpoints', () => {
  beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    await connectToDatabase(mongoServer.getUri());
  });

  afterAll(async () => {
    await disconnectFromDatabase();
    await mongoServer.stop();
  });

  it('registers a user and returns tokens', async () => {
    const response = await request(app).post('/auth/register').send({
      fullName: 'Ada Lovelace',
      email: 'ada@example.com',
      password: 'securepass',
    });

    expect(response.status).toBe(201);
    expect(response.body.user.email).toBe('ada@example.com');
    expect(response.body.accessToken).toBeTruthy();
    expect(response.body.refreshToken).toBeTruthy();
  });

  it('logs in an existing user and returns tokens', async () => {
    await request(app).post('/auth/register').send({
      fullName: 'Alan Turing',
      email: 'alan@example.com',
      password: 'strongpass',
    });

    const response = await request(app).post('/auth/login').send({
      email: 'alan@example.com',
      password: 'strongpass',
    });

    expect(response.status).toBe(200);
    expect(response.body.user.email).toBe('alan@example.com');
    expect(response.body.accessToken).toBeTruthy();
    expect(response.body.refreshToken).toBeTruthy();
  });

  it('rejects short passwords', async () => {
    const response = await request(app).post('/auth/register').send({
      fullName: 'Grace Hopper',
      email: 'grace@example.com',
      password: 'short',
    });

    expect(response.status).toBe(400);
  });
});
