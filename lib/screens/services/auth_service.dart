import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import '../data/database_helper.dart';
import '../models/user.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ✅ ADD THIS METHOD
  Future<User?> login(String username, String password) async {
    try {
      final db = await _dbHelper.database;
      final hashedPassword = _hashPassword(password);

      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username.trim(), hashedPassword],
      );

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null; // Invalid credentials
    } catch (e) {
      debugPrint("Login error: $e");
      return null;
    }
  }

  Future<User?> register(String username, String password) async {
    final db = await _dbHelper.database;

    // 1. Check if username already exists
    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [
        username.trim().toLowerCase(),
      ], // Case-insensitive check is safer
    );

    if (existing.isNotEmpty) {
      throw Exception("USER_EXISTS"); // Throw a specific error for duplicates
    }

    // 2. Perform the insert
    final hashedPassword = _hashPassword(password);
    final newUser = User(username: username.trim(), password: hashedPassword);

    // If this fails (e.g., schema error), it will throw a database exception
    final id = await db.insert('users', newUser.toMap());

    return User(
      id: id,
      username: username.trim(),
      password: hashedPassword,
      createdAt: newUser.createdAt,
    );
  }

  Future<User> loginAnonymous() async {
    final db = await _dbHelper.database;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempUsername = 'anon_$timestamp';

    final newUser = User(username: tempUsername, password: null);

    final id = await db.insert('users', newUser.toMap());

    return User(
      id: id,
      username: tempUsername,
      password: null,
      createdAt: newUser.createdAt,
    );
  }
}
