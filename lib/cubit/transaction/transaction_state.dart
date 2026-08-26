import 'package:equatable/equatable.dart';
import '../../models/transaction.dart';

enum TransactionStatus { initial, loading, loaded, error }

class TransactionState extends Equatable {
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.errorMessage,
  });

  final TransactionStatus status;
  final List<TransactionModel> transactions;
  final String? errorMessage;

  bool get isEmpty => transactions.isEmpty;

  // ---- Core calculations (kept in state/Cubit, never in the UI) ----

  double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  /// Transactions sorted newest-first.
  List<TransactionModel> get sortedByDateDesc {
    final list = [...transactions];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<TransactionModel> recent(int limit) {
    return sortedByDateDesc.take(limit).toList();
  }

  /// Total expense amount grouped by category id — used by the
  /// Dashboard's compact breakdown and the Statistics donut chart.
  Map<String, double> get expenseByCategory {
    final Map<String, double> totals = {};
    for (final t in transactions.where((t) => t.isExpense)) {
      totals.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    return totals;
  }

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionModel>? transactions,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage];
}