import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/journal_provider.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
      if (userId != null) {
        Provider.of<JournalProvider>(context, listen: false).loadEntries(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.book, size: 28),
            SizedBox(width: 8),
            Text('My Journal'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Privacy note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: const Text(
              '🔒 All entries are stored offline on your device only.\n'
              '🔒 সব এন্ট্রি শুধু তোমার ফোনে সংরক্ষিত।',
              style: TextStyle(fontSize: 13, color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: Consumer<JournalProvider>(
              builder: (context, provider, _) {
                final entries = provider.entries;

                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No journal entries yet.\nতোমার মনের কথা লেখো...',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Text(
                          entry.moodEmoji ?? '📝',
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          entry.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${entry.content.length > 60 ? entry.content.substring(0, 60) : entry.content}...\n'
                          '${_formatDate(entry.createdAt)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDelete(entry.id!),
                        ),
                        onTap: () => _viewEntry(entry),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/journal_editor'),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _viewEntry(dynamic entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(entry.moodEmoji ?? '📝', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(entry.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(entry.content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<JournalProvider>(context, listen: false).deleteEntry(id, userId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
