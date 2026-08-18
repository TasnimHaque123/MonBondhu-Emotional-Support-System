import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  String _phase = 'Ready';
  int _seconds = 0;
  Timer? _timer;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _startExercise() {
    setState(() {
      _isActive = true;
      _phase = 'Inhale';
    });
    _runCycle();
  }

  void _runCycle() async {
    if (!mounted || !_isActive) return;

    // Phase 1: Inhale (4s)
    setState(() {
      _phase = 'Inhale';
      _seconds = 4;
    });
    _controller.duration = const Duration(seconds: 4);
    _controller.forward();
    await _countdown(4);

    if (!mounted || !_isActive) return;

    // Phase 2: Hold (7s)
    setState(() {
      _phase = 'Hold';
      _seconds = 7;
    });
    await _countdown(7);

    if (!mounted || !_isActive) return;

    // Phase 3: Exhale (8s)
    setState(() {
      _phase = 'Exhale';
      _seconds = 8;
    });
    _controller.duration = const Duration(seconds: 8);
    _controller.reverse();
    await _countdown(8);

    if (mounted && _isActive) {
      _runCycle(); // Repeat
    }
  }

  Future<void> _countdown(int seconds) async {
    for (int i = seconds; i > 0; i--) {
      if (!mounted || !_isActive) return;
      setState(() => _seconds = i);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void _stopExercise() {
    setState(() {
      _isActive = false;
      _phase = 'Stopped';
    });
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('Deep Breathing', 'গভীর শ্বাস-প্রশ্বাস')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              langProvider.translate(_phase, _translatePhase(_phase)),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 20),
            Text(
              '$_seconds',
              style: const TextStyle(fontSize: 48, color: Colors.grey),
            ),
            const SizedBox(height: 60),
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.teal, width: 4),
                ),
                child: const Center(
                  child: Icon(Icons.air, size: 80, color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 100),
            if (!_isActive)
              ElevatedButton(
                onPressed: _startExercise,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(langProvider.translate('Start Exercise', 'ব্যায়াম শুরু করুন')),
              )
            else
              OutlinedButton(
                onPressed: _stopExercise,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  langProvider.translate('Stop', 'থামুন'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _translatePhase(String phase) {
    switch (phase) {
      case 'Inhale': return 'শ্বাস নিন';
      case 'Hold': return 'ধরে রাখুন';
      case 'Exhale': return 'শ্বাস ছাড়ুন';
      case 'Ready': return 'প্রস্তুত';
      default: return 'শেষ';
    }
  }
}
