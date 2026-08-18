import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/mood_entry.dart';

class InsightsProvider extends ChangeNotifier {
  final AiService _aiService = AiService();
  
  String _aiInsight = "Analyze your week to see insights.";
  bool _isLoading = false;

  String get aiInsight => _aiInsight;
  bool get isLoading => _isLoading;

  Future<void> generateWeeklyInsights(List<MoodEntry> moods, int journalCount, String currentRisk) async {
    if (moods.isEmpty && journalCount == 0) return;

    _isLoading = true;
    notifyListeners();

    try {
      final moodSummary = moods.take(7).map((e) => e.moodEmoji).join(', ');
      final avgSleep = moods.isEmpty ? 0 : moods.map((e) => e.sleepHours).reduce((a, b) => a + b) / moods.length;
      final avgStress = moods.isEmpty ? 0 : moods.map((e) => e.stressLevel).reduce((a, b) => a + b) / moods.length;

      final prompt = '''
Based on the following user data from the last week:
- Moods: $moodSummary
- Average Sleep: ${avgSleep.toStringAsFixed(1)} hours
- Average Stress: ${avgStress.toStringAsFixed(1)}/10
- Journals written: $journalCount
- Current Risk Level: $currentRisk

Provide a very short, personalized summary (2 sentences max) of their mental health trend.
Focus on improvements or areas needing care.
Example: "You are improving this week. Your stress has decreased in the last 3 days."
''';
      
      final response = await _aiService.sendMessage(prompt);
      _aiInsight = response.trim();
    } catch (e) {
      _aiInsight = "Unable to generate insights at this moment.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
