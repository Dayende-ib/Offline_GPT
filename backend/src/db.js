const mongoose = require('mongoose');

const connectToDatabase = async (mongodbUri) => {
  if (!mongodbUri) {
    throw new Error('MongoDB URI is required');
  }
  await mongoose.connect(mongodbUri, {
    autoIndex: true,
  });
};

const disconnectFromDatabase = async () => {
  await mongoose.disconnect();
};

module.exports = {
  connectToDatabase,
  disconnectFromDatabase,
};
