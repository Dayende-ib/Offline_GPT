import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model_provider.dart';

class ModeleScreen extends StatefulWidget {
  const ModeleScreen({super.key});

  @override
  State<ModeleScreen> createState() => _ModeleScreenState();
}

class _ModeleScreenState extends State<ModeleScreen> {
  // Liste locale de modèles de chat disponibles offline
  final List<Map<String, dynamic>> _models = [
    {
      'modelId': 'gpt2',
      'description': 'GPT-2, modèle de génération de texte d’OpenAI.',
      'author': 'OpenAI',
      'likes': 10000,
    },
    {
      'modelId': 'mistral-7b',
      'description': 'Mistral 7B, modèle performant pour le chat.',
      'author': 'Mistral AI',
      'likes': 5000,
    },
    {
      'modelId': 'llama-2-7b',
      'description': 'Llama 2, modèle de Meta pour la génération de texte.',
      'author': 'Meta',
      'likes': 8000,
    },
    // Ajoutez ici d’autres modèles locaux si besoin
  ];
  String? _selectedModel;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredModels = [];

  @override
  void initState() {
    super.initState();
    _filteredModels = List.from(_models);
  }

  void _selectModel(String model) {
    setState(() {
      _selectedModel = model;
    });
    Provider.of<ModelProvider>(context, listen: false).setModel(model);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Modèle sélectionné : $model')));
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredModels = List.from(_models);
      } else {
        _filteredModels =
            _models
                .where(
                  (model) =>
                      model['modelId'].toLowerCase().contains(query) ||
                      (model['description'] as String).toLowerCase().contains(
                        query,
                      ),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modèle'), backgroundColor: Colors.blue),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Rechercher un modèle IA...',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.blue),
                    onPressed: _onSearch,
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  _filteredModels.isEmpty
                      ? const Center(
                        child: Text('Aucun modèle de chat disponible.'),
                      )
                      : ListView.builder(
                        itemCount: _filteredModels.length,
                        itemBuilder: (context, index) {
                          final model = _filteredModels[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(model['modelId'] ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((model['description'] as String)
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        model['description'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      if (model['author'] != null &&
                                          model['author'] != '')
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: Text(
                                            'Auteur: ${model['author']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      if (model['likes'] != null)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.thumb_up,
                                              size: 14,
                                              color: Colors.blue,
                                            ),
                                            Text(
                                              ' ${model['likes']}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing:
                                  _selectedModel == model['modelId']
                                      ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.blue,
                                      )
                                      : null,
                              onTap: () => _selectModel(model['modelId']),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
