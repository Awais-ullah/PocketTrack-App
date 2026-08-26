import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pockettrack/core/widgets/responsive_content.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/transaction_tile.dart';
import '../../cubit/settings/settings_cubit.dart';
import '../../cubit/transaction/transaction_cubit.dart';
import '../../cubit/transaction/transaction_state.dart';
import '../../models/transaction.dart';
import 'filter_sheet.dart';
import 'transaction_detail_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searchVisible = false;
  String _query = '';
  TransactionType? _typeFilter;
  TransactionFilters _filters = const TransactionFilters();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _applyAll(TransactionState state) {
    var list = state.sortedByDateDesc;

    if (_query.trim().isNotEmpty) {
      final lower = _query.toLowerCase();
      list = list
          .where((t) =>
      t.title.toLowerCase().contains(lower) ||
          (t.note?.toLowerCase().contains(lower) ?? false))
          .toList();
    }

    if (_typeFilter != null) {
      list = list.where((t) => t.type == _typeFilter).toList();
    }

    if (_filters.categoryIds.isNotEmpty) {
      list = list.where((t) => _filters.categoryIds.contains(t.category)).toList();
    }

    switch (_filters.sort) {
      case SortOption.newest:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.oldest:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountHigh:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountLow:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return list;
  }

  Map<String, List<TransactionModel>> _groupByDate(
      List<TransactionModel> list) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in list) {
      final key = DateHelper.isToday(t.date)
          ? 'Today'
          : DateHelper.isYesterday(t.date)
          ? 'Yesterday'
          : DateFormat('d MMMM yyyy').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(_searchVisible ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () => setState(() {
              _searchVisible = !_searchVisible;
              if (!_searchVisible) {
                _searchController.clear();
                _query = '';
              }
            }),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: _filters.isActive,
              smallSize: 8,
              child: const Icon(Icons.tune_rounded),
            ),
            onPressed: () async {
              final result = await showFilterSheet(context, _filters);
              if (result != null) setState(() => _filters = result);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_searchVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 0, AppSpacing.screenPadding, AppSpacing.sm),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Search transactions',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
              child: _TypeSegmentedControl(
                value: _typeFilter,
                onChanged: (v) => setState(() => _typeFilter = v),
              ),
            ),
            Expanded(
              child: BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, state) {
                  if (state.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions yet',
                      subtitle: 'Everything you add will show up here.',
                    );
                  }

                  final filtered = _applyAll(state);
                  if (filtered.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: 'No matching transactions',
                      subtitle: 'Try a different search or filter.',
                    );
                  }

                  final grouped = _groupByDate(filtered);
                  final currency = context.select<SettingsCubit, String>(
                          (c) => c.state.currencySymbol);

                  return ResponsiveContent(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding, 0, AppSpacing.screenPadding, 100),
                      children: grouped.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              child: Text(entry.key, style: AppTextStyles.label()),
                            ),
                            ...entry.value.map((t) => TransactionTile(
                              currencySymbol: currency,
                              transaction: t,
                              onTap: () => showTransactionDetailSheet(context, t),
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSegmentedControl extends StatelessWidget {
  const _TypeSegmentedControl({required this.value, required this.onChanged});

  final TransactionType? value;
  final ValueChanged<TransactionType?> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment(String label, TransactionType? type) {
      final selected = value == type;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(type),
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
          segment('All', null),
          segment('Income', TransactionType.income),
          segment('Expense', TransactionType.expense),
        ],
      ),
    );
  }
}