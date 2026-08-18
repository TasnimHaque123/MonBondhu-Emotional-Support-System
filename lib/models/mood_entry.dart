class MoodEntry {
  final int? id;
  final int userId;
  final int moodScore; // 1-5 scale
  final String moodEmoji; // 😢😟😐🙂😊
  final double sleepHours; // New field
  final int stressLevel; // New field (1-10)
  final String? note; // Optional short note
  final DateTime createdAt;

  MoodEntry({
    this.id,
    required this.userId,
    required this.moodScore,
    required this.moodEmoji,
    this.sleepHours = 8.0,
    this.stressLevel = 5,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'mood_score': moodScore,
      'mood_emoji': moodEmoji,
      'sleep_hours': sleepHours,
      'stress_level': stressLevel,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      userId: map['user_id'],
      moodScore: map['mood_score'],
      moodEmoji: map['mood_emoji'],
      sleepHours: (map['sleep_hours'] ?? 8.0).toDouble(),
      stressLevel: map['stress_level'] ?? 5,
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
