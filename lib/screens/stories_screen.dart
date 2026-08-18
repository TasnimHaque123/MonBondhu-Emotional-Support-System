import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final List<Map<String, String>> stories = [
      {
        'titleEn': 'Finding hope in small steps',
        'titleBn': 'ছোট ছোট পদক্ষেপে আশা খুঁজে পাওয়া',
        'contentEn': 'I used to feel overwhelmed by everything. Starting a daily routine helped me regain control over my life. You are not alone.',
        'contentBn': 'আমি আগে সবকিছু নিয়ে খুব দিশেহারা বোধ করতাম। প্রতিদিনের একটি রুটিন শুরু করা আমাকে আমার জীবনের ওপর নিয়ন্ত্রণ ফিরে পেতে সাহায্য করেছে। আপনি একা নন।',
        'authorEn': 'Anonymous',
        'authorBn': 'নাম প্রকাশে অনিচ্ছুক',
        'tagEn': 'Recovery',
        'tagBn': 'সুস্থতা',
      },
      {
        'titleEn': 'The power of talking',
        'titleBn': 'কথা বলার শক্তি',
        'contentEn': 'Opening up to my family about my anxiety was the hardest but best decision I ever made. The support I received was life-changing.',
        'contentBn': 'আমার দুশ্চিন্তা নিয়ে পরিবারের কাছে মুখ খোলা ছিল আমার জীবনের সবচেয়ে কঠিন কিন্তু সেরা সিদ্ধান্ত। আমি যে সমর্থন পেয়েছি তা আমার জীবন বদলে দিয়েছে।',
        'authorEn': 'Anonymous',
        'authorBn': 'নাম প্রকাশে অনিচ্ছুক',
        'tagEn': 'Support',
        'tagBn': 'সমর্থন',
      },
      {
        'titleEn': 'Journaling my way to peace',
        'titleBn': 'ডায়েরি লিখে শান্তি খোঁজা',
        'contentEn': 'Writing down my thoughts every night helps me clear my mind. It’s like talking to a friend who always listens.',
        'contentBn': 'প্রতি রাতে আমার চিন্তাগুলো লিখে রাখা আমার মনকে শান্ত করতে সাহায্য করে। এটি এমন একজন বন্ধুর সাথে কথা বলার মতো যে সবসময় শোনে।',
        'authorEn': 'Anonymous',
        'authorBn': 'নাম প্রকাশে অনিচ্ছুক',
        'tagEn': 'Habit',
        'tagBn': 'অভ্যাস',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('Community Stories', 'কমিউনিটি গল্প')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          langProvider.translate(story['tagEn']!, story['tagBn']!),
                          style: const TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        langProvider.translate(story['authorEn']!, story['authorBn']!),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    langProvider.translate(story['titleEn']!, story['titleBn']!),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    langProvider.translate(story['contentEn']!, story['contentBn']!),
                    style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 20, color: Colors.red[300]),
                      const SizedBox(width: 8),
                      const Text('12', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 20),
                      Icon(Icons.chat_bubble_outline, size: 20, color: Colors.blue[300]),
                      const SizedBox(width: 8),
                      const Text('4', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission feature coming soon!')),
          );
        },
        label: Text(langProvider.translate('Share Your Story', 'আপনার গল্প শেয়ার করুন')),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
