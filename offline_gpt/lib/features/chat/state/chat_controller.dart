import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';
import '../domain/chat_message.dart';
import 'chat_state.dart';

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider));
});

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._repository) : super(ChatState.initial()) {
    Future.microtask(loadHistory);
  }

  final ChatRepository _repository;
  Timer? _typingTimer;

  Future<void> loadHistory() async {
    final messages = await _repository.fetchMessages();
    state = state.copyWith(messages: messages);
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) {
      return;
    }

    final userMessage = ChatMessage(
      role: ChatRole.user,
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(userMessage);
    state = state.copyWith(messages: updatedMessages);
    await _repository.addMessage(userMessage);

    await _simulateAssistantResponse(content);
  }

  Future<void> _simulateAssistantResponse(String prompt) async {
    _typingTimer?.cancel();
    final responseText =
        'Reponse locale simulee: $prompt. Le modele activera la vraie inference plus tard.';

    final placeholder = ChatMessage(
      role: ChatRole.assistant,
      content: '',
      createdAt: DateTime.now(),
    );

    final messages = List<ChatMessage>.from(state.messages)..add(placeholder);
    state = state.copyWith(messages: messages, isStreaming: true);

    var index = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (index >= responseText.length) {
        timer.cancel();
        state = state.copyWith(isStreaming: false);
        _repository.addMessage(messages.last.copyWithContent(responseText));
        return;
      }

      index += 1;
      final updated = messages.last.copyWithContent(responseText.substring(0, index));
      messages[messages.length - 1] = updated;
      state = state.copyWith(messages: List<ChatMessage>.from(messages));
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}

extension on ChatMessage {
  ChatMessage copyWithContent(String content) {
    return ChatMessage(
      id: id,
      role: role,
      content: content,
      createdAt: createdAt,
    );
  }
}
