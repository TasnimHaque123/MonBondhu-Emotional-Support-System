class User {
  final int? id;
  final String username;
  final String? password; // Nullable for anonymous users
  final String? profilePicture;
  final String? condition;
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    this.password,
    this.profilePicture,
    this.condition,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'profile_picture': profilePicture,
      'condition': condition,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      profilePicture: map['profile_picture'],
      condition: map['condition'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
