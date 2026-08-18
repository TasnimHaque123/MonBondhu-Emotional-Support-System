import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AiService _aiService = AiService();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  // NEW: Lazy Initialization
  Future<void> initializeGemini() async {
    await _aiService.initialize();
  }

  Future<void> loadHistory(int userId) async {
    _messages = await _dbHelper.getMessagesForUser(userId);
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  Future<void> sendMessage(String text, int userId, {String? context}) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(
      userId: userId,
      text: text.trim(),
      isUserMessage: true,
    );
    _messages.add(userMsg);
    notifyListeners();

    await _dbHelper.insertMessage(userMsg);

    _isTyping = true;
    notifyListeners();

    try {
      final aiResponseText = await _aiService.sendMessage(text.trim(), context: context);

      final aiMsg = ChatMessage(
        userId: userId,
        text: aiResponseText,
        isUserMessage: false,
      );
      _messages.add(aiMsg);
      await _dbHelper.insertMessage(aiMsg);
    } catch (e) {
      final errorMsg = ChatMessage(
        userId: userId,
        text: 'দুঃখিত, কিছু সমস্যা হয়েছে। আবার চেষ্টা করুন।',
        isUserMessage: false,
      );
      _messages.add(errorMsg);
      await _dbHelper.insertMessage(errorMsg);
    }

    _isTyping = false;
    notifyListeners();
  }
}
