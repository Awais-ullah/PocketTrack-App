import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/transaction_tile.dart';
import '../../cubit/settings/settings_cubit.dart';
import '../../cubit/transaction/transaction_cubit.dart';
import '../../cubit/transaction/transaction_state.dart';
import '../../models/transaction.dart';
import '../add_transaction/add_transaction_screen.dart';
import '../transactions/transaction_detail_sheet.dart';
import '../transactions/transactions_screen.dart';
import 'balance_card.dart';
import 'spending_overview.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            if (state.status == TransactionStatus.loading &&
                state.transactions.isEmpty) {
              return const _DashboardSkeleton();
            }

            final recent =
            state.recent(AppConstants.recentTransactionsLimit);
            final currency = context.select<SettingsCubit, String>(
                    (c) => c.state.currencySymbol);

            return RefreshIndicator(
              onRefresh: () => context.read<TransactionCubit>().loadTransactions(),
              child: ResponsiveContent(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.md,
                    AppSpacing.screenPadding,
                    100,
                  ),
                  children: [
                    _Header(),
                    const SizedBox(height: AppSpacing.lg),
                    if (state.status == TransactionStatus.error &&
                        state.errorMessage != null)
                      ErrorBanner(
                        message: state.errorMessage!,
                        onRetry: () =>
                            context.read<TransactionCubit>().loadTransactions(),
                      ),
                    BalanceCard(
                      balance: state.balance,
                      income: state.totalIncome,
                      expense: state.totalExpense,
                      currencySymbol: currency,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddTransactionScreen(
                                  initialType: TransactionType.income,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded,
                                color: AppColors.income),
                            label: const Text('Add Income'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.income,
                              side: const BorderSide(color: AppColors.income),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddTransactionScreen(
                                  initialType: TransactionType.expense,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.remove_rounded,
                                color: AppColors.expense),
                            label: const Text('Add Expense'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.expense,
                              side: const BorderSide(color: AppColors.expense),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SectionHeader(
                      title: 'Recent Transactions',
                      actionLabel: state.isEmpty ? null : 'See All',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TransactionsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (state.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: EmptyStateView(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'No transactions yet',
                          subtitle: 'Start tracking your income and expenses.',
                          actionLabel: 'Add your first transaction',
                          onAction: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddTransactionScreen(
                                initialType: TransactionType.expense,
                              ),
                            ),
                          ),
                        ),
                      )
                    else ...[
                      ...recent.map((t) => TransactionTile(
                        transaction: t,
                        currencySymbol: currency,
                        onTap: () => showTransactionDetailSheet(context, t),
                      )),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(title: 'Spending by Category'),
                      const SizedBox(height: AppSpacing.sm),
                      if (state.expenseByCategory.isEmpty)
                        Text(
                          'No expenses recorded yet.',
                          style: AppTextStyles.caption(),
                        )
                      else
                        SpendingOverview(
                          expenseByCategory: state.expenseByCategory,
                          currencySymbol: currency,
                          onTap: () {
                            showAppSnackbar(context,
                                message: 'Open the Statistics tab for full detail.');
                          },
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: AppTextStyles.h1(color: AppColors.primary)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('EEEE, d MMMM').format(DateTime.now()),
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget block(double height, {double? width}) => Container(
      width: width ?? double.infinity,
      height: height,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          block(24, width: 180),
          block(160),
          block(48),
          block(60),
          block(60),
          block(60),
        ],
      ),
    );
  }
}