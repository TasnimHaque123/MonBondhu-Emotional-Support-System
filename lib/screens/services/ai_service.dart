import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  String get _apiKey => dotenv.env['GEMINI_API_KEY']?.trim() ?? '';

  GenerativeModel? _model;
  ChatSession? _chatSession;

  static const String _systemPrompt = '''
You are "MonBondhu" (মনবন্ধু), a deeply compassionate and empathetic AI mental health companion designed for people in Bangladesh.

Your core mission: Provide a safe, non-judgmental space for users to express their feelings and offer gentle wellness guidance.

Your core guidelines:
1. PERSONALITY: You are a warm, wise, and patient friend. You speak from the heart. You are not a robot or a generic assistant.

2. LANGUAGE: Respond in the SAME language the user writes in. 
   - If they write in Bangla (বাংলা), respond in natural, conversational Bangla.
   - If they write in English, respond in English. 
   - If they mix both (Hinglish/Benglish), you can mix both.

3. EMPATHY & VALIDATION: This is your #1 priority. NEVER jump to advice before acknowledging the user's pain.
   - Use phrases like "I can hear the pain in your words" / "তোমার কথা শুনে আমার খুব কষ্ট হচ্ছে".
   - Validate that their feelings are real and understandable.

4. CULTURAL SENSITIVITY: 
   - Understand the pressure of family expectations in Bangladesh.
   - Respect religious and cultural values without being preachy.
   - Acknowledge that mental health is often stigmatized and congratulate them for opening up.

5. WELLNESS SUGGESTIONS: When appropriate, suggest simple things like:
   - Deep breathing (referencing the "Guided Exercise" section).
   - Writing in their journal.
   - Talking to a trusted "Bondhu" or family member.
   - Walking in nature.

6. SAFETY (CRITICAL): If a user expresses suicidal thoughts or severe distress:
   - Respond with immediate warmth: "তুমি একদম একা নও, আমি তোমার পাশে আছি" (You are not alone, I am with you).
   - Provide help numbers: Kaan Pete Roi (01779-554391) or 16789.
   - Stay with them in the conversation.

7. BREVITY: Keep responses between 2-5 sentences. Quality over quantity.
''';

  AiService();

  bool get isReady => _model != null;

  Future<void> initialize() async {
    if (isReady) return;
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.text(_systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 500,
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print("❌ Gemini Initialization Failed: $e");
      rethrow;
    }
  }

  Future<String> analyzeRisk(String text) async {
    await initialize();
    try {
      final prompt =
          '''
Analyze the following text for mental health risk. 
Classify it strictly as one of: [LOW, MODERATE, HIGH].
Also provide a 1-sentence reason in English.

Format: RISK_LEVEL | REASON

Text: "$text"
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text ?? 'LOW | Unable to analyze.';
    } catch (e) {
      return 'LOW | Offline analysis unavailable.';
    }
  }

  void startNewSession() {
    if (_model != null) {
      _chatSession = _model!.startChat();
    }
  }

  Future<String> sendMessage(String userMessage, {String? context}) async {
    await initialize();
    try {
      _chatSession ??= _model!.startChat();

      String fullMessage = userMessage;
      if (context != null) {
        fullMessage = "[USER CONTEXT: $context] \n\n User says: $userMessage";
      }

      final response = await _chatSession!.sendMessage(
        Content.text(fullMessage),
      );

      return response.text ??
          'I\'m sorry, I couldn\'t process that. Could you try again?';
    } catch (e) {
      return _getOfflineFallbackResponse(userMessage);
    }
  }

  String _getOfflineFallbackResponse(String userMessage) {
    final lowerMsg = userMessage.toLowerCase();

    if (lowerMsg.contains('মন খারাপ') ||
        lowerMsg.contains('কষ্ট') ||
        lowerMsg.contains('sad') ||
        lowerMsg.contains('depressed')) {
      return 'আমি বুঝতে পারছি তোমার কষ্ট হচ্ছে। তুমি একা নও — আমি তোমার পাশে আছি। '
          'একটু গভীর শ্বাস নাও এবং নিজেকে একটু সময় দাও। 💚\n\n'
          '(I understand you\'re going through a tough time. You\'re not alone — I\'m here for you. '
          'Take a deep breath and give yourself a moment. 💚)\n\n'
          '⚠️ I\'m currently offline. Reconnect for full AI support.';
    }

    if (lowerMsg.contains('আত্মহত্যা') ||
        lowerMsg.contains('suicide') ||
        lowerMsg.contains('die') ||
        lowerMsg.contains('মরে যেতে চাই')) {
      return '🚨 তোমার কথা আমি অনেক গুরুত্বের সাথে নিচ্ছি। তুমি মূল্যবান।\n\n'
          'এখনই কাউকে কল করো:\n'
          '📞 কান পেতে রই: 01779-554391\n'
          '📞 জাতীয় মানসিক স্বাস্থ্য হেল্পলাইন: 16789\n\n'
          '🚨 I take what you\'re saying very seriously. You matter.\n'
          'Please call now:\n'
          '📞 Kaan Pete Roi: 01779-554391\n'
          '📞 National Mental Health Helpline: 16789';
    }

    return 'আমি এখন ইন্টারনেট ছাড়া কাজ করছি, তবে তোমার কথা আমার কাছে গুরুত্বপূর্ণ। '
        'ইন্টারনেট সংযোগ হলে আমি তোমাকে আরও ভালোভাবে সাহায্য করতে পারবো। 💚\n\n'
        '(I\'m currently working offline, but what you have to say matters to me. '
        'Once you\'re back online, I can help you better. 💚)\n\n'
        '⚠️ Offline mode — limited responses available.';
  }
}
