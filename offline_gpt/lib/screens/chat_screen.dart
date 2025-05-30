import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = [
    _Message(text: "Bonjour ! Comment puis-je vous aider ?", isUser: false),
  ];
  bool _waiting = false;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _waiting) return;
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _controller.clear();
      _waiting = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      final selectedModel =
          Provider.of<ModelProvider>(context, listen: false).selectedModel;
      setState(() {
        _messages.add(
          _Message(text: _getFakeResponse(selectedModel, text), isUser: false),
        );
        _waiting = false;
      });
    });
  }

  String _getFakeResponse(String? model, String userMsg) {
    switch (model) {
      case 'gpt2':
        return "[GPT-2] Réponse simulée à: '$userMsg'";
      case 'mistral-7b':
        return "[Mistral 7B] Voici une réponse simulée pour: '$userMsg'";
      case 'llama-2-7b':
        return "[Llama 2] Je réponds à: '$userMsg'";
      default:
        return "[Aucun modèle sélectionné] Je ne peux pas répondre.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedModel = Provider.of<ModelProvider>(context).selectedModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedModel != null ? 'Chat IA ($selectedModel)' : 'Chat IA',
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.deepPurple : Colors.grey[200],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_waiting,
                    decoration: const InputDecoration(
                      hintText: "Écrivez votre message...",
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: _waiting ? Colors.grey : Colors.deepPurple,
                  ),
                  onPressed: _waiting ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  _Message({required this.text, required this.isUser});
}
