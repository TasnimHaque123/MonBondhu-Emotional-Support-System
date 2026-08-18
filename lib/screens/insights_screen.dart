import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/mood_provider.dart';
import '../providers/journal_provider.dart';
import '../providers/risk_provider.dart';
import '../providers/insights_provider.dart';
import '../providers/prediction_provider.dart';
import '../providers/auth_provider.dart';
import '../models/risk_history.dart';
import '../models/prediction.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;

    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    final riskProvider = Provider.of<RiskProvider>(context, listen: false);
    final insightsProvider = Provider.of<InsightsProvider>(context, listen: false);
    final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);

    riskProvider.loadHistory(user.id!);
    predictionProvider.loadLatestPrediction(user.id!);
    insightsProvider.generateWeeklyInsights(
      moodProvider.entries,
      journalProvider.entries.length,
      riskProvider.currentRisk,
    );
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final riskProvider = Provider.of<RiskProvider>(context);
    final insightsProvider = Provider.of<InsightsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('MonBondhu Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.teal,
          tabs: const [
            Tab(text: 'Trends', icon: Icon(Icons.show_chart)),
            Tab(text: 'Timeline', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrendsTab(moodProvider, insightsProvider),
          _buildTimelineTab(riskProvider),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(MoodProvider moodProvider, InsightsProvider insightsProvider) {
    final predictionProvider = Provider.of<PredictionProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPredictionCard(predictionProvider, moodProvider),
          const SizedBox(height: 16),
          _buildAIInsightCard(insightsProvider),
          const SizedBox(height: 24),
          
          const Text('Mood & Stress Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 12),
          _buildMultiChart(moodProvider),
          
          const SizedBox(height: 24),
          const Text('Sleep Quality (Weekly)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 12),
          _buildSleepChart(moodProvider),
          
          const SizedBox(height: 24),
          _buildStatRow(moodProvider),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(RiskProvider riskProvider) {
    final predictionProvider = Provider.of<PredictionProvider>(context);
    
    // Combine both types of history and sort by date
    final combinedHistory = [
      ...riskProvider.history.map((e) => {'type': 'risk', 'data': e, 'date': e.createdAt}),
      ...predictionProvider.history.map((e) => {'type': 'prediction', 'data': e, 'date': e.createdAt}),
    ];
    
    combinedHistory.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    if (combinedHistory.isEmpty) {
      return const Center(child: Text('No wellness history available yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: combinedHistory.length,
      itemBuilder: (context, index) {
        final item = combinedHistory[index];
        if (item['type'] == 'risk') {
          return _buildTimelineItem(item['data'] as RiskHistory);
        } else {
          return _buildPredictionTimelineItem(item['data'] as DepressionPrediction);
        }
      },
    );
  }

  Widget _buildPredictionTimelineItem(DepressionPrediction prediction) {
    final color = _getRiskColor(prediction.level);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('PREDICTION', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(prediction.level, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(_formatDate(prediction.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(prediction.summary, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text('Recovery Suggestions:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          ...prediction.suggestions.take(2).map((s) => Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('• $s', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          )),
        ],
      ),
    );
  }

  Color _getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'severe': return Colors.red;
      case 'moderate': return Colors.orange;
      case 'mild': return Colors.blue;
      default: return Colors.green;
    }
  }
  Widget _buildAIInsightCard(InsightsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        border: Border.all(color: Colors.teal.shade50, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.teal.shade400, size: 24),
              const SizedBox(width: 8),
              const Text('Personalized Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(provider.aiInsight, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildMultiChart(MoodProvider provider) {
    final trend = provider.weeklyTrend;
    if (trend.isEmpty) return const SizedBox(height: 200, child: Center(child: Text("Not enough data")));

    final moodSpots = trend.entries.toList().asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList();
    
    // Simulate stress spots (inversely proportional to mood for demo if no data)
    final stressSpots = provider.entries.take(7).toList().asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.stressLevel / 2)).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: true, rightTitles: AxisTitles(), topTitles: AxisTitles()),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(spots: moodSpots, color: Colors.teal, barWidth: 4, isCurved: true, dotData: const FlDotData(show: true)),
            LineChartBarData(spots: stressSpots, color: Colors.red.withValues(alpha: 0.5), barWidth: 2, isCurved: true, dashArray: [5, 5]),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChart(MoodProvider provider) {
    final sleepData = provider.entries.take(7).toList();
    if (sleepData.isEmpty) return const SizedBox(height: 150, child: Center(child: Text("Log your sleep to see trends")));

    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          barGroups: sleepData.asMap().entries.map((e) {
            return BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.sleepHours, color: Colors.indigo, width: 12, borderRadius: BorderRadius.circular(4))]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatRow(MoodProvider provider) {
    final avgSleep = provider.entries.isEmpty ? 0 : provider.entries.map((e) => e.sleepHours).reduce((a, b) => a + b) / provider.entries.length;
    return Row(
      children: [
        _statItem('Avg Sleep', '${avgSleep.toStringAsFixed(1)}h', Icons.nightlight_round, Colors.indigo),
        const SizedBox(width: 12),
        _statItem('Stress Avg', 'Low', Icons.speed, Colors.orange),
      ],
    );
  }

  Widget _buildPredictionCard(PredictionProvider provider, MoodProvider moodProvider) {
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final prediction = provider.latestPrediction;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade400, Colors.blue.shade600]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Text('Depression Risk Prediction', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (prediction == null)
            const Text('No recent prediction. Log your daily wellness to see results.', style: TextStyle(color: Colors.white70, fontSize: 13))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level: ${prediction.level}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Conf: ${(prediction.confidence * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(prediction.summary, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 12),
                const Text('Suggestions:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ...prediction.suggestions.take(3).map((s) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Expanded(child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12))),
                    ],
                  ),
                )),
              ],
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: provider.isLoading
                  ? null
                  : () => provider.runPrediction(
                        userId: user!.id!,
                        moods: moodProvider.entries,
                        journalCount: journalProvider.entries.length,
                        latestJournalContent: journalProvider.entries.isEmpty ? "" : journalProvider.entries.first.content,
                      ),
              child: provider.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) : const Text('Run Daily Prediction'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(RiskHistory item) {
    final color = item.level.contains('HIGH') ? Colors.red : (item.level.contains('MODERATE') ? Colors.orange : Colors.green);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border(left: BorderSide(color: color, width: 4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.level, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(_formatDate(item.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.reason, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, "0")}';
  }
}
