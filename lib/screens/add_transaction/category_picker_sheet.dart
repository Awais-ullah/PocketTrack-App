import 'package:flutter/material.dart';
import '../../core/constants/category_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/category_icon.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';

Future<Category?> showCategoryPicker(
    BuildContext context,
    TransactionType type, {
      String? selectedId,
    }) {
  final categories = CategoryConstants.byType(type);
  return showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SafeArea(
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
            Text('Select Category', style: AppTextStyles.h2()),
            const SizedBox(height: AppSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category.id == selectedId;
                return InkWell(
                  onTap: () => Navigator.of(context).pop(category),
                  borderRadius: BorderRadius.circular(12),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(color: AppColors.primary, width: 2)
                                : null,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: CategoryIcon(category: category, size: 48),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.name,
                          style: AppTextStyles.caption(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}