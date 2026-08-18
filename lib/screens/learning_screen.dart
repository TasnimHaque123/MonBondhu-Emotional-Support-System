import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'article_detail_screen.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('Learning Center', 'শিক্ষা কেন্দ্র')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryHeader(langProvider.translate('Popular Topics', 'জনপ্রিয় বিষয়')),
          _buildArticleCard(
            context,
            langProvider.translate('Managing Anxiety', 'দুশ্চিন্তা ব্যবস্থাপনা'),
            langProvider.translate('Learn how to control racing thoughts.', 'অস্থির চিন্তা নিয়ন্ত্রণ করতে শিখুন।'),
            'anxiety',
            Colors.blue,
          ),
          _buildArticleCard(
            context,
            langProvider.translate('Understanding Depression', 'বিষণ্ণতা বোঝা'),
            langProvider.translate('Signs, symptoms, and when to seek help.', 'লক্ষণসমূহ এবং কখন সাহায্য নিতে হবে।'),
            'depression',
            Colors.deepPurple,
          ),
          _buildArticleCard(
            context,
            langProvider.translate('Stress Coping Tips', 'মানসিক চাপ কমানোর উপায়'),
            langProvider.translate('Simple daily habits for a calmer life.', 'শান্ত জীবনের জন্য সহজ কিছু দৈনন্দিন অভ্যাস।'),
            'stress',
            Colors.orange,
          ),
          const SizedBox(height: 24),
          _buildCategoryHeader(langProvider.translate('Video Resources', 'ভিডিও রিসোর্স')),
          _buildVideoPlaceholder(
            context,
            langProvider.translate('Meditation for Beginners', 'নতুনদের জন্য মেডিটেশন'),
            '5 mins',
          ),
          _buildVideoPlaceholder(
            context,
            langProvider.translate('Dealing with Panic Attacks', 'প্যানিক অ্যাটাক মোকাবিলা'),
            '8 mins',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, String title, String snippet, String id, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.article, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(snippet),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ArticleDetailScreen(articleId: id)),
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder(BuildContext context, String title, String duration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1506126613408-eca07ce68773?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'),
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50)),
          ),
          ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: Text(duration, style: const TextStyle(color: Colors.grey)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video playback requires internet connection.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
