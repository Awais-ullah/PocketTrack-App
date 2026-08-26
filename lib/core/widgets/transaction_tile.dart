import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/category_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency_formatter.dart';
import '../../models/transaction.dart';
import 'category_icon.dart';

/// A single transaction row — used on the Dashboard's recent list
/// and throughout the Transactions screen so the two stay visually
/// identical.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
    this.currencySymbol = 'Rs.',
  });

  final TransactionModel transaction;
  final VoidCallback onTap;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final category = CategoryConstants.byId(transaction.category);
    final amountColor =
    transaction.isIncome ? AppColors.income : AppColors.expense;

    return TweenAnimationBuilder<double>(
      key: ValueKey(transaction.id),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 8),
          child: child,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Row(
            children: [
              CategoryIcon(category: category),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: AppTextStyles.bodyStrong(color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category.name} · ${DateFormat('d MMM').format(transaction.date)}',
                      style: AppTextStyles.caption(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                CurrencyFormatter.formatSigned(
                  transaction.amount,
                  transaction.isIncome,
                  symbol: currencySymbol,
                ),
                style: AppTextStyles.bodyStrong(color: amountColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}