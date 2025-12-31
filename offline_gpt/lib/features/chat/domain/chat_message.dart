enum ChatRole { user, assistant }

class ChatMessage {
  final int? id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, Object?> map) {
    return ChatMessage(
      id: map['id'] as int?,
      role: ChatRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => ChatRole.user,
      ),
      content: (map['content'] as String?) ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
