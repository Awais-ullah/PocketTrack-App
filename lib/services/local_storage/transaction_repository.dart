import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../models/transaction.dart';

/// Abstract contract for transaction persistence.
///
/// The Cubit depends on this interface, not on Hive directly. Adding
/// a remote/cloud-backed implementation later (e.g. `ApiTransactionRepository`)
/// means implementing this same interface — no changes needed in
/// [TransactionCubit] or any screen.
abstract class TransactionRepository {
  Future<List<TransactionModel>> getAll();
  Future<void> add(TransactionModel transaction);
  Future<void> update(TransactionModel transaction);
  Future<void> delete(String id);
  Future<void> clearAll();
}

/// Hive-backed implementation of [TransactionRepository] for v1.
///
/// Transactions are keyed by their own `id` in the box, so add/update
/// are both just a `put` and delete is a direct key removal.
class HiveTransactionRepository implements TransactionRepository {
  Box<TransactionModel> get _box =>
      Hive.box<TransactionModel>(AppConstants.transactionsBoxName);

  @override
  Future<List<TransactionModel>> getAll() async {
    return _box.values.toList();
  }

  @override
  Future<void> add(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  @override
  Future<void> update(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }
}