import 'package:flutter/material.dart';
import '../../models/category.dart';

/// Circular tinted icon used everywhere a category is displayed
/// (transaction rows, category picker, statistics legend).
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 44,
  });

  final Category category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(category.icon, color: category.color, size: size * 0.5),
    );
  }
}