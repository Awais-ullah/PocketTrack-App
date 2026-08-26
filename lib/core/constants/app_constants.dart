/// General, non-visual constants for PocketTrack.
class AppConstants {
  AppConstants._();

  static const String appName = 'PocketTrack';
  static const String appTagline = 'Know where it goes.';
  static const String appVersion = '1.0.0';

  // Hive box names — kept here so the storage layer and any future
  // migration code reference the same literal.
  static const String transactionsBoxName = 'transactions_box';
  static const String settingsBoxName = 'settings_box';

  // Settings keys
  static const String settingsCurrencyKey = 'currency';
  static const String settingsThemeKey = 'theme_mode';
  static const String settingsDefaultCategoryKey = 'default_category';

  static const String defaultCurrencySymbol = 'Rs.';

  static const List<String> availableCurrencies = [
    'Rs.', // PKR
    '\$', // USD
    '€', // EUR
    '£', // GBP
    '₹', // INR
  ];

  static const int recentTransactionsLimit = 5;

  static const Duration splashMinimumDuration = Duration(milliseconds: 900);
}
