import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'transaction.dart';

/// A spending or income category.
///
/// v1 ships with a fixed predefined set (see `category_constants.dart`),
/// but the model itself doesn't assume that — nothing here prevents
/// user-created categories from being added to storage later.
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;

  @override
  List<Object?> get props => [id, name, icon, color, type];
}
