import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../data/database_helper.dart';
import '../models/prediction.dart';
import '../models/mood_entry.dart';

class PredictionProvider extends ChangeNotifier {
  final AiService _aiService = AiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  DepressionPrediction? _latestPrediction;
  List<DepressionPrediction> _history = [];
  bool _isLoading = false;

  DepressionPrediction? get latestPrediction => _latestPrediction;
  List<DepressionPrediction> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> loadLatestPrediction(int userId) async {
    _history = await _dbHelper.getPredictionsForUser(userId);
    if (_history.isNotEmpty) {
      _latestPrediction = _history.first;
    }
    notifyListeners();
  }

  Future<void> runPrediction({
    required int userId,
    required List<MoodEntry> moods,
    required int journalCount,
    required String latestJournalContent,
  }) async {
    if (moods.isEmpty && latestJournalContent.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final moodSummary = moods
          .take(14) // Analyze up to 2 weeks if available
          .map(
            (e) =>
                'Date: ${e.createdAt.toIso8601String().split('T')[0]}, Mood:${e.moodScore}/10, Sleep:${e.sleepHours}h, Stress:${e.stressLevel}/10',
          )
          .join(' | ');

      final prompt = '''
You are "MonBondhu AI", a specialized Mental Health Wellness Assistant for users in Bangladesh. 
Analyze the following longitudinal wellness data to predict depression risk indicators and generate a personalized Recovery Plan.

USER DATA:
- Wellness History (Last 14 logs): $moodSummary
- Total Journals this week: $journalCount
- Most recent journal entry: "$latestJournalContent"

TASK:
1. Determine Depression Risk Level: [Low, Mild, Moderate, Severe].
2. Calculate Confidence Score (0.0 to 1.0) based on data consistency.
3. Write a 2-sentence Clinical Summary focusing on trends (e.g., "Your sleep has decreased while stress increased, suggesting a need for rest").
4. Provide 3-4 highly actionable, culturally relevant Recovery Suggestions. 

OUTPUT FORMAT (Strictly follow this):
Level: [Level]
Confidence: [Score]
Summary: [Summary]
Suggestions: [Task 1] | [Task 2] | [Task 3]

Tone: Empathetic, professional, and supportive.
''';

      final response = await _aiService.sendMessage(prompt);
      final prediction = _parseAiResponse(userId, response);

      await _dbHelper.insertPrediction(prediction);
      _latestPrediction = prediction;
    } catch (e) {
      // ignore: avoid_print
      print('Prediction Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DepressionPrediction _parseAiResponse(int userId, String response) {
    String level = 'Low';
    double confidence = 0.5;
    String summary = 'Unable to generate summary.';
    List<String> suggestions = [];

    final lines = response.split('\n');
    for (var line in lines) {
      if (line.startsWith('Level:')) {
        level = line.replaceFirst('Level:', '').trim().replaceAll('[', '').replaceAll(']', '');
      } else if (line.startsWith('Confidence:')) {
        String confStr = line.replaceFirst('Confidence:', '').trim().replaceAll('[', '').replaceAll(']', '');
        confidence = double.tryParse(confStr) ?? 0.5;
      } else if (line.startsWith('Summary:')) {
        summary = line.replaceFirst('Summary:', '').trim().replaceAll('[', '').replaceAll(']', '');
      } else if (line.startsWith('Suggestions:')) {
        suggestions = line
            .replaceFirst('Suggestions:', '')
            .trim()
            .split('|')
            .map((s) => s.trim().replaceAll('[', '').replaceAll(']', ''))
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }

    return DepressionPrediction(
      userId: userId,
      level: level,
      confidence: confidence,
      summary: summary,
      suggestions: suggestions,
    );
  }
}
