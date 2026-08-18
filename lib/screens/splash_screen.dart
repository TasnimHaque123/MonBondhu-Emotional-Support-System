import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/journal_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/routine_provider.dart';
import '../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = "সোহায় লোড হচ্ছে...";
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Initialize Database
      setState(() => _status = "ডেটাবেস প্রস্তুত করা হচ্ছে...");
      final journalProvider = Provider.of<JournalProvider>(
        context,
        listen: false,
      );
      await journalProvider.initialize(); // Make sure this method exists

      // 2. Initialize Gemini AI (Most Important)
      setState(() => _status = "AI সংযোগ তৈরি করা হচ্ছে...");
      if (!mounted) return;
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.initializeGemini();

      // 3. Initialize Mood Provider (if needed)
      setState(() => _status = "মুড ট্র্যাকার প্রস্তুত...");
      if (!mounted) return;
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      await moodProvider.initialize();
      
      // 4. Initialize Notifications
      setState(() => _status = "নোটিফিকেশন প্রস্তুত করা হচ্ছে...");
      await NotificationService().init();
      
      setState(() => _status = "সব প্রস্তুত! 🎉");

      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Wait for AuthProvider to finish loading the session from SharedPreferences
      while (authProvider.isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (!mounted) return;

      if (authProvider.isLoggedIn) {
        final uid = authProvider.currentUser!.id!;
        if (!mounted) return;
        
        // Pre-load data for the user
        await Provider.of<ChatProvider>(context, listen: false).loadHistory(uid);
        if (!mounted) return;
        await Provider.of<JournalProvider>(context, listen: false).loadEntries(uid);
        if (!mounted) return;
        await Provider.of<MoodProvider>(context, listen: false).loadEntries(uid);
        if (!mounted) return;
        await Provider.of<RoutineProvider>(context, listen: false).initialize(uid);
        
        _safeNavigate(true);
      } else {
        _safeNavigate(false);
      }
    } catch (e) {
      debugPrint("Initialization Error: $e");
      setState(() => _status = "ত্রুটি হয়েছে। আবার চেষ্টা করুন।");
    }
  }

  void _safeNavigate(bool isLoggedIn) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image with fallback
            Image.asset(
              'assets/images/logo.png',
              height: 180,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.health_and_safety,
                size: 80,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MonBondhu\nমনবন্ধু',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Text(
              'Your Mind Matters. You Matter.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Text(_status, style: const TextStyle(color: Colors.teal)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
