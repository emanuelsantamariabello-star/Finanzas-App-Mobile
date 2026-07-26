import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/models/budget_model.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_form_components.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_state_widgets.dart';
import 'package:finanzas_app_mobile/providers/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _syncUsage();
  }

  Future<void> _syncUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(SessionKeys.userId);
    if (userId == null || !mounted) return;
    await context.read<BudgetProvider>().syncUsage(userId);
  }

  String _formatAmount(double value) {
    final formatted = _currency.format(value).replaceAll('\$', '').trim();
    return '\$ $formatted';
  }

  Future<void> _openBudgetForm([BudgetModel? budget]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BudgetFormSheet(budget: budget),
    );

    if (!mounted || saved != true) return;
    AppSnackbar.success(context, 'Presupuesto guardado correctamente');
    await _syncUsage();
  }

  Future<void> _deleteBudget(BudgetModel budget) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar presupuesto'),
          content: Text('Se eliminará el presupuesto de ${budget.category}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;
    await context.read<BudgetProvider>().deleteBudget(budget.id);
    if (!mounted) return;
    AppSnackbar.info(context, 'Presupuesto eliminado');
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final theme = Theme.of(context);
    final budgets = budgetProvider.budgets;

    return Scaffold(
      appBar: AppBar(title: const Text('Presupuestos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBudgetForm,
        backgroundColor: AppTheme.corporateGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.pie_chart_outline_rounded),
        label: const Text('Nuevo presupuesto'),
      ),
      body: budgetProvider.isLoading
          ? const AppLoadingState(message: 'Cargando presupuestos…')
          : budgetProvider.error != null && budgets.isEmpty
          ? AppErrorState(
              message: budgetProvider.error!,
              onRetry: budgetProvider.loadBudgets,
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.corporateBlue.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.corporateBlue.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          color: AppTheme.corporateBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Control mensual',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              budgetProvider.overBudgetCount == 0
                                  ? 'Sin categorías excedidas'
                                  : '${budgetProvider.overBudgetCount} categoría(s) excedidas',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: budgets.isEmpty
                      ? AppEmptyState(
                          icon: Icons.pie_chart_outline_rounded,
                          title: 'Aún no tienes presupuestos',
                          message:
                              'Define límites por categoría para controlar cuánto gastas cada mes.',
                          accentColor: AppTheme.corporateGreen,
                          actionLabel: 'Crear presupuesto',
                          onAction: () => _openBudgetForm(),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: budgets.length,
                          separatorBuilder: (_, separatorIndex) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final budget = budgets[index];
                            final spent = budgetProvider.spentForCategory(
                              budget.category,
                            );
                            final progress = budget.limitAmount <= 0
                                ? 0.0
                                : (spent / budget.limitAmount).clamp(0.0, 1.0);
                            final isExceeded = spent > budget.limitAmount;
                            final remaining = budget.limitAmount - spent;
                            final accent = isExceeded
                                ? AppTheme.corporateRed
                                : AppTheme.corporateGreen;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          budget.category,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      if (isExceeded)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.corporateRed
                                                .withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: const Text(
                                            'Excedido',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.corporateRed,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if ((budget.note ?? '')
                                      .trim()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      budget.note!.trim(),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.72),
                                          ),
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(999),
                                    backgroundColor: theme.dividerColor
                                        .withValues(alpha: 0.22),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      accent,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(progress * 100).round()}% consumido',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        'Límite ${_formatAmount(budget.limitAmount)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.72),
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _BudgetChip(
                                        label:
                                            'Gastado ${_formatAmount(spent)}',
                                        accent: accent,
                                      ),
                                      _BudgetChip(
                                        label: isExceeded
                                            ? 'Exceso ${_formatAmount(spent - budget.limitAmount)}'
                                            : 'Disponible ${_formatAmount(remaining > 0 ? remaining : 0)}',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _openBudgetForm(budget),
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Editar',
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteBudget(budget),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppTheme.corporateRed,
                                        ),
                                        tooltip: 'Eliminar',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _BudgetChip extends StatelessWidget {
  const _BudgetChip({
    required this.label,
    this.accent = AppTheme.corporateBlue,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
    );
  }
}

class _BudgetFormSheet extends StatefulWidget {
  const _BudgetFormSheet({this.budget});

  final BudgetModel? budget;

  @override
  State<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<_BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _limitController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final budget = widget.budget;
    _categoryController.text = budget?.category ?? '';
    _limitController.text = budget != null
        ? budget.limitAmount.toStringAsFixed(0)
        : '';
    _noteController.text = budget?.note ?? '';
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _limitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final limitAmount = double.tryParse(_limitController.text.trim());
    if (limitAmount == null || limitAmount <= 0) {
      AppSnackbar.error(context, 'Ingresa un límite válido');
      return;
    }

    setState(() => _isSaving = true);

    final budget = BudgetModel(
      id: widget.budget?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      category: _categoryController.text.trim(),
      limitAmount: limitAmount,
      note: _noteController.text.trim(),
      createdAt: widget.budget?.createdAt,
    );

    await context.read<BudgetProvider>().saveBudget(budget);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      includeKeyboardInset: true,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.budget == null
                  ? 'Nuevo presupuesto'
                  : 'Editar presupuesto',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Ingresa una categoría';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _limitController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Límite mensual',
                prefixIcon: Icon(Icons.track_changes_outlined),
              ),
              validator: (value) {
                final amount = double.tryParse((value ?? '').trim());
                if (amount == null || amount <= 0) {
                  return 'Ingresa un límite válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nota',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
            const SizedBox(height: 18),
            AppPrimaryButton(
              label: widget.budget == null
                  ? 'Guardar presupuesto'
                  : 'Actualizar presupuesto',
              loadingLabel: 'Guardando…',
              icon: Icons.save_outlined,
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
