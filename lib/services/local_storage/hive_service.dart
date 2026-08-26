import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../models/transaction.dart';

/// Handles one-time Hive setup: init, adapter registration, box opening.
///
/// This is the ONLY place that talks to Hive's static API. Everything
/// else in the app goes through [TransactionRepository], so the
/// storage engine itself (Hive) could be swapped out later without
/// touching the Cubit or UI layers.
class HiveService {
  HiveService._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionModelAdapter());

    await Hive.openBox<TransactionModel>(AppConstants.transactionsBoxName);
    await Hive.openBox(AppConstants.settingsBoxName);

    _initialized = true;
  }
}