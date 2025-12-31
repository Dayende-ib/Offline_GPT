const app = require('./app');
const { config, requireConfig } = require('./config');
const { connectToDatabase } = require('./db');
const { seedModels } = require('./seedModels');

const startServer = async () => {
  requireConfig();
  await connectToDatabase(config.mongodbUri);
  await seedModels();

  app.listen(config.port, () => {
    console.log(`OfflineGPT API running on port ${config.port}`);
  });
};

startServer().catch((error) => {
  console.error('Failed to start server', error);
  process.exit(1);
});
