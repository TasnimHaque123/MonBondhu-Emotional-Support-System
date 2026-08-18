import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  static const List<Map<String, String>> _hotlines = [
    {
      'name': 'কান পেতে রই (Kaan Pete Roi)',
      'number': '01779-554391',
      'desc': 'Mental health support helpline (Bangla)',
    },
    {
      'name': 'National Mental Health Helpline',
      'number': '16789',
      'desc': 'জাতীয় মানসিক স্বাস্থ্য হেল্পলাইন',
    },
    {
      'name': 'National Emergency',
      'number': '999',
      'desc': 'জরুরি সেবা / Emergency Services',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.health_and_safety, size: 28),
            SizedBox(width: 8),
            Text('Emergency Support'),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calming message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Column(
                children: [
                  Text(
                    '💚 তুমি একা নও। তুমি মূল্যবান।',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '💚 You are not alone. You matter.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'If you or someone you know is in crisis, please reach out to one of the numbers below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'তুমি বা তোমার পরিচিত কেউ সংকটে থাকলে, নিচের যেকোনো নম্বরে কল করো।',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hotlines
            const Text(
              '📞 Emergency Contacts / জরুরি যোগাযোগ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ..._hotlines.map((hotline) => _buildHotlineCard(context, hotline)),

            const SizedBox(height: 24),

            // Breathing exercise
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: const Column(
                children: [
                  Text(
                    '🧘 Breathing Exercise / শ্বাস-প্রশ্বাসের ব্যায়াম',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '1. ৪ সেকেন্ড ধরে শ্বাস নাও (Breathe in for 4 seconds)\n'
                    '2. ৭ সেকেন্ড ধরে রাখো (Hold for 7 seconds)\n'
                    '3. ৮ সেকেন্ড ধরে ছাড়ো (Breathe out for 8 seconds)\n\n'
                    'Repeat 3–4 times. / ৩-৪ বার পুনরায় করো।',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Safety tips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🛡️ Safety Tips / নিরাপত্তা টিপস',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• Talk to someone you trust / বিশ্বস্ত কাউকে বলো\n'
                    '• Go to a safe place / নিরাপদ জায়গায় যাও\n'
                    '• Avoid being alone / একা থেকো না\n'
                    '• Remove harmful items / ক্ষতিকর জিনিস সরিয়ে রাখো\n'
                    '• Visit your nearest doctor / নিকটতম ডাক্তারের কাছে যাও',
                    style: TextStyle(fontSize: 14, height: 1.8),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^\d]'), ''), // Strip non-digits
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Fallback: copy to clipboard
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open dialer. $phoneNumber copied.')),
        );
      }
    }
  }

  Widget _buildHotlineCard(BuildContext context, Map<String, String> hotline) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade400,
          child: const Icon(Icons.phone, color: Colors.white),
        ),
        title: Text(
          hotline['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(hotline['desc']!),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            hotline['number']!,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        onTap: () => _makePhoneCall(context, hotline['number']!),
      ),
    );
  }
}
