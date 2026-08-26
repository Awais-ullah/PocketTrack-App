import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../theme/app_colors.dart';

/// Predefined categories available in PocketTrack v1.
///
/// Kept as a static list (not persisted) for now — the architecture
/// doesn't prevent moving this into local storage later so users can
/// manage/extend their own categories without a code change.
class CategoryConstants {
  CategoryConstants._();

  static const List<Category> expenseCategories = [
    Category(
      id: 'exp_food',
      name: 'Food',
      icon: Icons.restaurant_rounded,
      color: AppColors.expense,
      type: TransactionType.expense,
    ),
    Category(
      id: 'exp_transport',
      name: 'Transport',
      icon: Icons.directions_car_filled_rounded,
      color: Color(0xFF3D7AB3),
      type: TransactionType.expense,
    ),
    Category(
      id: 'exp_shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF8B5CF6),
      type: TransactionType.expense,
    ),
    Category(
      id: 'exp_bills',
      name: 'Bills',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFE8A93D),
      type: TransactionType.expense,
    ),
    Category(
      id: 'exp_entertainment',
      name: 'Entertainment',
      icon: Icons.movie_filter_rounded,
      color: Color(0xFF0F9B8E),
      type: TransactionType.expense,
    ),
    Category(
      id: 'exp_health',
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: AppColors.expense,
      type: TransactionType.expense,
    ),
    Category(
      id: 'exp_education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF1B5E4F),
      type: TransactionType.expense,
    ),
    Category(
      id: 'exp_other',
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: AppColors.textSecondary,
      type: TransactionType.expense,
    ),
  ];

  static const List<Category> incomeCategories = [
    Category(
      id: 'inc_salary',
      name: 'Salary',
      icon: Icons.work_rounded,
      color: AppColors.income,
      type: TransactionType.income,
    ),
    Category(
      id: 'inc_freelance',
      name: 'Freelance',
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFF3D7AB3),
      type: TransactionType.income,
    ),
    Category(
      id: 'inc_business',
      name: 'Business',
      icon: Icons.storefront_rounded,
      color: Color(0xFF0F9B8E),
      type: TransactionType.income,
    ),
    Category(
      id: 'inc_gift',
      name: 'Gift',
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFF8B5CF6),
      type: TransactionType.income,
    ),
    Category(
      id: 'inc_investment',
      name: 'Investment',
      icon: Icons.trending_up_rounded,
      color: AppColors.income,
      type: TransactionType.income,
    ),
    Category(
      id: 'inc_other',
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: AppColors.textSecondary,
      type: TransactionType.income,
    ),
  ];

  static const List<Category> all = [
    ...expenseCategories,
    ...incomeCategories,
  ];

  static Category byId(String id) {
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => expenseCategories.last, // falls back to "Other"
    );
  }

  static List<Category> byType(TransactionType type) {
    return type == TransactionType.expense ? expenseCategories : incomeCategories;
  }
}
