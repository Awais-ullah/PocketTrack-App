import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/constants/category_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../cubit/settings/settings_cubit.dart';
import '../../cubit/transaction/transaction_cubit.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import 'category_picker_sheet.dart';

/// Shared Add/Expense form. Pass [existingTransaction] to edit instead
/// of create.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    required this.initialType,
    this.existingTransaction,
  });

  final TransactionType initialType;
  final TransactionModel? existingTransaction;

  bool get isEditing => existingTransaction != null;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _type;
  Category? _category;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    _type = existing?.type ?? widget.initialType;
    _date = existing?.date ?? DateTime.now();
    if (existing != null) {
      _amountController.text = existing.amount % 1 == 0
          ? existing.amount.toStringAsFixed(0)
          : existing.amount.toString();
      _titleController.text = existing.title;
      _noteController.text = existing.note ?? '';
      _category = CategoryConstants.byId(existing.category);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Color get _accentColor =>
      _type == TransactionType.income ? AppColors.income : AppColors.expense;

  void _switchType(TransactionType type) {
    setState(() {
      _type = type;
      // Category belonged to the old type — clear it so the user
      // re-picks from the correct list rather than keeping a stale one.
      _category = null;
    });
  }

  Future<void> _pickCategory() async {
    final result = await showCategoryPicker(
      context,
      _type,
      selectedId: _category?.id,
    );
    if (result != null) setState(() => _category = result);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      showAppSnackbar(context, message: 'Please select a category', isError: true);
      return;
    }

    setState(() => _saving = true);
    final cubit = context.read<TransactionCubit>();
    final amount = double.parse(_amountController.text.trim());

    bool success;
    if (widget.isEditing) {
      final updated = widget.existingTransaction!.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        category: _category!.id,
        date: _date,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      success = await cubit.updateTransaction(updated);
    } else {
      success = await cubit.addTransaction(
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        category: _category!.id,
        date: _date,
        note: _noteController.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      Navigator.of(context).pop();
      showAppSnackbar(
        context,
        message: widget.isEditing
            ? 'Transaction updated'
            : (_type == TransactionType.income
            ? 'Income added'
            : 'Expense added'),
      );
    } else {
      showAppSnackbar(context,
          message: "Couldn't save the transaction. Please try again.",
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing
        ? (_type == TransactionType.income ? 'Edit Income' : 'Edit Expense')
        : (_type == TransactionType.income ? 'Add Income' : 'Add Expense');
          final currency = context.select<SettingsCubit, String>(
            (c) => c.state.currencySymbol);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, AppSpacing.md, AppSpacing.screenPadding, 120),
            children: [
              if (!widget.isEditing) ...[
                _TypeToggle(type: _type, onChanged: _switchType),
                const SizedBox(height: AppSpacing.lg),
              ],
              Center(
                child: Column(
                  children: [
                    Text('AMOUNT', style: AppTextStyles.label()),
                    const SizedBox(height: AppSpacing.sm),
                    IntrinsicWidth(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.display(color: _accentColor),
                        decoration: InputDecoration(
                          prefixText: 'Rs. ',
                          prefixStyle: AppTextStyles.display(color: _accentColor),
                          border: InputBorder.none,
                          filled: false,
                          errorStyle: AppTextStyles.caption(color: AppColors.error),
                        ),
                        validator: (value) {
                          final v = double.tryParse((value ?? '').trim());
                          if (v == null || v <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Title', style: AppTextStyles.label()),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'e.g. Dinner'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Category', style: AppTextStyles.label()),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _pickCategory,
                borderRadius: BorderRadius.circular(AppRadius.button),
                child: InputDecorator(
                  decoration: const InputDecoration(),
                  child: Row(
                    children: [
                      if (_category != null) ...[
                        CategoryIcon(category: _category!, size: 28),
                        const SizedBox(width: AppSpacing.sm),
                        Text(_category!.name, style: AppTextStyles.body()),
                      ] else
                        Text('Select category', style: AppTextStyles.body(color: AppColors.textSecondary)),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Date', style: AppTextStyles.label()),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadius.button),
                child: InputDecorator(
                  decoration: const InputDecoration(),
                  child: Row(
                    children: [
                      Text(DateFormat('d MMMM yyyy').format(_date),
                          style: AppTextStyles.body()),
                      const Spacer(),
                      const Icon(Icons.calendar_today_rounded,
                          size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Note (optional)', style: AppTextStyles.label()),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Add a note'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
            child: _saving
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : const Text('Save'),
          ),
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment(String label, TransactionType t, Color color) {
      final selected = type == t;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.bodyStrong(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        children: [
          segment('Expense', TransactionType.expense, AppColors.expense),
          segment('Income', TransactionType.income, AppColors.income),
        ],
      ),
    );
  }
}