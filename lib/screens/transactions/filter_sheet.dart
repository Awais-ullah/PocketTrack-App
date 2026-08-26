import 'package:flutter/material.dart';
import '../../core/constants/category_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/transaction.dart';

enum SortOption { newest, oldest, amountHigh, amountLow }

class TransactionFilters {
  const TransactionFilters({
    this.type,
    this.categoryIds = const {},
    this.sort = SortOption.newest,
  });

  final TransactionType? type;
  final Set<String> categoryIds;
  final SortOption sort;

  TransactionFilters copyWith({
    TransactionType? type,
    bool clearType = false,
    Set<String>? categoryIds,
    SortOption? sort,
  }) {
    return TransactionFilters(
      type: clearType ? null : (type ?? this.type),
      categoryIds: categoryIds ?? this.categoryIds,
      sort: sort ?? this.sort,
    );
  }

  bool get isActive => type != null || categoryIds.isNotEmpty || sort != SortOption.newest;
}

/// Bottom sheet for category multi-select, and sort — presented from
/// the Transactions screen's filter icon. Income/Expense filtering
/// lives in the segmented control on the main screen, not here.
Future<TransactionFilters?> showFilterSheet(
    BuildContext context,
    TransactionFilters current,
    ) {
  return showModalBottomSheet<TransactionFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterSheet(initial: current),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});
  final TransactionFilters initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<String> _categoryIds;
  late SortOption _sort;

  @override
  void initState() {
    super.initState();
    _categoryIds = {...widget.initial.categoryIds};
    _sort = widget.initial.sort;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Filter & Sort',
                    style: AppTextStyles.h2(color: Colors.white60)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'CATEGORY',
                style: AppTextStyles.label(color: AppColors.primary)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CategoryConstants.all.map((c) {
                  final selected = _categoryIds.contains(c.id);
                  return _CategoryChip(
                    label: c.name,
                    selected: selected,
                    onTap: () => setState(() {
                      selected ? _categoryIds.remove(c.id) : _categoryIds.add(c.id);
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'SORT BY',
                style: AppTextStyles.label(color: AppColors.primary)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...SortOption.values.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SortOptionTile(
                  label: _sortLabel(option),
                  selected: _sort == option,
                  onTap: () => setState(() => _sort = option),
                ),
              )),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _categoryIds = {};
                          _sort = SortOption.newest;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(
                        widget.initial.copyWith(
                          categoryIds: _categoryIds,
                          sort: _sort,
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sortLabel(SortOption o) {
    switch (o) {
      case SortOption.newest:
        return 'Newest first';
      case SortOption.oldest:
        return 'Oldest first';
      case SortOption.amountHigh:
        return 'Amount: High to Low';
      case SortOption.amountLow:
        return 'Amount: Low to High';
    }
  }
}

/// Hand-built sort-option row — replaces RadioListTile for the same
/// reason _CategoryChip replaces FilterChip: no reliance on default
/// Radio/ListTile theming, so it can't render invisible on any device.
class _SortOptionTile extends StatelessWidget {
  const _SortOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.body(
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ).copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hand-built category pill — deliberately NOT using Flutter's
/// FilterChip. FilterChip pulls its label color from the app's
/// ChipTheme, which isn't configured, and on some devices/Material
/// versions that resolves to an invisible color. Every other pill
/// in the app (segmented controls, etc.) is built this same explicit
/// way and renders correctly, so category chips now match.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ).copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.normal),
        ),
      ),
    );
  }
}