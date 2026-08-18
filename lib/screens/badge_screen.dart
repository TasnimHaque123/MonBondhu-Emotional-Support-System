import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/badge_provider.dart';

class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final badgeProvider = Provider.of<BadgeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('Your Achievements', 'আপনার অর্জনসমূহ')),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.85,
        ),
        itemCount: badgeProvider.badges.length,
        itemBuilder: (context, index) {
          final badge = badgeProvider.badges[index];
          return Opacity(
            opacity: badge.isUnlocked ? 1.0 : 0.3,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: badge.isUnlocked ? 4 : 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: badge.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(badge.icon, color: badge.color, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      langProvider.translate(badge.nameEn, badge.nameBn),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      langProvider.translate(badge.descriptionEn, badge.descriptionBn),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    if (!badge.isUnlocked)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
