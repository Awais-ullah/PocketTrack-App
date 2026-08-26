import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/transaction.dart';

/// Spending trend line — daily expense totals across the currently
/// selected period, so the shape adapts to Week/Month/Year automatically.
class SpendingTrendChart extends StatelessWidget {
  const SpendingTrendChart({
    super.key,
    required this.transactions,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final List<TransactionModel> transactions;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  @override
  Widget build(BuildContext context) {
    final days = rangeEnd.difference(rangeStart).inDays.clamp(1, 366);
    final Map<int, double> totals = {for (var i = 0; i <= days; i++) i: 0.0};

    for (final t in transactions.where((t) => t.isExpense)) {
      final offset = t.date.difference(rangeStart).inDays;
      if (offset >= 0 && offset <= days) {
        totals[offset] = (totals[offset] ?? 0) + t.amount;
      }
    }

    final spots = totals.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final maxY = spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b);

    if (maxY == 0) {
      return Center(
        child: Text('No spending recorded in this period.',
            style: AppTextStyles.caption()),
      );
    }

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          minY: 0,
          maxY: maxY * 1.2,
          lineTouchData: const LineTouchData(enabled: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}