import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/constants/category_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../cubit/settings/settings_cubit.dart';
import '../../cubit/transaction/transaction_cubit.dart';
import '../../models/transaction.dart';
import '../add_transaction/add_transaction_screen.dart';

/// Opens the transaction detail as a modal bottom sheet — tap a row
/// anywhere in the app to get here.
Future<void> showTransactionDetailSheet(
    BuildContext context,
    TransactionModel transaction,
    ) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TransactionDetailSheet(transaction: transaction),
  );
}

class TransactionDetailSheet extends StatelessWidget {
  const TransactionDetailSheet({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final category = CategoryConstants.byId(transaction.category);
    final amountColor =
    transaction.isIncome ? AppColors.income : AppColors.expense;
    final currency = context.select<SettingsCubit, String>(
            (c) => c.state.currencySymbol);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryIcon(category: category, size: 52),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(transaction.title, style: AppTextStyles.h2()),
                      const SizedBox(height: 2),
                      Text(category.name, style: AppTextStyles.caption()),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              CurrencyFormatter.formatSigned(
                transaction.amount,
                transaction.isIncome,
                symbol: currency,
              ),
              style: AppTextStyles.display(color: amountColor),
            ),
            const SizedBox(height: AppSpacing.md),
            _DetailRow(
              label: 'Date',
              value: DateFormat('d MMMM yyyy').format(transaction.date),
            ),
            if (transaction.note != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(label: 'Note', value: transaction.note!),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddTransactionScreen(
                            initialType: transaction.type,
                            existingTransaction: transaction,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showConfirmationDialog(
                        context,
                        title: 'Delete transaction?',
                        message:
                        'This will permanently delete "${transaction.title}". This cannot be undone.',
                      );
                      if (!confirmed || !context.mounted) return;
                      final cubit = context.read<TransactionCubit>();
                      final success =
                      await cubit.deleteTransaction(transaction.id);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      showAppSnackbar(
                        context,
                        message: success
                            ? 'Transaction deleted'
                            : 'Could not delete transaction',
                        isError: !success,
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error),
                    label: const Text('Delete',
                        style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: AppTextStyles.caption()),
        ),
        Expanded(child: Text(value, style: AppTextStyles.body())),
      ],
    );
  }
}