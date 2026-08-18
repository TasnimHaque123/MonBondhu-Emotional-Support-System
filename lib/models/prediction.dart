class DepressionPrediction {
  final int? id;
  final int userId;
  final String level; // Low, Mild, Moderate, Severe
  final double confidence;
  final String summary;
  final List<String> suggestions;
  final DateTime createdAt;

  DepressionPrediction({
    this.id,
    required this.userId,
    required this.level,
    required this.confidence,
    required this.summary,
    required this.suggestions,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'level': level,
      'confidence': confidence,
      'summary': summary,
      'suggestions': suggestions.join('|'),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DepressionPrediction.fromMap(Map<String, dynamic> map) {
    return DepressionPrediction(
      id: map['id'],
      userId: map['user_id'],
      level: map['level'],
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      summary: map['summary'],
      suggestions: (map['suggestions'] as String).split('|'),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
