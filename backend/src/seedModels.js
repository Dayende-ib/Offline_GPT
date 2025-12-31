const Model = require('./models/Model');

const defaultModels = [
  {
    modelId: 'ultra-lite',
    name: 'TinyLlama 1.1B Chat v1.0 (Q4_K_M)',
    sizeMB: 670,
    description: 'Modele ultra leger pour telephones 2-4 GB RAM.',
    recommendedFor: ['mobile', '2-4 GB RAM', 'chat rapide'],
    sha256: 'pending',
    downloadUrl:
      'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf',
  },
  {
    modelId: 'lite',
    name: 'Phi-3 Mini Instruct (Q4_K_M)',
    sizeMB: 900,
    description: 'Modele leger et rapide pour appareils 2-4 GB RAM.',
    recommendedFor: ['mobile', '2-4 GB RAM', 'chat rapide'],
    sha256: 'pending',
    downloadUrl:
      'https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4_k_m.gguf',
  },
  {
    modelId: 'standard',
    name: 'Qwen 2.5 3B Instruct (Q4_K_M)',
    sizeMB: 2100,
    description: 'Modele equilibre et multilingue.',
    recommendedFor: ['assistant generaliste', 'multilingue'],
    sha256: 'pending',
    downloadUrl:
      'https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf',
  },
  {
    modelId: 'pro',
    name: 'Llama 3.2 3B Instruct (Q4_K_M)',
    sizeMB: 2700,
    description: 'Modele qualitatif pour reponses detaillees.',
    recommendedFor: ['redaction longue', 'qualite'],
    sha256: 'pending',
    downloadUrl:
      'https://huggingface.co/hugging-quants/Llama-3.2-3B-Instruct-Q4_K_M-GGUF/resolve/main/llama-3.2-3b-instruct-q4_k_m.gguf',
  },
];

const seedModels = async () => {
  const operations = defaultModels.map((model) => ({
    updateOne: {
      filter: { modelId: model.modelId },
      update: { $set: model },
      upsert: true,
    },
  }));

  if (operations.length > 0) {
    await Model.bulkWrite(operations);
  }
};

module.exports = {
  seedModels,
};
