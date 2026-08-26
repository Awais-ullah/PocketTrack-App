import 'package:intl/intl.dart';

/// Formats amounts with the app's currency symbol and thousands
/// separators. Currency symbol comes from Settings (next phase) — for
/// now it accepts a symbol parameter so screens stay decoupled from
/// SettingsCubit until that's wired up.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _numberFormat = NumberFormat('#,##0');
  static final NumberFormat _decimalFormat = NumberFormat('#,##0.00');

  static String format(double amount, {String symbol = 'Rs.'}) {
    final isWhole = amount == amount.roundToDouble();
    final formatted =
    isWhole ? _numberFormat.format(amount) : _decimalFormat.format(amount);
    return '$symbol $formatted';
  }

  static String formatSigned(double amount, bool isIncome,
      {String symbol = 'Rs.'}) {
    final sign = isIncome ? '+' : '-';
    return '$sign${format(amount, symbol: symbol)}';
  }
}