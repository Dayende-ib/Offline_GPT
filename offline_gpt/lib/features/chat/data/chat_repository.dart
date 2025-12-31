import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/app_database.dart';
import '../domain/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(database: AppDatabase.instance);
});

class ChatRepository {
  ChatRepository({required this.database});

  final AppDatabase database;

  Future<List<ChatMessage>> fetchMessages() async {
    final rows = await database.fetchMessages();
    return rows.map(ChatMessage.fromMap).toList();
  }

  Future<void> addMessage(ChatMessage message) async {
    await database.insertMessage(message.toMap());
  }
}
