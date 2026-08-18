// lib/providers/badge_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Badge {
  final String id;
  final String nameEn;
  final String nameBn;
  final IconData icon;
  final Color color;
  final String descriptionEn;
  final String descriptionBn;
  bool isUnlocked;

  Badge({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.icon,
    required this.color,
    required this.descriptionEn,
    required this.descriptionBn,
    this.isUnlocked = false,
  });
}

class BadgeProvider extends ChangeNotifier {
  final List<Badge> _badges = [
    Badge(
      id: 'early_bird',
      nameEn: 'Early Bird',
      nameBn: 'ভোরের পাখি',
      icon: Icons.wb_sunny,
      color: Colors.orange,
      descriptionEn: 'Logged your mood before 8 AM.',
      descriptionBn: 'সকাল ৮টার আগে মুড লগ করেছেন।',
    ),
    Badge(
      id: 'journal_master',
      nameEn: 'Journal Master',
      nameBn: 'ডায়েরি মাস্টার',
      icon: Icons.edit_note,
      color: Colors.blue,
      descriptionEn: 'Written 5 journal entries.',
      descriptionBn: '৫টি জার্নাল এন্ট্রি লিখেছেন।',
    ),
    Badge(
      id: 'quiz_expert',
      nameEn: 'Knowledge Seeker',
      nameBn: 'জ্ঞান অন্বেষণকারী',
      icon: Icons.school,
      color: Colors.teal,
      descriptionEn: 'Completed the mental health quiz.',
      descriptionBn: 'মানসিক স্বাস্থ্য কুইজ সম্পন্ন করেছেন।',
    ),
    Badge(
      id: 'routine_hero',
      nameEn: 'Routine Hero',
      nameBn: 'রুটিন হিরো',
      icon: Icons.check_circle,
      color: Colors.green,
      descriptionEn: 'Completed 10 routine tasks.',
      descriptionBn: '১০টি রুটিন টাস্ক সম্পন্ন করেছেন।',
    ),
    // You can add more badges here later
  ];

  List<Badge> get badges => _badges;
  List<Badge> get unlockedBadges => _badges.where((b) => b.isUnlocked).toList();

  BadgeProvider() {
    _loadFromPrefs();
  }

  // ===================== AUTO UNLOCK METHODS =====================

  Future<void> checkAndUnlockBadges({
    required int totalJournals,
    required int totalRoutinesCompleted,
    required List<DateTime> moodDates, // for early bird
  }) async {
    bool changed = false;

    // Journal Master
    if (totalJournals >= 5) {
      changed = await _unlockIfNotUnlocked('journal_master') || changed;
    }

    // Routine Hero
    if (totalRoutinesCompleted >= 10) {
      changed = await _unlockIfNotUnlocked('routine_hero') || changed;
    }

    // Early Bird - Check if any mood was logged before 8 AM
    if (_hasEarlyBirdMood(moodDates)) {
      changed = await _unlockIfNotUnlocked('early_bird') || changed;
    }

    if (changed) notifyListeners();
  }

  Future<bool> _unlockIfNotUnlocked(String id) async {
    final index = _badges.indexWhere((b) => b.id == id);
    if (index != -1 && !_badges[index].isUnlocked) {
      _badges[index].isUnlocked = true;
      await _saveToPrefs();
      return true;
    }
    return false;
  }

  bool _hasEarlyBirdMood(List<DateTime> moodDates) {
    return moodDates.any((date) => date.hour < 8);
  }

  // Quick unlock for Quiz (already used)
  void unlockBadge(String id) async {
    final index = _badges.indexWhere((b) => b.id == id);
    if (index != -1 && !_badges[index].isUnlocked) {
      _badges[index].isUnlocked = true;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  // Persistence
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    for (var badge in _badges) {
      badge.isUnlocked = prefs.getBool('badge_${badge.id}') ?? false;
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    for (var badge in _badges) {
      await prefs.setBool('badge_${badge.id}', badge.isUnlocked);
    }
  }
}
