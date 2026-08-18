
import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// Correct imports for Badge
import '../providers/badge_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/journal_provider.dart';
import '../providers/risk_provider.dart';
import '../providers/prediction_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../models/routine.dart';
import '../models/prediction.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingBn() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'শুভ সকাল';
    if (hour < 17) return 'শুভ দুপুর';
    return 'শুভ সন্ধ্যা';
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final moodProvider = Provider.of<MoodProvider>(context);
    final journalProvider = Provider.of<JournalProvider>(context);
    final predictionProvider = Provider.of<PredictionProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final lastMood = moodProvider.entries.isNotEmpty
        ? moodProvider.entries.first
        : null;
    final username = user?.username ?? 'Bondhu';

    // Auto-check badges after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndUnlockBadges(context);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
              errorBuilder: (_, _, _) => const Icon(Icons.health_and_safety),
            ),
            const SizedBox(width: 10),
            Text(
              langProvider.translate('MonBondhu', 'মনবন্ধু'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: langProvider.translate(
              'Switch Language',
              'ভাষা পরিবর্তন করুন',
            ),
            onPressed: () => langProvider.toggleLanguage(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      langProvider.translate(_getGreeting(), _getGreetingBn()),
                      style: TextStyle(fontSize: 16, color: Colors.teal[700]),
                    ),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: Hero(
                    tag: 'profile_pic',
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal.shade100,
                      backgroundImage: user?.profilePicture != null
                          ? NetworkImage(user!.profilePicture!)
                          : null,
                      child: user?.profilePicture == null
                          ? const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.teal,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: const Icon(Icons.edit, size: 16),
              label: Text(
                langProvider.translate('Edit Profile', 'প্রোফাইল এডিট করুন'),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),

            // Daily Motivation Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.teal[300]!],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Affirmation',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '"You are doing your best, and that is enough."',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.format_quote, color: Colors.white24, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Section
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Last Mood',
                    lastMood?.moodEmoji ?? '❓',
                    'Recorded recently',
                    Colors.orange,
                    '/mood',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Journals',
                    '${journalProvider.entries.length}',
                    'Total entries',
                    Colors.green,
                    '/journal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              langProvider.translate('Explore Modules', 'মডিউলগুলো দেখুন'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // AI Wellness Dashboard
            _buildAiWellnessDashboard(
              context,
              predictionProvider,
              moodProvider,
            ),
            const SizedBox(height: 16),

            // Grid Modules
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildGridModule(
                  context,
                  Icons.analytics,
                  langProvider.translate('Insight Panel', 'ইনসাইট প্যানেল'),
                  Colors.teal,
                  '/insights',
                ),
                _buildGridModule(
                  context,
                  Icons.self_improvement,
                  langProvider.translate(
                    'Guided Exercises',
                    'নির্দেশিত ব্যায়াম',
                  ),
                  Colors.indigo,
                  '/exercise',
                ),
                _buildGridModule(
                  context,
                  Icons.calendar_today,
                  langProvider.translate('Daily Routine', 'দৈনন্দিন রুটিন'),
                  Colors.orange,
                  '/routine',
                ),
                _buildGridModule(
                  context,
                  Icons.chat,
                  langProvider.translate('AI Support', 'এআই সহায়তা'),
                  Colors.blue,
                  '/chat',
                ),
                _buildGridModule(
                  context,
                  Icons.book,
                  langProvider.translate('My Journal', 'আমার ডায়েরি'),
                  Colors.green,
                  '/journal',
                ),
                _buildGridModule(
                  context,
                  Icons.mood,
                  langProvider.translate('Mood Tracker', 'মুড ট্র্যাকার'),
                  Colors.amber,
                  '/mood',
                ),
                _buildGridModule(
                  context,
                  Icons.local_hospital,
                  langProvider.translate('Find Doctors', 'ডাক্তার খুঁজুন'),
                  Colors.purple,
                  '/doctor',
                ),
                _buildGridModule(
                  context,
                  Icons.warning,
                  langProvider.translate('Emergency', 'জরুরি অবস্থা'),
                  Colors.red,
                  '/emergency',
                ),
                _buildGridModule(
                  context,
                  Icons.school,
                  langProvider.translate('Learning', 'শিক্ষা'),
                  Colors.blueGrey,
                  '/learning',
                ),
                _buildGridModule(
                  context,
                  Icons.quiz,
                  langProvider.translate('Daily Quiz', 'দৈনিক কুইজ'),
                  Colors.teal,
                  '/quiz',
                ),
                _buildGridModule(
                  context,
                  Icons.people,
                  langProvider.translate('Community', 'কমিউনিটি'),
                  Colors.blue,
                  '/stories',
                ),
                _buildGridModule(
                  context,
                  Icons.emoji_events,
                  langProvider.translate('Badges', 'ব্যাজ'),
                  Colors.orange,
                  '/badges',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== BADGE CHECKING LOGIC =====================
  void _checkAndUnlockBadges(BuildContext context) {
    final badgeProvider = Provider.of<BadgeProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(
      context,
      listen: false,
    );
    final routineProvider = Provider.of<RoutineProvider>(
      context,
      listen: false,
    );

    final moodDates = moodProvider.entries.map((e) => e.createdAt).toList();
    final completedRoutines = routineProvider.routines
        .where((r) => r.isCompleted)
        .length;

    // Check which badges were newly unlocked
    final previouslyUnlocked = badgeProvider.unlockedBadges
        .map((b) => b.id)
        .toSet();

    badgeProvider.checkAndUnlockBadges(
      totalJournals: journalProvider.entries.length,
      totalRoutinesCompleted: completedRoutines,
      moodDates: moodDates,
    );

    // Show popup for newly unlocked badges
    final newlyUnlocked = badgeProvider.unlockedBadges.where(
      (b) => !previouslyUnlocked.contains(b.id),
    );

    for (var badge in newlyUnlocked) {
      _showBadgeUnlockedDialog(context, badge);
    }
  }

  void _showBadgeUnlockedDialog(BuildContext context, Badge badge) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 32),
            SizedBox(width: 8),
            Text(
              '🎉 New Badge Unlocked!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: badge.color.withValues(alpha: 0.12), // Fixed
                shape: BoxShape.circle,
              ),
              child: Icon(badge.icon, color: badge.color, size: 68),
            ),
            const SizedBox(height: 20),
            Text(
              badge.nameEn,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              badge.nameBn,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              badge.descriptionEn,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Awesome! 🎉', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSummaryCard(
  BuildContext context,
  String title,
  String value,
  String subtitle,
  Color color,
  String route,
) {
  return InkWell(
    onTap: () => Navigator.of(context).pushNamed(route),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

Widget _buildAiWellnessDashboard(
  BuildContext context,
  PredictionProvider predictionProvider,
  MoodProvider moodProvider,
) {
  final DepressionPrediction? prediction = predictionProvider.latestPrediction;
  final riskProvider = Provider.of<RiskProvider>(context);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.teal.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      border: Border.all(color: Colors.teal.withValues(alpha: 0.1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome, color: Colors.teal, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Wellness Panel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'এআই স্বাস্থ্য প্যানেল',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (predictionProvider.isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
                onPressed: () {
                  final user = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).currentUser;
                  if (user != null) {
                    predictionProvider.runPrediction(
                      userId: user.id!,
                      moods: moodProvider.entries,
                      journalCount: Provider.of<JournalProvider>(
                        context,
                        listen: false,
                      ).entries.length,
                      latestJournalContent:
                          Provider.of<JournalProvider>(
                            context,
                            listen: false,
                          ).entries.isEmpty
                          ? ""
                          : Provider.of<JournalProvider>(
                              context,
                              listen: false,
                            ).entries.first.content,
                    );
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (prediction == null)
          Center(
            child: Column(
              children: [
                const Text(
                  'No AI analysis available yet.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    final user = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).currentUser;
                    if (user != null) {
                      predictionProvider.runPrediction(
                        userId: user.id!,
                        moods: moodProvider.entries,
                        journalCount: Provider.of<JournalProvider>(
                          context,
                          listen: false,
                        ).entries.length,
                        latestJournalContent:
                            Provider.of<JournalProvider>(
                              context,
                              listen: false,
                            ).entries.isEmpty
                            ? ""
                            : Provider.of<JournalProvider>(
                                context,
                                listen: false,
                              ).entries.first.content,
                      );
                    }
                  },
                  child: const Text('Analyze My Wellness Now'),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusChip(
                    prediction.level,
                    _getRiskColor(prediction.level),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Confidence: ${(prediction.confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                prediction.summary,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _buildSmallMoodChart(moodProvider),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Text(
                    'Your Recovery Plan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '(আপনার পুনরুদ্ধার পরিকল্পনা)',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...prediction.suggestions
                  .take(3)
                  .map((s) => _buildSuggestionItem(context, s)),
              if (prediction.level == 'Severe' ||
                  riskProvider.currentLevel == RiskLevel.high)
                _buildEmergencyAction(context),
            ],
          ),
      ],
    ),
  );
}

Widget _buildStatusChip(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
    ),
  );
}

Widget _buildSuggestionItem(BuildContext context, String suggestion) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Icon(Icons.check_circle_outline, color: Colors.teal[300], size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            suggestion,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        InkWell(
          onTap: () {
            final user = Provider.of<AuthProvider>(
              context,
              listen: false,
            ).currentUser;
            if (user != null) {
              Provider.of<RoutineProvider>(context, listen: false).addRoutine(
                Routine(userId: user.id!, title: suggestion, type: 'TASK'),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added to your Daily Routine: $suggestion'),
                ),
              );
            }
          },
          child: Icon(
            Icons.add_circle_outline,
            color: Colors.teal[100],
            size: 20,
          ),
        ),
      ],
    ),
  );
}

Widget _buildEmergencyAction(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red[100]!),
    ),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.red),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Severe distress detected. Please seek professional help.',
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/emergency'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('HELP'),
        ),
      ],
    ),
  );
}

Widget _buildSmallMoodChart(MoodProvider provider) {
  final trend = provider.weeklyTrend;
  if (trend.isEmpty) return const SizedBox.shrink();

  final spots = trend.entries.toList().asMap().entries.map((e) {
    return FlSpot(e.key.toDouble(), e.value.value);
  }).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Weekly Trend (সাপ্তাহিক প্রবণতা)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 80,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.teal,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.teal.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Color _getRiskColor(String level) {
  switch (level.toLowerCase()) {
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

Widget _buildGridModule(
  BuildContext context,
  IconData icon,
  String title,
  Color color,
  String? route,
) {
  return InkWell(
    onTap: route != null ? () => Navigator.of(context).pushNamed(route) : null,
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    ),
  );
}
