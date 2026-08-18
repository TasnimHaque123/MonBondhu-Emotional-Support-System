import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  bool _loaded = false;

  static const List<Map<String, dynamic>> _moodOptions = [
    {'emoji': '😢', 'label': 'Very Sad', 'score': 1, 'color': 0xFFE57373},
    {'emoji': '😟', 'label': 'Sad', 'score': 2, 'color': 0xFFFFB74D},
    {'emoji': '😐', 'label': 'Okay', 'score': 3, 'color': 0xFFFFD54F},
    {'emoji': '🙂', 'label': 'Good', 'score': 4, 'color': 0xFF81C784},
    {'emoji': '😊', 'label': 'Great', 'score': 5, 'color': 0xFF4FC3F7},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
      if (userId != null) {
        Provider.of<MoodProvider>(context, listen: false).loadEntries(userId);
      }
    }
  }

  Future<void> _showMoodDetailsDialog(Map<String, dynamic> mood) async {
    double sleepHours = 8.0;
    int stressLevel = 5;
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Log Wellness: ${mood['emoji']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How many hours did you sleep?', style: TextStyle(fontSize: 14)),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: sleepHours,
                        min: 0,
                        max: 15,
                        divisions: 30,
                        label: sleepHours.toStringAsFixed(1),
                        onChanged: (val) => setDialogState(() => sleepHours = val),
                      ),
                    ),
                    Text('${sleepHours.toStringAsFixed(1)}h'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('How stressed are you? (1-10)', style: TextStyle(fontSize: 14)),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: stressLevel.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: stressLevel.toString(),
                        onChanged: (val) => setDialogState(() => stressLevel = val.toInt()),
                      ),
                    ),
                    Text('$stressLevel'),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Optional note / মন্তব্য',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _logMoodFull(mood, sleepHours, stressLevel, noteController.text);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logMoodFull(Map<String, dynamic> mood, double sleep, int stress, String? note) async {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId == null) return;

    final entry = MoodEntry(
      userId: userId,
      moodScore: mood['score'],
      moodEmoji: mood['emoji'],
      sleepHours: sleep,
      stressLevel: stress,
      note: note?.trim().isEmpty == true ? null : note,
    );

    await Provider.of<MoodProvider>(context, listen: false).addMood(entry);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged: ${mood['emoji']} — ${sleep.toStringAsFixed(1)}h sleep')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Wellness Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'আজ তোমার কেমন লাগছে?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Better Mood Selection Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _moodOptions.map((mood) {
                  return GestureDetector(
                    onTap: () => _showMoodDetailsDialog(mood),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(mood['color'] as int).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text(mood['emoji'], style: const TextStyle(fontSize: 32)),
                        ),
                        const SizedBox(height: 8),
                        Text(mood['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),
            
            // History Section
            const Text('Recent History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 16),

            Consumer<MoodProvider>(
              builder: (context, provider, _) {
                if (provider.entries.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('No history yet. Log your first mood!'),
                  ));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.entries.length,
                  itemBuilder: (context, index) {
                    final entry = provider.entries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: Text(entry.moodEmoji, style: const TextStyle(fontSize: 32)),
                        title: Text('Sleep: ${entry.sleepHours.toStringAsFixed(1)}h | Stress: ${entry.stressLevel}/10'),
                        subtitle: Text('${entry.note ?? "No notes"}\n${_formatDate(entry.createdAt)}'),
                        trailing: Icon(Icons.chevron_right, color: Colors.teal.shade200),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
