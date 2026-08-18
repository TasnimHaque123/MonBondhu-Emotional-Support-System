class Routine {
  final int? id;
  final int userId;
  final String title;
  final String type; // 'TASK' or 'HABIT'
  final bool isCompleted;
  final String? scheduledTime;
  final DateTime createdAt;

  Routine({
    this.id,
    required this.userId,
    required this.title,
    required this.type,
    this.isCompleted = false,
    this.scheduledTime,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'type': type,
      'is_completed': isCompleted ? 1 : 0,
      'scheduled_time': scheduledTime,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      type: map['type'],
      isCompleted: map['is_completed'] == 1,
      scheduledTime: map['scheduled_time'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Routine copyWith({
    int? id,
    int? userId,
    String? title,
    String? type,
    bool? isCompleted,
    String? scheduledTime,
    DateTime? createdAt,
  }) {
    return Routine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
