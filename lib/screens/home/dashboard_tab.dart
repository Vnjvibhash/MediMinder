import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mediminder/providers/medicine_provider.dart';
import 'package:mediminder/firestore/firestore_data_schema.dart';
import 'package:mediminder/widgets/custom_button.dart';
import 'package:mediminder/widgets/reminder_card.dart';
import 'package:mediminder/widgets/stats_card.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final provider = context.read<MedicineProvider>();
    await provider.loadTodayReminders();
    await provider.loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              // 🔹 Greeting Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good ${_getGreeting()}! 👋',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                ),
                                Text(
                                  user?.displayName ?? 'User',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w100,
                                    color: theme.colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateFormat.format(now),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 12,
                                    color: theme.colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.medication_liquid,
                              size: 32,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Consumer<MedicineProvider>(
                        builder: (context, provider, child) {
                          final todayCount = provider.todayReminders.length;
                          return Row(
                            children: [
                              Expanded(
                                child: _buildQuickStat(
                                  context,
                                  'Today\'s Doses',
                                  '$todayCount',
                                  Icons.today,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildQuickStat(
                                  context,
                                  'Active Reminders',
                                  '${provider.statistics['totalReminders'] ?? 0}',
                                  Icons.alarm,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 🔹 Stats + Charts Section
              Consumer<MedicineProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (provider.error.isNotEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Something went wrong',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.error,
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              onPressed: _refreshData,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'This Week\'s Overview',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Quick Stats Cards
                            Row(
                              children: [
                                Expanded(
                                  child: StatsCard(
                                    title: 'Taken',
                                    value:
                                        '${provider.statistics['dosesTaken'] ?? 0}',
                                    icon: Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StatsCard(
                                    title: 'Missed',
                                    value:
                                        '${provider.statistics['dosesMissed'] ?? 0}',
                                    icon: Icons.cancel,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StatsCard(
                                    title: 'Skipped',
                                    value:
                                        '${provider.statistics['dosesSkipped'] ?? 0}',
                                    icon: Icons.skip_next,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Pie Chart
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 50,
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value:
                                          (provider.statistics['dosesTaken'] ??
                                                  0)
                                              .toDouble(),
                                      title: 'Taken',
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value:
                                          (provider.statistics['dosesMissed'] ??
                                                  0)
                                              .toDouble(),
                                      title: 'Missed',
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: Colors.orange,
                                      value:
                                          (provider.statistics['dosesSkipped'] ??
                                                  0)
                                              .toDouble(),
                                      title: 'Skipped',
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Weekly Bar Chart
                            Text(
                              "Weekly Trend",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final days = [
                                            'M',
                                            'T',
                                            'W',
                                            'T',
                                            'F',
                                            'S',
                                            'S',
                                          ];
                                          return Text(days[value.toInt() % 7]);
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false),
                                  barGroups: List.generate(7, (i) {
                                    final taken =
                                        (provider.statistics['day${i}_taken'] ??
                                                0)
                                            .toDouble();
                                    final missed =
                                        (provider.statistics['day${i}_missed'] ??
                                                0)
                                            .toDouble();

                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: taken,
                                          color: Colors.green,
                                          width: 8,
                                        ),
                                        BarChartRodData(
                                          toY: missed,
                                          color: Colors.red,
                                          width: 8,
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 🔹 Today's Reminders
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Icon(
                              Icons.today_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Today\'s Medications',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (provider.todayReminders.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.celebration_outlined,
                                size: 64,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'All clear for today! 🎉',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No medications scheduled for today.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ...provider.todayReminders.map((reminder) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 6,
                            ),
                            child: ReminderCard(
                              reminder: reminder,
                              onMarkTaken: () =>
                                  _markDose(reminder, DoseStatus.taken),
                              onMarkSkipped: () =>
                                  _markDose(reminder, DoseStatus.skipped),
                            ),
                          );
                        }),
                      const SizedBox(height: 32),
                    ]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.8,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 3 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 22) return 'Evening';
    return 'Night';
  }

  Future<void> _markDose(MedicineReminder reminder, DoseStatus status) async {
    try {
      await context.read<MedicineProvider>().recordDose(reminder, status);
      if (mounted) {
        final statusText = status == DoseStatus.taken ? 'taken' : 'skipped';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reminder.medicine} marked as $statusText'),
            backgroundColor: status == DoseStatus.taken
                ? Colors.green
                : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
