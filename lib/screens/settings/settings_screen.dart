import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../cubit/settings/settings_cubit.dart';
import '../../cubit/settings/settings_state.dart';
import '../../cubit/transaction/transaction_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.md,
              ),
              children: [
                _SectionLabel('PREFERENCES'),
                _SettingsGroup(
                  children: [
                    SingleChildScrollView(
                      child: _SettingsTile(
                        label: 'Currency',
                        value: settings.currencySymbol,
                        onTap: () => _showCurrencyPicker(context, settings),
                      ),
                    ),
                    _SettingsTile(
                      label: 'Theme',
                      value: _themeLabel(settings.themeMode),
                      onTap: () => _showThemePicker(context, settings),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel('DATA'),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      label: 'Clear All Transactions',
                      labelColor: AppColors.error,
                      onTap: () => _confirmClearData(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel('ABOUT'),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      label: 'App Version',
                      value: AppConstants.appVersion,
                    ),
                    _SettingsTile(
                      label: 'About PocketTrack',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showCurrencyPicker(BuildContext context, SettingsState settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: 'Currency',
        options: AppConstants.availableCurrencies,
        selected: settings.currencySymbol,
        onSelected: (value) {
          context.read<SettingsCubit>().setCurrency(value);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showThemePicker(BuildContext context, SettingsState settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: 'Theme',
        options: const ['System', 'Light', 'Dark'],
        selected: _themeLabel(settings.themeMode),
        onSelected: (value) {
          final mode = value == 'Light'
              ? ThemeMode.light
              : value == 'Dark'
              ? ThemeMode.dark
              : ThemeMode.system;

          context.read<SettingsCubit>().setThemeMode(mode);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Clear all transactions?',
      message:
      'This will permanently delete all transactions. This cannot be undone.',
      confirmLabel: 'Delete',
    );

    if (!confirmed || !context.mounted) return;

    final success =
    await context.read<TransactionCubit>().clearAllTransactions();

    if (!context.mounted) return;

    showAppSnackbar(
      context,
      message:
      success ? 'All transactions cleared' : 'Could not clear data',
      isError: !success,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.h2(),
        ),
        content: Text(
          '${AppConstants.appTagline}\n\n'
              'Version ${AppConstants.appVersion}\n\n'
              'A simple, offline-first way to track your income and expenses.',
          style: AppTextStyles.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
        left: 4,
      ),
      child: Text(
        text,
        style: AppTextStyles.label(),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(
          children.length,
              (i) {
            return Column(
              children: [
                children[i],
                if (i != children.length - 1)
                  const Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.label,
    this.value,
    this.labelColor,
    this.onTap,
  });

  final String label;
  final String? value;
  final Color? labelColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.body(color: labelColor ?? AppColors.textPrimary),
            ),
            const Spacer(),
            if (value != null) ...[
              Text(
                value!,
                style: AppTextStyles.caption(),
              ),
              const SizedBox(width: 4),
            ],
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ??
              Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(
            AppRadius.bottomSheet,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: AppTextStyles.h2(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...options.map(
                    (option) => RadioListTile<String>(
                  value: option,
                  groupValue: selected,
                  onChanged: (v) => onSelected(v!),
                  title: Text(
                    option,
                    style: AppTextStyles.body(),
                  ),
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}