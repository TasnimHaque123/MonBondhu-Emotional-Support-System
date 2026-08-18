import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/badge_provider.dart';
import '../providers/language_provider.dart';
import '../providers/prediction_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _conditionController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController.text = user?.username ?? '';
    _conditionController.text = user?.condition ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final moodProvider = Provider.of<MoodProvider>(context);
    final badgeProvider = Provider.of<BadgeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final predictionProvider = Provider.of<PredictionProvider>(context);

    // Prepare heatmap data from mood entries
    Map<DateTime, int> datasets = {};
    for (var entry in moodProvider.entries) {
      final date = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      datasets[date] = (datasets[date] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('My Profile', 'আমার প্রোফাইল')),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (_isEditing) {
                await authProvider.updateProfile(
                  username: _nameController.text,
                  condition: _conditionController.text,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        langProvider.translate(
                          'Profile Updated',
                          'প্রোফাইল আপডেট করা হয়েছে',
                        ),
                      ),
                    ),
                  );
                }
              }
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.teal.shade100,
                    backgroundImage: user?.profilePicture != null
                        ? NetworkImage(user!.profilePicture!)
                        : null,
                    child: user?.profilePicture == null
                        ? const Icon(Icons.person, size: 50, color: Colors.teal)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.teal,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Implement image picker
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: langProvider.translate('Name', 'নাম'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _conditionController,
                decoration: InputDecoration(
                  labelText: langProvider.translate(
                    'Condition/Status',
                    'অবস্থা/স্ট্যাটাস',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'e.g. Feeling better, Recovering...',
                ),
              ),
            ] else ...[
              Text(
                user?.username ?? 'Bondhu',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (user?.condition != null && user!.condition!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    user.condition!,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ),
            ],
            const SizedBox(height: 32),

            // Active Status (Heatmap)
            _buildSectionTitle(
              langProvider.translate('Activity History', 'অ্যাক্টিভিটি ইতিহাস'),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: HeatMap(
                  datasets: datasets,
                  colorMode: ColorMode.opacity,
                  showText: false,
                  scrollable: true,
                  colorsets: {
                    1: Colors.teal.shade200,
                    2: Colors.teal.shade400,
                    3: Colors.teal.shade600,
                    4: Colors.teal.shade800,
                    5: Colors.teal.shade900,
                  },
                  onClick: (value) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(value.toString())));
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Condition History (Summary from AI)
            _buildSectionTitle(
              langProvider.translate('Health Summary', 'স্বাস্থ্য সারসংক্ষেপ'),
            ),
            const SizedBox(height: 8),
            _buildSummaryTile(
              Icons.analytics,
              langProvider.translate('Current State', 'বর্তমান অবস্থা'),
              predictionProvider.latestPrediction?.level ?? 'No Data',
              _getRiskColor(predictionProvider.latestPrediction?.level),
            ),
            const SizedBox(height: 16),

            // Badges
            _buildSectionTitle(
              langProvider.translate('Unlocked Badges', 'আনলক করা ব্যাজ'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: badgeProvider.unlockedBadges.length,
                itemBuilder: (context, index) {
                  final badge = badgeProvider.unlockedBadges[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: badge.color.withValues(alpha: 0.1),
                          child: Icon(badge.icon, color: badge.color),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          langProvider.translate(badge.nameEn, badge.nameBn),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (badgeProvider.unlockedBadges.isEmpty)
              Text(
                langProvider.translate(
                  'No badges earned yet.',
                  'এখনো কোনো ব্যাজ অর্জিত হয়নি।',
                ),
              ),

            const SizedBox(height: 24),

            // Quiz Result (Last Score)
            _buildSectionTitle(
              langProvider.translate('Quiz History', 'কুইজ ইতিহাস'),
            ),
            const SizedBox(height: 8),
            _buildSummaryTile(
              Icons.quiz,
              langProvider.translate('Latest Quiz', 'সর্বশেষ কুইজ'),
              'Expert Badge Earned', // Since we don't persist scores yet, we show badge status
              Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryTile(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String? level) {
    switch (level?.toLowerCase()) {
      case 'severe':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'mild':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}
