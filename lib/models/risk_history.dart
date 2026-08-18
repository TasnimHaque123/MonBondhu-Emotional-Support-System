class RiskHistory {
  final int? id;
  final int userId;
  final String level; // LOW, MODERATE, HIGH
  final String reason;
  final DateTime createdAt;

  RiskHistory({
    this.id,
    required this.userId,
    required this.level,
    required this.reason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'level': level,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RiskHistory.fromMap(Map<String, dynamic> map) {
    return RiskHistory(
      id: map['id'],
      userId: map['user_id'],
      level: map['level'],
      reason: map['reason'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
