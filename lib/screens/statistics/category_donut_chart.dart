import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/category_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';

/// Expense-by-category donut chart with a tappable legend below it.
class CategoryDonutChart extends StatefulWidget {
  const CategoryDonutChart({
    super.key,
    required this.expenseByCategory,
    this.currencySymbol = 'Rs.',
  });

  final Map<String, double> expenseByCategory;
  final String currencySymbol;

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final entries = widget.expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    if (entries.isEmpty || total == 0) {
      return Center(
        child: Text('No expenses in this period.', style: AppTextStyles.caption()),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response?.touchedSection == null) {
                      _touchedIndex = null;
                      return;
                    }
                    _touchedIndex =
                        response!.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: List.generate(entries.length, (i) {
                final entry = entries[i];
                final category = CategoryConstants.byId(entry.key);
                final percent = entry.value / total;
                final isTouched = i == _touchedIndex;
                return PieChartSectionData(
                  color: category.color,
                  value: entry.value,
                  radius: isTouched ? 46 : 40,
                  title: '${(percent * 100).toStringAsFixed(0)}%',
                  titleStyle: AppTextStyles.caption(color: Colors.white)
                      .copyWith(fontWeight: FontWeight.w600),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: List.generate(entries.length, (i) {
            final entry = entries[i];
            final category = CategoryConstants.byId(entry.key);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${category.name} · ${CurrencyFormatter.format(entry.value, symbol: widget.currencySymbol)}',
                  style: AppTextStyles.caption(),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}