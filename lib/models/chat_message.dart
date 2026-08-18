class ChatMessage {
  final int? id;
  final int userId;
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  ChatMessage({
    this.id,
    required this.userId,
    required this.text,
    required this.isUserMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'text': text,
      'is_user_message': isUserMessage ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      userId: map['user_id'],
      text: map['text'],
      isUserMessage: map['is_user_message'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
