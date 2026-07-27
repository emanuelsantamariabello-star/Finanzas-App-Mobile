import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/motion/app_motion.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/models/reminder_model.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_confirmation_dialog.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_form_components.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_state_widgets.dart';
import 'package:finanzas_app_mobile/providers/reminder_provider.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy - hh:mm a', 'es_CO');

  String _typeLabel(String type) {
    switch (type) {
      case 'fixed_expense':
        return 'Gasto fijo';
      case 'goal':
        return 'Meta';
      case 'payment':
      default:
        return 'Pago';
    }
  }

  String _frequencyLabel(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Diario';
      case 'weekly':
        return 'Semanal';
      case 'biweekly':
        return 'Quincenal';
      case 'monthly':
      default:
        return 'Mensual';
    }
  }

  Future<void> _openReminderForm([ReminderModel? reminder]) async {
    final saved = await showModalBottomSheet<Object?>(
      context: context,
      sheetAnimationStyle: AppMotion.modalStyle(context),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ReminderFormSheet(reminder: reminder),
    );

    if (!mounted || saved == null) return;

    if (saved == 'saved_disabled') {
      AppSnackbar.info(
        context,
        'Recordatorio guardado sin activar notificaciones',
      );
      return;
    }

    if (saved == true) {
      AppSnackbar.success(context, 'Recordatorio guardado correctamente');
    }
  }

  Future<void> _deleteReminder(ReminderModel reminder) async {
    final confirm = await showAppConfirmationDialog(
      context,
      title: 'Eliminar recordatorio',
      message: 'Se eliminará "${reminder.title}" de forma permanente.',
      confirmLabel: 'Eliminar',
      icon: Icons.notifications_off_outlined,
    );

    if (!confirm || !mounted) return;

    await context.read<ReminderProvider>().deleteReminder(reminder.id);
    if (!mounted) return;
    AppSnackbar.success(context, 'Recordatorio eliminado');
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();
    final reminders = reminderProvider.reminders;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openReminderForm,
        backgroundColor: AppTheme.corporateGreen,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Nuevo'),
      ),
      body: reminderProvider.isLoading
          ? const AppLoadingState(message: 'Cargando recordatorios…')
          : reminderProvider.error != null && reminders.isEmpty
          ? AppErrorState(
              message: reminderProvider.error!,
              onRetry: reminderProvider.loadReminders,
            )
          : reminders.isEmpty
          ? AppEmptyState(
              icon: Icons.notifications_active_outlined,
              title: 'Aún no tienes recordatorios',
              message:
                  'Programa avisos para pagos, gastos fijos o metas y recíbelos a tiempo.',
              accentColor: AppTheme.corporateGreen,
              actionLabel: 'Crear recordatorio',
              onAction: () => _openReminderForm(),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              separatorBuilder: (_, separatorIndex) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.corporateGreen.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppTheme.corporateGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_typeLabel(reminder.type)} · ${_frequencyLabel(reminder.frequency)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.68),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: reminder.isEnabled,
                            onChanged: (value) async {
                              await context
                                  .read<ReminderProvider>()
                                  .toggleReminder(reminder.id, value);
                            },
                          ),
                        ],
                      ),
                      if ((reminder.description ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          reminder.description!.trim(),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.65,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _dateFormat.format(reminder.scheduledAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.68,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => _openReminderForm(reminder),
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            onPressed: () => _deleteReminder(reminder),
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
    );
  }
}

class _ReminderFormSheet extends StatefulWidget {
  const _ReminderFormSheet({this.reminder});

  final ReminderModel? reminder;

  @override
  State<_ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<_ReminderFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String _type;
  late String _frequency;
  late bool _isEnabled;
  late DateTime _scheduledAt;
  late TimeOfDay _timeOfDay;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    _titleController.text = reminder?.title ?? '';
    _descriptionController.text = reminder?.description ?? '';
    _type = reminder?.type ?? 'payment';
    _frequency = reminder?.frequency ?? 'monthly';
    _isEnabled = reminder?.isEnabled ?? true;
    _scheduledAt =
        reminder?.scheduledAt ?? DateTime.now().add(const Duration(days: 1));
    _timeOfDay = TimeOfDay.fromDateTime(_scheduledAt);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _scheduledAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _timeOfDay.hour,
        _timeOfDay.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay,
    );

    if (picked == null || !mounted) return;

    setState(() {
      _timeOfDay = picked;
      _scheduledAt = DateTime(
        _scheduledAt.year,
        _scheduledAt.month,
        _scheduledAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ReminderProvider>();
    final reminder = ReminderModel(
      id:
          widget.reminder?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _type,
      frequency: _frequency,
      scheduledAt: _scheduledAt,
      isEnabled: _isEnabled,
      createdAt: widget.reminder?.createdAt,
    );

    setState(() => _isSaving = true);

    try {
      var reminderToSave = reminder;

      if (_isEnabled) {
        final permissionGranted = await provider.ensurePermission();
        if (!mounted) return;

        if (!permissionGranted) {
          reminderToSave = reminder.copyWith(isEnabled: false);
        }
      }

      await provider.saveReminder(reminderToSave);
      if (!mounted) return;
      Navigator.pop(
        context,
        reminderToSave.isEnabled ? true : 'saved_disabled',
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'No se pudo guardar el recordatorio');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('dd/MM/yyyy', 'es_CO');
    final timeLabel = _timeOfDay.format(context);

    return AppFormScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      includeKeyboardInset: true,
      includeBottomSafeInset: true,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.reminder == null
                  ? 'Nuevo recordatorio'
                  : 'Editar recordatorio',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.title_rounded),
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
              controller: _descriptionController,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'payment', child: Text('Pago')),
                DropdownMenuItem(
                  value: 'fixed_expense',
                  child: Text('Gasto fijo'),
                ),
                DropdownMenuItem(value: 'goal', child: Text('Meta')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _type = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frecuencia',
                prefixIcon: Icon(Icons.repeat_rounded),
              ),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Diario')),
                DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                DropdownMenuItem(value: 'biweekly', child: Text('Quincenal')),
                DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _frequency = value);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha base',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(formatter.format(_scheduledAt)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hora',
                        prefixIcon: Icon(Icons.access_time_rounded),
                      ),
                      child: Text(timeLabel),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Activar recordatorio'),
              subtitle: const Text('Se programará automáticamente al guardar.'),
              value: _isEnabled,
              onChanged: (value) {
                setState(() => _isEnabled = value);
              },
            ),
            const SizedBox(height: 16),
            AppPrimaryButton(
              label: widget.reminder == null
                  ? 'Guardar recordatorio'
                  : 'Actualizar recordatorio',
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
