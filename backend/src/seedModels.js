const Model = require('./models/Model');

const defaultModels = [
  {
    modelId: 'lite',
    name: 'Lite',
    sizeMB: 850,
    description: 'Modele compact pour usage rapide et mobile.',
    recommendedFor: ['chat rapide', 'essais locaux'],
    sha256: '2b98e28eeb095426e7124d16cca167e3af5ac4537fdf56f621b7475e532f0ee0',
    downloadUrl: 'https://example.com/models/offlinegpt-lite.bin',
  },
  {
    modelId: 'standard',
    name: 'Standard',
    sizeMB: 2100,
    description: 'Bon compromis entre qualite et taille.',
    recommendedFor: ['assistant generaliste'],
    sha256: '99b231ad8ba546c76b568d9b35c4447655eb7d9e06f8957e2af499d5a345cd6f',
    downloadUrl: 'https://example.com/models/offlinegpt-standard.bin',
  },
  {
    modelId: 'pro',
    name: 'Pro',
    sizeMB: 4600,
    description: 'Modele complet pour taches exigeantes.',
    recommendedFor: ['long contexte', 'redaction complexe'],
    sha256: '0c932075053e6ab3f5cbcd78c3ed8533ffe2525ac68b966a9c5671c6bff617de',
    downloadUrl: 'https://example.com/models/offlinegpt-pro.bin',
  },
];

const seedModels = async () => {
  const count = await Model.countDocuments();
  if (count > 0) {
    return;
  }
  await Model.insertMany(defaultModels);
};

module.exports = {
  seedModels,
};
