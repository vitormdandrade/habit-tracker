import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'habit_model.dart';

class StatsScreen extends StatelessWidget {
  final HabitTracker tracker;

  const StatsScreen({super.key, required this.tracker});

  @override
  Widget build(BuildContext context) {
    final daysSinceStart = tracker.startDate != null 
        ? DateTime.now().difference(tracker.startDate!).inDays + 1
        : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 18,
            fontFamily: 'Aleo',
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tier Section
            _buildTierSection(context),
            const SizedBox(height: 24),
            // Achievements Section
            _AchievementsSection(tracker: tracker),
            const SizedBox(height: 24),
            // Overview Stats
            _buildOverviewCard(context, daysSinceStart),
            const SizedBox(height: 24),
            // Streak Chart
            _buildChartCard(
              context,
              'Daily Streak Progress',
              _buildStreakChart(context),
            ),
            const SizedBox(height: 24),
            // Points Chart
            _buildChartCard(
              context,
              'Daily Points Progress',
              _buildPointsChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierSection(BuildContext context) {
    final tier = tracker.tierName;
    final points = tracker.tierPoints;
    final min = tracker.tierMin;
    final max = tracker.tierMax;
    final progress = tracker.tierProgress.clamp(0.0, 1.0);
    final nextTier = _nextTierName(tier);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.tealAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.tealAccent, size: 28),
              const SizedBox(width: 10),
              Text(
                'Tier: $tier',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  fontFamily: 'Aleo',
                ),
              ),
              const Spacer(),
              Text(
                '$points TP',
                style: const TextStyle(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Aleo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.tealAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    nextTier != null
                        ? '$points / $max TP  (Next: $nextTier)'
                        : '$points TP',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      fontFamily: 'Aleo',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _nextTierName(String current) {
    const tiers = [
      'Newbie', 'Novice', 'Challenger', 'Pro', 'Expert', 'Master', 'Grand Master', 'Hall of Fame'
    ];
    final idx = tiers.indexOf(current);
    if (idx >= 0 && idx < tiers.length - 1) return tiers[idx + 1];
    return null;
  }

  Widget _buildOverviewCard(BuildContext context, int daysSinceStart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Days Since Start',
                  daysSinceStart.toString(),
                  '📅',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Maximum Streak',
                  tracker.maxStreak.toString(),
                  '🔥',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Current Streak',
                  tracker.streak.toString(),
                  '⚡',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total Points',
                  tracker.points.toString(),
                  '⭐',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Aleo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'Aleo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, String title, Widget chart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: chart,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakChart(BuildContext context) {
    if (tracker.dailyStats.isEmpty) {
      return const Center(
        child: Text(
          'No data available yet.\nStart tracking your habits to see progress!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'Aleo',
          ),
        ),
      );
    }

    final spots = tracker.dailyStats.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.streak.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: tracker.dailyStats.length > 10 ? (tracker.dailyStats.length / 5).ceil().toDouble() : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= tracker.dailyStats.length) return const Text('');
                return Text(
                  'Day ${index + 1}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontFamily: 'Aleo',
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontFamily: 'Aleo',
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.tealAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.tealAccent,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.tealAccent.withOpacity(0.2),
            ),
          ),
        ],
        minX: 0,
        maxX: (tracker.dailyStats.length - 1).toDouble(),
        minY: 0,
        maxY: (tracker.maxStreak > 0 ? tracker.maxStreak : 10).toDouble(),
      ),
    );
  }

  Widget _buildPointsChart(BuildContext context) {
    if (tracker.dailyStats.isEmpty) {
      return const Center(
        child: Text(
          'No data available yet.\nStart tracking your habits to see progress!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'Aleo',
          ),
        ),
      );
    }

    final spots = tracker.dailyStats.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.points.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: tracker.points > 20 ? (tracker.points / 5).ceil().toDouble() : 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: tracker.dailyStats.length > 10 ? (tracker.dailyStats.length / 5).ceil().toDouble() : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= tracker.dailyStats.length) return const Text('');
                return Text(
                  'Day ${index + 1}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontFamily: 'Aleo',
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontFamily: 'Aleo',
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.deepPurpleAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.deepPurpleAccent,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.deepPurpleAccent.withOpacity(0.2),
            ),
          ),
        ],
        minX: 0,
        maxX: (tracker.dailyStats.length - 1).toDouble(),
        minY: 0,
        maxY: (tracker.points > 0 ? tracker.points : 10).toDouble(),
      ),
    );
  }
} 

class _AchievementsSection extends StatefulWidget {
  final HabitTracker tracker;
  const _AchievementsSection({required this.tracker});
  @override
  State<_AchievementsSection> createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends State<_AchievementsSection> {
  bool _showAll = false;
  @override
  Widget build(BuildContext context) {
    final achievements = widget.tracker.achievements;
    final done = achievements.where((a) => a.achieved).toList();
    final notDone = achievements.where((a) => !a.achieved).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                fontFamily: 'Aleo',
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(_showAll ? Icons.expand_less : Icons.expand_more, color: Colors.tealAccent),
              onPressed: () => setState(() => _showAll = !_showAll),
              tooltip: _showAll ? 'Hide Achievements' : 'Show Achievements',
            ),
          ],
        ),
        if (_showAll) ...[
          const SizedBox(height: 8),
          ...done.map((a) => _buildAchievementTile(a, true)),
          if (done.isNotEmpty && notDone.isNotEmpty) const Divider(color: Colors.white24, height: 24),
          ...notDone.map((a) => _buildAchievementTile(a, false)),
        ],
      ],
    );
  }

  Widget _buildAchievementTile(Achievement a, bool done) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: done ? Colors.teal.withOpacity(0.18) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: done ? Colors.tealAccent : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.emoji_events : Icons.emoji_events_outlined,
            color: done ? Colors.tealAccent : Colors.white54,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: TextStyle(
                    color: done ? Colors.tealAccent : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: 'Aleo',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  a.description,
                  style: TextStyle(
                    color: done ? Colors.white70 : Colors.white38,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    fontFamily: 'Aleo',
                  ),
                ),
              ],
            ),
          ),
          if (done)
            const Icon(Icons.check_circle, color: Colors.tealAccent, size: 20),
        ],
      ),
    );
  }
} 