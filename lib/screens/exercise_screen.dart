import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'breathing_exercise_screen.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('Guided Exercises', 'নির্দেশিত ব্যায়াম')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExerciseCard(
            context,
            langProvider.translate('Deep Breathing', 'গভীর শ্বাস-প্রশ্বাস'),
            langProvider.translate('Calm your mind with the 4-7-8 technique.', '৪-৭-৮ কৌশলের মাধ্যমে আপনার মনকে শান্ত করুন।'),
            Icons.air,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BreathingExerciseScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _buildExerciseCard(
            context,
            langProvider.translate('Muscle Relaxation', 'পেশী শিথিলকরণ'),
            langProvider.translate('Release physical tension from your body.', 'আপনার শরীর থেকে শারীরিক উত্তেজনা মুক্তি দিন।'),
            Icons.accessibility_new,
            Colors.orange,
            null, // To be implemented
          ),
          const SizedBox(height: 16),
          _buildExerciseCard(
            context,
            langProvider.translate('Grounding (5-4-3-2-1)', 'গ্রাউন্ডিং (৫-৪-৩-২-১)'),
            langProvider.translate('Connect with your surroundings to stay present.', 'বর্তমানে থাকার জন্য আপনার চারপাশের সাথে সংযোগ করুন।'),
            Icons.self_improvement,
            Colors.teal,
            null, // To be implemented
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
