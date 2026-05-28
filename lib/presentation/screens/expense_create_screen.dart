import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/data/services/expense_service.dart';
import 'package:finanzas_app_mobile/data/services/income_service.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
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

  Future<void> loadIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

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
    final userId = prefs.getInt('userId');

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
        AppSnackbar.error(
          context,
          response['message']?.toString() ?? 'No se pudo guardar el gasto',
        );
      }
    } catch (e) {
      AppSnackbar.error(context, 'Error al guardar el gasto');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? "Editar gasto" : "Nuevo gasto")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoadingIncomes
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Monto"),
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
                      decoration: const InputDecoration(
                        labelText: "Seleccionar ingreso",
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: "Nota"),
                    ),

                    const SizedBox(height: 12),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Fecha"),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: isLoading ? null : saveExpense,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Guardar"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
