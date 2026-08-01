import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/reminder_settings_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/privacy_and_data_screen.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/providers/app_settings_provider.dart';
import 'package:finanzas_app_mobile/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/motion/app_page_route.dart';
import 'package:finanzas_app_mobile/core/motion/app_motion.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  Future<void> _openThemeSelector(BuildContext context) async {
    final themeProvider = context.read<ThemeProvider>();
    final currentMode = themeProvider.themeMode;

    await showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: AppMotion.modalStyle(context),
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.viewPaddingOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext).dividerColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Tema',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(sheetContext).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Selecciona el aspecto visual de la app.',
                style: TextStyle(
                  color: Theme.of(
                    sheetContext,
                  ).colorScheme.onSurface.withValues(alpha: 0.72),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              _buildThemeOption(
                context: sheetContext,
                label: 'Claro',
                icon: Icons.wb_sunny_outlined,
                isSelected: currentMode == ThemeMode.light,
                onTap: () async {
                  await themeProvider.setThemeMode(ThemeMode.light);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 10),
              _buildThemeOption(
                context: sheetContext,
                label: 'Oscuro',
                icon: Icons.nightlight_round,
                isSelected: currentMode == ThemeMode.dark,
                onTap: () async {
                  await themeProvider.setThemeMode(ThemeMode.dark);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 10),
              _buildThemeOption(
                context: sheetContext,
                label: 'Sistema',
                icon: Icons.settings_outlined,
                isSelected: currentMode == ThemeMode.system,
                onTap: () async {
                  await themeProvider.setThemeMode(ThemeMode.system);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setHomeInsightsVisibility(
    BuildContext context,
    bool value,
  ) async {
    final provider = context.read<AppSettingsProvider>();
    await provider.setShowHomeInsights(value);

    if (!context.mounted || provider.error == null) return;
    AppSnackbar.error(context, 'No se pudo guardar esta preferencia');
  }

  Future<void> _setSavingRecommendationsVisibility(
    BuildContext context,
    bool value,
  ) async {
    final provider = context.read<AppSettingsProvider>();
    await provider.setShowHomeSavingRecommendations(value);

    if (!context.mounted || provider.error == null) return;
    AppSnackbar.error(context, 'No se pudo guardar esta preferencia');
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    String? description,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              description,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.45),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      onTap: onTap,
      leading: _buildIconContainer(context, icon),
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildPreferenceTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      secondary: _buildIconContainer(context, icon),
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
          fontSize: 12,
        ),
      ),
      value: value,
      activeThumbColor: AppTheme.corporateGreen,
      activeTrackColor: AppTheme.corporateGreen.withValues(alpha: 0.35),
      onChanged: onChanged,
    );
  }

  Widget _buildIconContainer(BuildContext context, IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppTheme.corporateGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppTheme.corporateGreen, size: 21),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.corporateGreen.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.corporateGreen
                : theme.dividerColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.corporateGreen.withValues(alpha: 0.18)
                    : theme.dividerColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.corporateGreen
                    : theme.colorScheme.onSurface.withValues(alpha: 0.75),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.corporateGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettingsProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'Personaliza tu experiencia',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Elige cómo quieres ver y usar Finanzas App.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Apariencia',
              children: [
                _buildNavigationTile(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Tema',
                  subtitle: _themeModeLabel(themeProvider.themeMode),
                  onTap: () => _openThemeSelector(context),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _buildSection(
              context,
              title: 'Contenido de Inicio',
              description:
                  'Puedes ocultar recomendaciones para mantener tu panel más '
                  'compacto.',
              children: [
                _buildPreferenceTile(
                  context,
                  icon: Icons.insights_outlined,
                  title: 'Insights rápidos',
                  subtitle: 'Alertas y patrones de tu actividad financiera',
                  value: appSettings.showHomeInsights,
                  onChanged: (value) =>
                      _setHomeInsightsVisibility(context, value),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.45),
                ),
                _buildPreferenceTile(
                  context,
                  icon: Icons.savings_outlined,
                  title: 'Sugerencias de ahorro',
                  subtitle: 'Recomendaciones basadas en tus movimientos',
                  value: appSettings.showHomeSavingRecommendations,
                  onChanged: (value) =>
                      _setSavingRecommendationsVisibility(context, value),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _buildSection(
              context,
              title: 'Notificaciones',
              children: [
                _buildNavigationTile(
                  context,
                  icon: Icons.notifications_none_rounded,
                  title: 'Recordatorios y avisos',
                  subtitle: 'Pagos, gastos fijos y metas programadas',
                  onTap: () {
                    Navigator.push(
                      context,
                      AppPageRoute.build(
                        context,
                        builder: (_) => const ReminderSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
            _buildSection(
              context,
              title: 'Privacidad',
              children: [
                _buildNavigationTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacidad y datos',
                  subtitle: 'Consulta y administra los datos de tu cuenta',
                  onTap: () {
                    Navigator.push(
                      context,
                      AppPageRoute.build(
                        context,
                        builder: (_) => const PrivacyAndDataScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
