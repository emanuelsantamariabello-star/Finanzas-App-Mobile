import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/models/financial_goal_model.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'package:finanzas_app_mobile/providers/goal_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({super.key});

  @override
  State<FinancialGoalsScreen> createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen> {
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  String _formatAmount(double value) {
    final formatted = _currency.format(value).replaceAll('\$', '').trim();
    return '\$ $formatted';
  }

  Future<void> _openGoalForm([FinancialGoalModel? goal]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _GoalFormSheet(goal: goal),
    );

    if (!mounted || saved != true) return;
    AppSnackbar.success(context, 'Meta guardada correctamente');
  }

  Future<void> _editProgress(FinancialGoalModel goal) async {
    final controller = TextEditingController(
      text: goal.currentAmount.toStringAsFixed(0),
    );

    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Actualizar avance'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monto actual',
              prefixIcon: Icon(Icons.savings_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (updated != true || !mounted) return;

    final amount = double.tryParse(controller.text.trim());
    if (amount == null) {
      AppSnackbar.error(context, 'Monto inválido');
      return;
    }

    await context.read<GoalProvider>().updateGoalProgress(goal.id, amount);
    if (!mounted) return;
    AppSnackbar.info(context, 'Avance de meta actualizado');
  }

  Future<void> _deleteGoal(FinancialGoalModel goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar meta'),
          content: Text(
            'Se eliminará "${goal.title}" y su seguimiento actual.',
          ),
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

    await context.read<GoalProvider>().deleteGoal(goal.id);
    if (!mounted) return;
    AppSnackbar.info(context, 'Meta eliminada');
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final theme = Theme.of(context);
    final goals = goalProvider.goals;
    final balance =
        double.tryParse(dashboardProvider.data['balance'].toString()) ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Metas financieras')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openGoalForm,
        backgroundColor: AppTheme.corporateGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.flag_outlined),
        label: const Text('Nueva meta'),
      ),
      body: goalProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          Icons.account_balance_wallet_outlined,
                          color: AppTheme.corporateBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance disponible',
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
                              _formatAmount(balance),
                              style: TextStyle(
                                fontSize: 22,
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
                  child: goals.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    color: AppTheme.corporateGreen.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Icon(
                                    Icons.flag_outlined,
                                    size: 40,
                                    color: AppTheme.corporateGreen,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Aún no tienes metas',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Crea metas para seguir objetivos de ahorro, compras importantes o fondos específicos.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.72),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: goals.length,
                          separatorBuilder: (_, separatorIndex) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            final progress = goal.progress;
                            final isCoveredByBalance =
                                balance >= goal.remainingAmount;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: goal.isCompleted
                                      ? AppTheme.corporateGreen.withValues(
                                          alpha: 0.28,
                                        )
                                      : theme.dividerColor.withValues(
                                          alpha: 0.35,
                                        ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          goal.title,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      if (goal.isCompleted)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.corporateGreen
                                                .withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: const Text(
                                            'Cumplida',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.corporateGreen,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if ((goal.note ?? '').trim().isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      goal.note!.trim(),
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
                                      goal.isCompleted
                                          ? AppTheme.corporateGreen
                                          : AppTheme.corporateBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(progress * 100).round()}% completado',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        'Meta ${_formatAmount(goal.targetAmount)}',
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
                                      _GoalChip(
                                        label:
                                            'Actual ${_formatAmount(goal.currentAmount)}',
                                      ),
                                      _GoalChip(
                                        label:
                                            'Faltan ${_formatAmount(goal.remainingAmount)}',
                                      ),
                                      _GoalChip(
                                        label:
                                            'Fecha ${DateFormat('dd/MM/yyyy').format(goal.targetDate)}',
                                      ),
                                      if (isCoveredByBalance &&
                                          !goal.isCompleted)
                                        const _GoalChip(
                                          label:
                                              'Tu balance actual puede cubrirla',
                                          accent: AppTheme.corporateGreen,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () => _editProgress(goal),
                                        icon: const Icon(
                                          Icons.savings_outlined,
                                        ),
                                        tooltip: 'Actualizar avance',
                                      ),
                                      IconButton(
                                        onPressed: () => _openGoalForm(goal),
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Editar',
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteGoal(goal),
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

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.label, this.accent = AppTheme.corporateBlue});

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

class _GoalFormSheet extends StatefulWidget {
  const _GoalFormSheet({this.goal});

  final FinancialGoalModel? goal;

  @override
  State<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<_GoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  final _noteController = TextEditingController();

  late DateTime _targetDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _titleController.text = goal?.title ?? '';
    _targetController.text = goal != null
        ? goal.targetAmount.toStringAsFixed(0)
        : '';
    _currentController.text = goal != null
        ? goal.currentAmount.toStringAsFixed(0)
        : '0';
    _noteController.text = goal?.note ?? '';
    _targetDate =
        goal?.targetDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;
    setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final targetAmount = double.tryParse(_targetController.text.trim());
    final currentAmount = double.tryParse(_currentController.text.trim());

    if (targetAmount == null || currentAmount == null) {
      AppSnackbar.error(context, 'Montos inválidos');
      return;
    }

    setState(() => _isSaving = true);

    final goal = FinancialGoalModel(
      id: widget.goal?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: _targetDate,
      note: _noteController.text.trim(),
      isCompleted: currentAmount >= targetAmount,
      createdAt: widget.goal?.createdAt,
    );

    await context.read<GoalProvider>().saveGoal(goal);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.goal == null ? 'Nueva meta financiera' : 'Editar meta',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monto objetivo',
                  prefixIcon: Icon(Icons.track_changes_outlined),
                ),
                validator: (value) {
                  final amount = double.tryParse((value ?? '').trim());
                  if (amount == null || amount <= 0) {
                    return 'Ingresa un monto objetivo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currentController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monto actual',
                  prefixIcon: Icon(Icons.savings_outlined),
                ),
                validator: (value) {
                  final amount = double.tryParse((value ?? '').trim());
                  if (amount == null || amount < 0) {
                    return 'Ingresa un monto actual válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Nota',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha objetivo',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    suffixIcon: Icon(Icons.expand_more_rounded),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_targetDate)),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving
                        ? 'Guardando...'
                        : widget.goal == null
                        ? 'Guardar meta'
                        : 'Actualizar meta',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
