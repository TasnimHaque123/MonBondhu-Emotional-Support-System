import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mental_health/providers/mood_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/routine.dart';
import '../services/ai_service.dart';

class RoutineProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AiService _aiService = AiService();

  List<Routine> _routines = [];
  bool _isLoading = false;

  List<Routine> get routines => _routines;
  bool get isLoading => _isLoading;

  Future<void> initialize(int userId) async {
    _isLoading = true;
    notifyListeners();
    await loadRoutines(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRoutines(int userId) async {
    _routines = await _dbHelper.getRoutinesForUser(userId);
    notifyListeners();
  }

  Future<void> addRoutine(Routine routine) async {
    await _dbHelper.insertRoutine(routine);
    await loadRoutines(routine.userId);
  }

  Future<void> toggleRoutine(Routine routine) async {
    final updated = routine.copyWith(isCompleted: !routine.isCompleted);
    await _dbHelper.updateRoutine(updated);
    await loadRoutines(routine.userId);
  }

  Future<void> deleteRoutine(int id, int userId) async {
    await _dbHelper.deleteRoutine(id);
    await loadRoutines(userId);
  }

  // AI Mood-based task suggestions
  // lib/providers/routine_provider.dart

  Future<void> generateAiRoutine(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final moodProvider = Provider.of<MoodProvider>(
        context as BuildContext,
        listen: false,
      ); // You'll need context or pass data
      final lastMood = moodProvider.entries.isNotEmpty
          ? moodProvider.entries.first.moodEmoji
          : "Neutral";

      final prompt =
          '''
You are MonBondhu, a helpful mental health companion.

Generate a **daily routine** for a person who is currently feeling "$lastMood".

Create a realistic and balanced daily routine with 6-8 activities suitable for someone in Bangladesh.

Include:
- Morning routine
- Healthy habits (water, exercise, meals)
- Mental wellness activities (breathing, journaling, etc.)
- Evening wind-down

Return the response **strictly in JSON format** like this:

{
  "title": "My Peaceful Daily Routine",
  "tasks": [
    {"title": "Wake up and drink water", "type": "HABIT"},
    {"title": "10 minutes deep breathing", "type": "TASK"},
    {"title": "Go for a short walk", "type": "HABIT"},
    ...
  ]
}
''';

      final response = await _aiService.sendMessage(prompt);

      // Parse JSON response
      final List<dynamic> tasks = _parseAiRoutineResponse(response);

      // Add all tasks to routine
      for (var task in tasks) {
        final routine = Routine(
          userId: userId,
          title: task['title'],
          type: task['type'] ?? 'TASK',
        );
        await addRoutine(routine);
      }
    } catch (e) {
      debugPrint('AI Routine Generation Error: $e');
      // Fallback routines
      await _addFallbackRoutines(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to parse AI JSON response
  List<dynamic> _parseAiRoutineResponse(String response) {
    try {
      // Extract JSON from response (in case AI adds extra text)
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        final Map<String, dynamic> data = json.decode(jsonString);
        return data['tasks'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint('JSON Parse Error: $e');
    }
    return [];
  }

  // Fallback if AI fails
  Future<void> _addFallbackRoutines(int userId) async {
    final fallbackTasks = [
      "Drink 2 glasses of water after waking up",
      "10 minutes of deep breathing",
      "Take a short morning walk",
      "Eat a healthy breakfast",
      "Write 3 things you are grateful for",
      "Do light exercise or stretching",
      "Read or listen to something positive",
      "Prepare for bed early",
    ];

    for (var title in fallbackTasks) {
      await addRoutine(Routine(userId: userId, title: title, type: 'HABIT'));
    }
  }
}
