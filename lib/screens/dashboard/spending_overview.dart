import 'package:flutter/material.dart';
import '../../core/constants/category_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';

/// Compact top-3-category breakdown shown on the Dashboard.
/// Tapping it is handled by the parent (navigates to Statistics).
class SpendingOverview extends StatelessWidget {
  const SpendingOverview({
    super.key,
    required this.expenseByCategory,
    required this.onTap,
    this.currencySymbol = 'Rs.',
  });

  final Map<String, double> expenseByCategory;
  final VoidCallback onTap;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final total = expenseByCategory.values.fold(0.0, (a, b) => a + b);
    final entries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(3).toList();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: top.map((entry) {
            final category = CategoryConstants.byId(entry.key);
            final percent = total == 0 ? 0.0 : entry.value / total;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(category.name, style: AppTextStyles.body()),
                      Text(
                        '${CurrencyFormatter.format(entry.value, symbol: currencySymbol)} · ${(percent * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.caption(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor: category.color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation(category.color),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}