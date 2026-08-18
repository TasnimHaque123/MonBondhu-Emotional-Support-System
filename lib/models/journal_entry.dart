class JournalEntry {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final String? moodEmoji; // Optional emoji tag for the entry
  final DateTime createdAt;

  JournalEntry({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.moodEmoji,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'mood_emoji': moodEmoji,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'],
      moodEmoji: map['mood_emoji'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
