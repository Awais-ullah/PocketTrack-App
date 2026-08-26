import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import 'settings_state.dart';

/// Owns app preferences (currency, theme mode, default category).
///
/// Persists directly to the Hive settings box — a plain key/value
/// store is enough here, unlike transactions which need a typed model.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Box get _box => Hive.box(AppConstants.settingsBoxName);

  void _loadSettings() {
    final currency = _box.get(
      AppConstants.settingsCurrencyKey,
      defaultValue: AppConstants.defaultCurrencySymbol,
    ) as String;
    final themeModeName = _box.get(
      AppConstants.settingsThemeKey,
      defaultValue: ThemeMode.system.name,
    ) as String;
    final defaultCategory =
    _box.get(AppConstants.settingsDefaultCategoryKey) as String?;

    emit(state.copyWith(
      currencySymbol: currency,
      themeMode: ThemeMode.values.firstWhere(
            (m) => m.name == themeModeName,
        orElse: () => ThemeMode.system,
      ),
      defaultCategoryId: defaultCategory,
    ));
  }

  Future<void> setCurrency(String symbol) async {
    await _box.put(AppConstants.settingsCurrencyKey, symbol);
    emit(state.copyWith(currencySymbol: symbol));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put(AppConstants.settingsThemeKey, mode.name);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setDefaultCategory(String categoryId) async {
    await _box.put(AppConstants.settingsDefaultCategoryKey, categoryId);
    emit(state.copyWith(defaultCategoryId: categoryId));
  }
}