import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/date_helper.dart';
import '../../models/transaction.dart';

import '../../services/local_storage/transaction_repository.dart';
import 'transaction_state.dart';

/// Owns all transaction business logic.
///
/// UI widgets never talk to [TransactionRepository] directly and never
/// compute balances/sums themselves — they only read [TransactionState]
/// and call methods on this Cubit. Flow: UI -> Cubit -> Repository -> Storage.
class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit({required TransactionRepository repository})
      : _repository = repository,
        super(const TransactionState());

  final TransactionRepository _repository;
  final Uuid _uuid = const Uuid();

  Future<void> loadTransactions() async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      final transactions = await _repository.getAll();
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: transactions,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: "Couldn't load your transactions.",
      ));
    }
  }

  /// Adds a new transaction. Returns true on success so the Add/Edit
  /// screen can show a success snackbar and pop, or an error snackbar.
  Future<bool> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    try {
      final transaction = TransactionModel(
        id: _uuid.v4(),
        title: title.trim(),
        amount: amount,
        type: type,
        category: category,
        date: date,
        note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      );
      await _repository.add(transaction);
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: [...state.transactions, transaction],
      ));
      return true;
    } catch (_) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: "Couldn't save the transaction. Please try again.",
      ));
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel updated) async {
    try {
      await _repository.update(updated);
      final newList = state.transactions
          .map((t) => t.id == updated.id ? updated : t)
          .toList();
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: newList,
      ));
      return true;
    } catch (_) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: "Couldn't update the transaction. Please try again.",
      ));
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _repository.delete(id);
      final newList = state.transactions.where((t) => t.id != id).toList();
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: newList,
      ));
      return true;
    } catch (_) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: "Couldn't delete the transaction. Please try again.",
      ));
      return false;
    }
  }

  Future<bool> clearAllTransactions() async {
    try {
      await _repository.clearAll();
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: const [],
      ));
      return true;
    } catch (_) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: "Couldn't clear your data. Please try again.",
      ));
      return false;
    }
  }

  // ---- Filtering / search (used by Transactions screen, Phase 5) ----

  List<TransactionModel> search(String query) {
    if (query.trim().isEmpty) return state.sortedByDateDesc;
    final lower = query.toLowerCase();
    return state.sortedByDateDesc
        .where((t) =>
    t.title.toLowerCase().contains(lower) ||
        (t.note?.toLowerCase().contains(lower) ?? false))
        .toList();
  }

  List<TransactionModel> filterByType(TransactionType? type) {
    if (type == null) return state.sortedByDateDesc;
    return state.sortedByDateDesc.where((t) => t.type == type).toList();
  }

  // ---- Period statistics (used by Statistics screen, Phase 5) ----

  List<TransactionModel> transactionsForPeriod(StatsPeriod period) {
    return state.transactions
        .where((t) => DateHelper.isWithinPeriod(t.date, period))
        .toList();
  }

  double incomeForPeriod(StatsPeriod period) => transactionsForPeriod(period)
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double expenseForPeriod(StatsPeriod period) => transactionsForPeriod(period)
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
}