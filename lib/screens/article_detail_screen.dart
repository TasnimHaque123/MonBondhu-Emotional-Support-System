import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final content = _getArticleContent(articleId, langProvider);

    return Scaffold(
      appBar: AppBar(title: Text(content['title'] ?? '')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (content['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  content['imageUrl']!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              content['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              langProvider.translate('Mental Health Series', 'মানসিক স্বাস্থ্য সিরিজ'),
              style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.w500),
            ),
            const Divider(height: 32),
            Text(
              content['body'] ?? '',
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 32),
            _buildTipsSection(content['tips'] as List<String>?, langProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection(List<String>? tips, LanguageProvider lp) {
    if (tips == null || tips.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lp.translate('Quick Tips:', 'দ্রুত টিপস:'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(tip, style: const TextStyle(fontSize: 15))),
                ],
              ),
            )),
      ],
    );
  }

  Map<String, dynamic> _getArticleContent(String id, LanguageProvider lp) {
    switch (id) {
      case 'anxiety':
        return {
          'title': lp.translate('Managing Anxiety', 'দুশ্চিন্তা ব্যবস্থাপনা'),
          'imageUrl': 'https://images.unsplash.com/photo-1474418397713-7ded61d96e18?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          'body': lp.translate(
            'Anxiety is a natural response to stress, but when it becomes overwhelming, it can interfere with daily life. Common signs include racing heart, worrying thoughts, and restlessness.',
            'দুশ্চিন্তা হলো চাপের বিরুদ্ধে একটি স্বাভাবিক প্রতিক্রিয়া, তবে যখন এটি অত্যধিক হয়ে যায়, তখন এটি দৈনন্দিন জীবনে বাধা সৃষ্টি করতে পারে। সাধারণ লক্ষণগুলোর মধ্যে রয়েছে দ্রুত হৃদস্পন্দন, অস্থির চিন্তা এবং অস্থিরতা।'
          ),
          'tips': lp.translate(
            ['Practice deep breathing', 'Limit caffeine intake', 'Write your worries down', 'Focus on the present moment'],
            ['গভীর শ্বাস-প্রশ্বাসের অভ্যাস করুন', 'ক্যাফেইন বা চা-কফি পানের পরিমাণ কমান', 'আপনার দুশ্চিন্তাগুলো ডায়েরিতে লিখুন', 'বর্তমান মুহূর্তের ওপর মনোযোগ দিন']
          ),
        };
      case 'depression':
        return {
          'title': lp.translate('Understanding Depression', 'বিষণ্ণতা বোঝা'),
          'imageUrl': 'https://images.unsplash.com/photo-1516589174184-c68d196f454e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          'body': lp.translate(
            'Depression is more than just feeling sad. It is a persistent feeling of hopelessness, loss of interest, and physical fatigue. It is a treatable medical condition, not a sign of weakness.',
            'বিষণ্ণতা শুধু মন খারাপের চেয়েও বেশি কিছু। এটি হলো আশাহীনতার একটি স্থায়ী অনুভূতি, কাজের প্রতি আগ্রহ হারানো এবং শারীরিক ক্লান্তি। এটি একটি চিকিৎসাযোগ্য রোগ, দুর্বলতার কোনো লক্ষণ নয়।'
          ),
          'tips': lp.translate(
            ['Stay connected with loved ones', 'Set small, achievable goals', 'Maintain a sleep routine', 'Seek professional help'],
            ['প্রিয়জনদের সাথে যোগাযোগ রাখুন', 'ছোট ছোট এবং অর্জনযোগ্য লক্ষ্য নির্ধারণ করুন', 'ঘুমের একটি রুটিন মেনে চলুন', 'পেশাদার সাহায্য নিন']
          ),
        };
      case 'stress':
        return {
          'title': lp.translate('Stress Coping Tips', 'মানসিক চাপ কমানোর উপায়'),
          'imageUrl': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          'body': lp.translate(
            'Stress is unavoidable, but how we react to it makes the difference. Chronic stress can lead to health problems, so learning to cope is essential for long-term wellness.',
            'মানসিক চাপ অনিবার্য, তবে আমরা কীভাবে এর প্রতিক্রিয়া জানাই সেটিই আসল পার্থক্য তৈরি করে। দীর্ঘস্থায়ী মানসিক চাপ স্বাস্থ্য সমস্যা তৈরি করতে পারে, তাই দীর্ঘমেয়াদী সুস্থতার জন্য চাপ সামলানো শেখা জরুরি।'
          ),
          'tips': lp.translate(
            ['Exercise regularly', 'Listen to calming music', 'Take short breaks often', 'Eat a balanced diet'],
            ['নিয়মিত ব্যায়াম করুন', 'শান্ত সংগীত শুনুন', 'কাজের মাঝে মাঝে ছোট বিরতি নিন', 'সুষম খাবার খান']
          ),
        };
      default:
        return {'title': 'Article Not Found', 'body': 'Coming soon...'};
    }
  }
}
