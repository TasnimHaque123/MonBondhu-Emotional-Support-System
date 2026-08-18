import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/journal_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/journal_provider.dart';
import '../providers/risk_provider.dart';

class JournalEditorScreen extends StatefulWidget {
  const JournalEditorScreen({super.key});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedEmoji = '📝';

  final List<String> _emojiOptions = ['😊', '🙂', '😐', '😟', '😢', '😡', '😰', '🤔', '💪', '🙏', '📝'];

  Future<void> _saveEntry() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and content.')),
      );
      return;
    }

    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId == null) return;

    final entry = JournalEntry(
      userId: userId,
      title: title,
      content: content,
      moodEmoji: _selectedEmoji,
    );

    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    final riskProvider = Provider.of<RiskProvider>(context, listen: false);

    await journalProvider.addEntry(entry);
    
    // Trigger AI Risk Analysis on the new journal content
    riskProvider.analyzeNewContent(content, userId);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          TextButton.icon(
            onPressed: _saveEntry,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji mood selector
            const Text(
              'How are you feeling? / তুমি কেমন আছো?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _emojiOptions.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green.shade100 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.green, width: 2)
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title / শিরোনাম',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Content
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Write your thoughts... / তোমার মনের কথা লেখো...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 12,
              textInputAction: TextInputAction.newline,
            ),
          ],
        ),
      ),
    );
  }
}
