import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.currencySymbol = 'Rs.',
    this.themeMode = ThemeMode.system,
    this.defaultCategoryId,
  });

  final String currencySymbol;
  final ThemeMode themeMode;
  final String? defaultCategoryId;

  SettingsState copyWith({
    String? currencySymbol,
    ThemeMode? themeMode,
    String? defaultCategoryId,
  }) {
    return SettingsState(
      currencySymbol: currencySymbol ?? this.currencySymbol,
      themeMode: themeMode ?? this.themeMode,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
    );
  }

  @override
  List<Object?> get props => [currencySymbol, themeMode, defaultCategoryId];
}