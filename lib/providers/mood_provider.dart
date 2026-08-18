import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/mood_entry.dart';

class MoodProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<MoodEntry> _entries = [];

  List<MoodEntry> get entries => _entries;

  Future<void> initialize() async {
    // Ensure database is ready
    await _dbHelper.database;
  }

  /// Average mood score for the last 7 days.
  double get weeklyAverage {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recent = _entries.where((e) => e.createdAt.isAfter(weekAgo)).toList();
    if (recent.isEmpty) return 0;
    return recent.map((e) => e.moodScore).reduce((a, b) => a + b) / recent.length;
  }

  /// Get mood entries grouped by day for chart display.
  Map<String, double> get weeklyTrend {
    final now = DateTime.now();
    final trend = <String, List<int>>{};

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.month}/${day.day}';
      trend[key] = [];
    }

    for (final entry in _entries) {
      final key = '${entry.createdAt.month}/${entry.createdAt.day}';
      if (trend.containsKey(key)) {
        trend[key]!.add(entry.moodScore);
      }
    }

    return trend.map((key, scores) {
      if (scores.isEmpty) return MapEntry(key, 0.0);
      return MapEntry(key, scores.reduce((a, b) => a + b) / scores.length);
    });
  }

  Future<void> loadEntries(int userId) async {
    _entries = await _dbHelper.getMoodsForUser(userId);
    notifyListeners();
  }

  Future<void> addMood(MoodEntry entry) async {
    await _dbHelper.insertMood(entry);
    _entries.insert(0, entry);
    notifyListeners();
  }

  void clearEntries() {
    _entries = [];
    notifyListeners();
  }
}
