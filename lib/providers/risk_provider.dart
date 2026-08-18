import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../data/database_helper.dart';
import '../models/risk_history.dart';

enum RiskLevel { low, moderate, high }

class RiskProvider extends ChangeNotifier {
  final AiService _aiService = AiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  RiskLevel _currentLevel = RiskLevel.low;
  String _reason = 'No recent activity analyzed.';
  bool _isAnalyzing = false;
  List<RiskHistory> _history = [];

  RiskLevel get currentLevel => _currentLevel;
  String get reason => _reason;
  bool get isAnalyzing => _isAnalyzing;
  List<RiskHistory> get history => _history;

  String get currentRisk => _currentLevel.toString().split('.').last.toUpperCase();

  Color get riskColor {
    switch (_currentLevel) {
      case RiskLevel.high: return Colors.red;
      case RiskLevel.moderate: return Colors.orange;
      case RiskLevel.low: return Colors.green;
    }
  }

  String get riskLabel {
    switch (_currentLevel) {
      case RiskLevel.high: return 'High Risk (উচ্চ ঝুঁকি)';
      case RiskLevel.moderate: return 'Moderate Risk (মাঝারি ঝুঁকি)';
      case RiskLevel.low: return 'Low Risk (স্বল্প ঝুঁকি)';
    }
  }

  Future<void> loadHistory(int userId) async {
    _history = await _dbHelper.getRiskHistoryForUser(userId);
    if (_history.isNotEmpty) {
      final latest = _history.first;
      _reason = latest.reason;
      _currentLevel = _parseLevel(latest.level);
    }
    notifyListeners();
  }

  RiskLevel _parseLevel(String level) {
    if (level.contains('HIGH')) return RiskLevel.high;
    if (level.contains('MODERATE')) return RiskLevel.moderate;
    return RiskLevel.low;
  }

  Future<void> analyzeNewContent(String text, int userId) async {
    if (text.trim().isEmpty) return;
    
    _isAnalyzing = true;
    notifyListeners();

    try {
      final result = await _aiService.analyzeRisk(text);
      final parts = result.split('|');
      
      final levelStr = parts[0].trim().toUpperCase();
      final reason = parts.length > 1 ? parts[1].trim() : 'No reason provided.';

      _currentLevel = _parseLevel(levelStr);
      _reason = reason;

      // Save to Database
      final entry = RiskHistory(
        userId: userId,
        level: levelStr,
        reason: reason,
      );
      await _dbHelper.insertRiskHistory(entry);
      _history.insert(0, entry);

    } catch (e) {
      // ignore: avoid_print
      print('Risk Analysis Error: $e');
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }
}
