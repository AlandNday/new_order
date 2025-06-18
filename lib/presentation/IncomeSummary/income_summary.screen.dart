import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // For formatting currency

import 'controllers/income_summary.controller.dart';

class IncomeSummaryScreen extends GetView<IncomeSummaryController> {
  const IncomeSummaryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Initialize the controller. GetX will dispose of it automatically.
    final IncomeSummaryController controller = Get.put(
      IncomeSummaryController(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Income Summary'),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Income Summaries Section
            buildSummaryCard(
              title: 'Pendapatan Hari Ini',
              icon: Icons.calendar_today,
              color: Colors.grey,
              income: controller.dailyIncome,
            ),
            buildSummaryCard(
              title: 'Pendapatan Minggu Ini',
              icon: Icons.calendar_view_week,
              color: Colors.grey,
              income: controller.weeklyIncome,
            ),
            buildSummaryCard(
              title: 'Pendapatan Bulan Ini',
              icon: Icons.calendar_month,
              color: Colors.grey,
              income: controller.monthlyIncome,
            ),
            const SizedBox(height: 24),

            // Historical Daily Income Chart
            buildChartCard(
              title: 'Pendapatan 7 Hari Terakhir ',
              child: Obx(
                () => buildBarChart(
                  controller.historicalDailyIncome.value,
                  'daily',
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Historical Weekly Income Chart
            buildChartCard(
              title: 'Pendapatan 8 Minggu Terakhir',
              child: Obx(
                () => buildBarChart(
                  controller.historicalWeeklyIncome.value,
                  'weekly',
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Historical Monthly Income Chart
            buildChartCard(
              title: 'Pendapatan 6 Bulan Terakhir',
              child: Obx(
                () => buildBarChart(
                  controller.historicalMonthlyIncome.value,
                  'monthly',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create summary cards
  Widget buildSummaryCard({
    required String title,
    required IconData icon,
    required Color color,
    required RxDouble income,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(
          () => Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(income.value),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to create chart containers
  Widget buildChartCard({required String title, required Widget child}) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250, // Fixed height for the chart
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  // Builds a BarChart from the given historical data
  Widget buildBarChart(Map<String, double> data, String type) {
    if (data.isEmpty) {
      return const Center(
        child: Text('Tidak ada data tersedia untuk periode ini.'),
      );
    }

    // Sort data by key (date/week/month) to ensure correct order on the chart
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Limit the number of entries for display to avoid clutter
    final int maxEntries = type == 'daily' ? 7 : (type == 'weekly' ? 8 : 6);
    final displayEntries = sortedEntries.length > maxEntries
        ? sortedEntries.sublist(sortedEntries.length - maxEntries)
        : sortedEntries;

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < displayEntries.length; i++) {
      final entry = displayEntries[i];
      final value = entry.value;
      if (value > maxY) {
        maxY = value;
      }
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Colors.teal.withOpacity(0.8),
              width: 15,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY * 1.2, // A bit higher than current max for background
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ],
          // REMOVED: showingTooltipIndicators: [0],
          // Removing this makes the tooltip only show on hover/touch
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String title = '';
                if (value.toInt() < displayEntries.length) {
                  final key = displayEntries[value.toInt()].key;
                  if (type == 'daily') {
                    // Extract day and month for daily (e.g., 'Jun 15')
                    title = DateFormat('MMM dd').format(DateTime.parse(key));
                  } else if (type == 'weekly') {
                    // Format for weekly (e.g., 'W24')
                    title = 'W${key.split('-')[1]}';
                  } else if (type == 'monthly') {
                    // Format for monthly (e.g., 'Jun')
                    title = DateFormat('MMM').format(DateTime.parse('$key-01'));
                  }
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4.0,
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 10, color: Colors.black),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Format y-axis labels for readability (e.g., '10K', '100K')
                return Text(
                  value >= 1000
                      ? '${(value / 1000).toStringAsFixed(0)}K'
                      : value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final entry = displayEntries[group.x.toInt()];
              String label = '';
              if (type == 'daily') {
                label = DateFormat(
                  'EEEE, MMM dd, yyyy',
                ).format(DateTime.parse(entry.key));
              } else if (type == 'weekly') {
                label =
                    'Week ${entry.key.split('-')[1]}, ${entry.key.split('-')[0]}';
              } else if (type == 'monthly') {
                label = DateFormat(
                  'MMMM yyyy',
                ).format(DateTime.parse('${entry.key}-01'));
              }
              return BarTooltipItem(
                '$label\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(rod.toY),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              );
            },
          ),
        ),
        maxY: maxY * 1.2, // Provide some padding above the max value
      ),
    );
  }
}
