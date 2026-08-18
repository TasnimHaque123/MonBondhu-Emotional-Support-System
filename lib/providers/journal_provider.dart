import 'package:flutter/material.dart';
import 'package:mental_health/providers/badge_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/journal_entry.dart';

class JournalProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<JournalEntry> _entries = [];

  List<JournalEntry> get entries => _entries;

  Future<void> initialize() async {
    // Ensure database is ready
    await _dbHelper.database;
  }

  Future<void> loadEntries(int userId) async {
    _entries = await _dbHelper.getJournalsForUser(userId);
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry) async {
    await _dbHelper.insertJournal(entry);
    _entries.insert(0, entry);
    notifyListeners();

    // Auto unlock badges
    final badgeProvider = Provider.of<BadgeProvider>(
      context as BuildContext,
      listen: false,
    ); // Need context or use another way
    badgeProvider.checkAndUnlockBadges(
      totalJournals: _entries.length,
      totalRoutinesCompleted: 0, // You can pass from other providers
      moodDates: [],
    );
  }

  Future<void> deleteEntry(int id, int userId) async {
    await _dbHelper.deleteJournal(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void clearEntries() {
    _entries = [];
    notifyListeners();
  }
}
