import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ui/tech_theme.dart';
import '../../auth/state/auth_controller.dart';
import '../../models/state/models_controller.dart';
import '../domain/chat_message.dart';
import '../state/chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final modelsState = ref.watch(modelsControllerProvider);
    final authState = ref.watch(authControllerProvider);

    final hasActiveModel =
        modelsState.models.any((model) => model.isActive);
    final hasAnyInstalled = modelsState.models
        .any((model) => model.isInstalled || model.isActive);

    return Scaffold(
      backgroundColor: TechPalette.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (!authState.isAuthenticated)
            TextButton(
              onPressed: () => context.go('/auth'),
              style: TextButton.styleFrom(
                foregroundColor: TechPalette.accent,
              ),
              child: const Text('Se connecter / S\'inscrire'),
            ),
        ],
      ),
      body: Stack(
        children: [
          const TechBackground(),
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatState.messages[index];
                          return _ChatBubble(message: message);
                        },
                      ),
                    ),
                    if (!hasActiveModel)
                      _NoModelBanner(
                        isAuthenticated: authState.isAuthenticated,
                        onAction: () {
                          if (authState.isAuthenticated) {
                            context.go('/models');
                          } else {
                            context.go('/auth');
                          }
                        },
                      ),
                    _InputBar(
                      controller: _controller,
                      enabled: hasActiveModel,
                      onSend: () {
                        final text = _controller.text;
                        _controller.clear();
                        ref.read(chatControllerProvider.notifier).sendMessage(text);
                      },
                    ),
                  ],
                ),
                if (!hasAnyInstalled)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TechPalette.surfaceStrong,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: TechPalette.outline),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.download_for_offline_outlined,
                            color: TechPalette.accent,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Aucun modele installe. Telechargez un pack IA pour commencer.',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (authState.isAuthenticated) {
                                context.go('/models');
                              } else {
                                context.go('/auth');
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: TechPalette.accent,
                            ),
                            child: const Text('Voir'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isUser
        ? TechPalette.accent.withOpacity(0.16)
        : TechPalette.surfaceStrong;
    final borderColor = isUser ? TechPalette.accent : TechPalette.outline;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor.withOpacity(0.8)),
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: TechPalette.textPrimary),
        ),
      ),
    );
  }
}

class _NoModelBanner extends StatelessWidget {
  final bool isAuthenticated;
  final VoidCallback onAction;

  const _NoModelBanner({
    required this.isAuthenticated,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TechPalette.surfaceStrong,
        border: Border.all(color: TechPalette.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: TechPalette.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAuthenticated
                  ? 'Aucun modele actif. Telechargez puis activez un modele.'
                  : 'Aucun modele installe. Connectez-vous pour telecharger.',
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: TechPalette.accent,
            ),
            child: Text(isAuthenticated ? 'Modeles' : 'Auth'),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                decoration: InputDecoration(
                  hintText: enabled
                      ? 'Ecrire un message...'
                      : 'Activez un modele pour discuter',
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: TechPalette.accent),
              onPressed: enabled ? onSend : null,
            ),
          ],
        ),
      ),
    );
  }
}
