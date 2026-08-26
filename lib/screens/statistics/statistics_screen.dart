import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/common_widgets.dart';
import '../../cubit/settings/settings_cubit.dart';
import '../../cubit/settings/settings_state.dart';
import '../../cubit/transaction/transaction_cubit.dart';
import '../../cubit/transaction/transaction_state.dart';
import 'category_donut_chart.dart';
import 'income_expense_bar_chart.dart';
import 'spending_trend_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatsPeriod _period = StatsPeriod.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SafeArea(
        child: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            if (state.isEmpty) {
              return const EmptyStateView(
                icon: Icons.bar_chart_rounded,
                title: 'Nothing to show yet',
                subtitle: 'Add a few transactions to see your statistics.',
              );
            }

            final cubit = context.read<TransactionCubit>();
            final periodTransactions = cubit.transactionsForPeriod(_period);
            final income = cubit.incomeForPeriod(_period);
            final expense = cubit.expenseForPeriod(_period);
            final balance = income - expense;

            final expenseByCategory = <String, double>{};
            for (final t in periodTransactions.where((t) => t.isExpense)) {
              expenseByCategory.update(
                t.category,
                    (v) => v + t.amount,
                ifAbsent: () => t.amount,
              );
            }

            final currency = context.select<SettingsCubit, String>(
                    (c) => c.state.currencySymbol);

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, AppSpacing.md, AppSpacing.screenPadding, 100),
              children: [
                _PeriodSelector(
                  value: _period,
                  onChanged: (p) => setState(() => _period = p),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        label: 'Income',
                        value: CurrencyFormatter.format(income, symbol: currency),
                        color: AppColors.income,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryTile(
                        label: 'Expenses',
                        value: CurrencyFormatter.format(expense, symbol: currency),
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Net balance: ${CurrencyFormatter.format(balance, symbol: currency)}',
                  style: AppTextStyles.caption(),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChartCard(
                  title: 'Spending by Category',
                  child: CategoryDonutChart(
                    expenseByCategory: expenseByCategory,
                    currencySymbol: currency,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChartCard(
                  title: 'Income vs Expenses',
                  child: IncomeExpenseBarChart(income: income, expense: expense),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChartCard(
                  title: 'Spending Trend',
                  child: SpendingTrendChart(
                    transactions: periodTransactions,
                    rangeStart: DateHelper.startOf(_period),
                    rangeEnd: DateTime.now(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.value, required this.onChanged});

  final StatsPeriod value;
  final ValueChanged<StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment(String label, StatsPeriod period) {
      final selected = value == period;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(period),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.bodyStrong(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        children: [
          segment('Weekly', StatsPeriod.week),
          segment('Monthly', StatsPeriod.month),
          segment('Yearly', StatsPeriod.year),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption()),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTextStyles.h2(color: color)),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2()),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}