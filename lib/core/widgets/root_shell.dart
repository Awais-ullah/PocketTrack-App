import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../screens/add_transaction/add_transaction_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/statistics/statistics_screen.dart';
import '../../screens/transactions/transactions_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Hosts the four main tabs plus the center "Add Transaction" FAB,
/// reachable from anywhere in the app.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  Future<void> _openAddTransactionSheet() async {
    final type = await showModalBottomSheet<TransactionType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddTypeSheet(),
    );
    if (type == null || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(initialType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionSheet,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Dashboard',
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Transactions',
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
              ),
              const Expanded(child: SizedBox()), // space for the notch/FAB
              Expanded(
                child: _NavItem(
                  icon: Icons.pie_chart_rounded,
                  label: 'Statistics',
                  selected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  selected: _index == 3,
                  onTap: () => setState(() => _index = 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: AppTextStyles.label(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet shown when the FAB is tapped — choose Income or Expense.
class _AddTypeSheet extends StatelessWidget {
  const _AddTypeSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Transaction', style: AppTextStyles.h2()),
            const SizedBox(height: AppSpacing.md),
            _TypeOption(
              icon: Icons.arrow_downward_rounded,
              label: 'Add Income',
              color: AppColors.income,
              onTap: () =>
                  Navigator.of(context).pop(TransactionType.income),
            ),
            const SizedBox(height: AppSpacing.sm),
            _TypeOption(
              icon: Icons.arrow_upward_rounded,
              label: 'Add Expense',
              color: AppColors.expense,
              onTap: () =>
                  Navigator.of(context).pop(TransactionType.expense),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTextStyles.bodyStrong(color: color)),
          ],
        ),
      ),
    );
  }
}