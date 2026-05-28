import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/data/services/income_service.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';

class IncomeCreateScreen extends StatefulWidget {
  final Map<String, dynamic>? income;

  const IncomeCreateScreen({super.key, this.income});

  @override
  State<IncomeCreateScreen> createState() => _IncomeCreateScreenState();
}

class _IncomeCreateScreenState extends State<IncomeCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String type = 'mensual';
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.income != null) {
      amountController.text = widget.income!['amount'].toString();
      noteController.text = widget.income!['note'] ?? '';
      type = widget.income!['type'];
      selectedDate = _parseDate(widget.income!['income_date']);
    }
  }

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

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> saveIncome() async {
    if (isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      AppSnackbar.error(context, 'Usuario no identificado');
      return;
    }

    setState(() => isLoading = true);

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      late final Map<String, dynamic> response;

      if (widget.income == null) {
        // 👉 CREAR
        response = await IncomeService.createIncome(
          userId: userId,
          amount: amountController.text.trim(),
          type: type,
          note: noteController.text.trim(),
          date: formattedDate,
        );
      } else {
        // 👉 EDITAR
        response = await IncomeService.updateIncome(
          id: widget.income!['id'],
          userId: userId,
          amount: amountController.text.trim(),
          type: type,
          note: noteController.text.trim(),
          date: formattedDate,
        );
      }

      if (response['success'] == true) {
        if (!mounted) return;
        context.read<DashboardProvider>().refreshDashboard(userId);

        final msg = widget.income == null
            ? 'Ingreso agregado correctamente'
            : 'Ingreso actualizado correctamente';
        AppSnackbar.success(context, msg);

        // ✅ Volver y refrescar lista
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        AppSnackbar.error(
          context,
          response['message']?.toString() ?? 'No se pudo guardar el ingreso',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error al guardar el ingreso');
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.income == null ? "Nuevo ingreso" : "Editar ingreso"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 💰 MONTO
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: "Monto"),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return "Ingrese un monto";
                  if (double.tryParse(v) == null) {
                    return "Monto inválido";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // 📊 TIPO
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'mensual', child: Text("Mensual")),
                  DropdownMenuItem(
                    value: 'quincenal',
                    child: Text("Quincenal"),
                  ),
                  DropdownMenuItem(value: 'otro', child: Text("Otro")),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => type = value);
                },
                decoration: const InputDecoration(labelText: "Tipo"),
              ),

              const SizedBox(height: 12),

              // 📝 NOTA
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: "Nota"),
              ),

              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Fecha"),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),

              const SizedBox(height: 20),

              // 🚀 BOTÓN
              ElevatedButton(
                onPressed: isLoading ? null : saveIncome,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
