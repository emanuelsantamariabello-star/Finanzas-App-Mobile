import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/models/category_suggestion_model.dart';
import 'package:finanzas_app_mobile/data/services/category_suggestion_service.dart';
import 'package:finanzas_app_mobile/data/services/expense_service.dart';
import 'package:finanzas_app_mobile/data/services/income_service.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_form_components.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';

class ExpenseCreateScreen extends StatefulWidget {
  final Map<String, dynamic>? expense;

  const ExpenseCreateScreen({super.key, this.expense});

  @override
  State<ExpenseCreateScreen> createState() => _ExpenseCreateScreenState();
}

class _ExpenseCreateScreenState extends State<ExpenseCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  List incomes = [];
  int? selectedIncomeId;
  DateTime selectedDate = DateTime.now();

  bool isLoading = false;
  bool isLoadingIncomes = true;
  CategorySuggestionModel? expenseSuggestion;

  @override
  void initState() {
    super.initState();
    loadIncomes();

    if (isEditMode) {
      amountController.text = widget.expense!['amount'].toString();
      noteController.text = widget.expense!['note'] ?? '';
      selectedIncomeId = widget.expense!['income_id'];
      selectedDate = _parseDate(widget.expense!['expense_date']);
    }

    noteController.addListener(_updateSuggestion);
    _updateSuggestion();
  }

  bool get isEditMode => widget.expense != null;

  DateTime _parseDate(dynamic rawDate) {
    final value = rawDate?.toString().trim() ?? '';
    if (value.isEmpty) return DateTime.now();

    return DateTime.tryParse(value) ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _updateSuggestion() {
    final nextSuggestion = CategorySuggestionService.suggestExpenseCategory(
      noteController.text,
    );

    if (expenseSuggestion?.label == nextSuggestion?.label &&
        expenseSuggestion?.confidence == nextSuggestion?.confidence) {
      return;
    }

    setState(() => expenseSuggestion = nextSuggestion);
  }

  Future<void> loadIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(SessionKeys.userId);

    if (userId == null) return;

    try {
      final response = await IncomeService.getIncomes(userId);

      if (response['success']) {
        setState(() {
          incomes = response['data'];
          isLoadingIncomes = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingIncomes = false;
      });
    }
  }

  Future<void> saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(SessionKeys.userId);

    if (!mounted) return;

    if (userId == null) {
      AppSnackbar.error(context, 'Usuario no identificado');
      return;
    }

    if (!isEditMode && selectedIncomeId == null) {
      AppSnackbar.info(context, 'Selecciona el ingreso asociado');
      return;
    }

    setState(() => isLoading = true);

    try {
      final amount = amountController.text;
      final note = noteController.text;
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      late Map<String, dynamic> response;

      if (isEditMode) {
        response = await ExpenseService.updateExpense(
          id: widget.expense!['id'],
          amount: amount,
          note: note,
          expenseDate: formattedDate,
        );
      } else {
        response = await ExpenseService.createExpense(
          userId: userId,
          incomeId: selectedIncomeId!,
          amount: amount,
          note: note,
          expenseDate: formattedDate,
        );
      }

      if (response['success']) {
        if (!mounted) return;
        context.read<DashboardProvider>().refreshDashboard(userId);
        final msg = isEditMode
            ? 'Gasto actualizado correctamente'
            : 'Gasto agregado correctamente';
        AppSnackbar.success(context, msg);
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        AppSnackbar.error(
          context,
          response['message']?.toString() ?? 'No se pudo guardar el gasto',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        apiErrorMessage(e, fallback: 'Error al guardar el gasto'),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    noteController.removeListener(_updateSuggestion);
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Widget _buildSuggestionCard(BuildContext context) {
    if (expenseSuggestion == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final suggestion = expenseSuggestion!;
    final confidenceLabel = suggestion.confidence >= 0.5 ? 'Alta' : 'Media';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.corporateBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.corporateBlue.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.corporateBlue.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.corporateBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categoría sugerida',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.corporateBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confianza $confidenceLabel según la descripción ingresada.',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? "Editar gasto" : "Nuevo gasto")),
      body: AppFormScrollView(
        padding: const EdgeInsets.all(20),
        child: isLoadingIncomes
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: AppFormDecoration.input(
                        context: context,
                        label: 'Monto',
                        icon: Icons.attach_money,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Ingrese un monto" : null,
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      initialValue: selectedIncomeId,
                      items: incomes.map<DropdownMenuItem<int>>((income) {
                        return DropdownMenuItem<int>(
                          value: income['id'],
                          child: Text(
                            "${income['type']} - \$${income['amount']}",
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedIncomeId = value);
                      },
                      decoration: AppFormDecoration.input(
                        context: context,
                        label: 'Seleccionar ingreso',
                        icon: Icons.account_balance_wallet,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: noteController,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: AppFormDecoration.input(
                        context: context,
                        label: 'Nota',
                        icon: Icons.note_alt_outlined,
                      ),
                    ),

                    const SizedBox(height: 12),
                    _buildSuggestionCard(context),
                    if (expenseSuggestion != null) const SizedBox(height: 12),

                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: AppFormDecoration.input(
                          context: context,
                          label: 'Fecha',
                          icon: Icons.calendar_today_outlined,
                          suffixIcon: const Icon(Icons.expand_more_rounded),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    AppPrimaryButton(
                      label: isEditMode ? 'Actualizar gasto' : 'Guardar gasto',
                      loadingLabel: isEditMode ? 'Actualizando…' : 'Guardando…',
                      icon: Icons.save_outlined,
                      isLoading: isLoading,
                      onPressed: saveExpense,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
