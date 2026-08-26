import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'transaction.g.dart';

/// Whether a [TransactionModel] represents money coming in or going out.
@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

/// A single income or expense entry.
///
/// This is the core data model of PocketTrack. It is intentionally
/// flat and simple so it's easy to extend later (e.g. adding
/// `recurringId`, `attachmentPath`, or `accountId` for future phases)
/// without breaking the storage layer.
@HiveType(typeId: 1)
class TransactionModel extends Equatable {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  /// Always stored as a positive value. Sign/direction is derived
  /// from [type], never encoded into the number itself.
  @HiveField(2)
  final double amount;

  @HiveField(3)
  final TransactionType type;

  /// The category id (see [Category]), not the display name — so
  /// category labels/icons can be changed later without migrating data.
  @HiveField(4)
  final String category;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? note;

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  /// Signed amount convenience getter — positive for income,
  /// negative for expense. Useful for sum() operations in the Cubit.
  double get signedAmount => isIncome ? amount : -amount;

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, title, amount, type, category, date, note];
}
