import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/motion/app_page_route.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/providers/budget_provider.dart';
import 'package:finanzas_app_mobile/data/models/saving_recommendation_model.dart';
import 'package:finanzas_app_mobile/data/models/smart_insight_model.dart';
import 'package:finanzas_app_mobile/data/services/saving_recommendation_service.dart';
import 'package:finanzas_app_mobile/data/services/smart_insight_service.dart';
import 'package:finanzas_app_mobile/data/services/smart_summary_service.dart';
import 'package:finanzas_app_mobile/presentation/screens/budgets_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/financial_goals_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/reminder_settings_screen.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_animated_number_text.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_pressable.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_state_widgets.dart';
import 'package:finanzas_app_mobile/presentation/widgets/internal_notifications_panel.dart';
import 'package:finanzas_app_mobile/providers/app_settings_provider.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'package:finanzas_app_mobile/providers/reminder_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  final currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  int? userId;

  void loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getInt(SessionKeys.userId);

    setState(() {
      name = prefs.getString(SessionKeys.userName) ?? '';
      userId = storedUserId;
    });

    if (storedUserId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<DashboardProvider>().refreshDashboard(storedUserId);
        context.read<BudgetProvider>().syncUsage(storedUserId);
      });
    }
  }

  String formatAmount(dynamic amount) {
    final value = _numericValue(amount);
    final formatted = currency.format(value).replaceAll('\$', '').trim();
    return '\$ $formatted';
  }

  double _numericValue(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required dynamic amount,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 6),
                AppAnimatedNumberText(
                  value: _numericValue(amount),
                  formatter: formatAmount,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required String label,
    required dynamic value,
    required IconData icon,
    required Color accentColor,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 12),
            AppAnimatedNumberText(
              value: _numericValue(value),
              formatter: (animatedValue) => animatedValue.round().toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: 0.2,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSmartSummaryCard(
    BuildContext context, {
    required String title,
    required String message,
    required String highlight,
    required IconData icon,
    required Color color,
    required List<String> chips,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            highlight,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map(
                    (chip) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        chip,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightsSection(
    BuildContext context,
    List<SmartInsightModel> insights,
  ) {
    final theme = Theme.of(context);

    return _buildSectionCard(
      context,
      title: 'Insights rápidos',
      children: insights
          .map(
            (insight) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: insight.color.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: insight.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(insight.icon, color: insight.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insight.message,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.72,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildRecommendationsSection(
    BuildContext context,
    List<SavingRecommendationModel> recommendations,
  ) {
    final theme = Theme.of(context);

    return _buildSectionCard(
      context,
      title: 'Sugerencias de ahorro',
      children: recommendations
          .map(
            (recommendation) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: recommendation.color.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: recommendation.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      recommendation.icon,
                      color: recommendation.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recommendation.message,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.72,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDashboardEmptyBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.corporateGreen.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: AppTheme.corporateGreen,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu dashboard está listo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Aún no hay movimientos. Registra tu primer ingreso o gasto para empezar a ver estadísticas y balance.',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 1.6).toDouble();
    final quickAccessHeight = 116 + ((textScale - 1) * 44);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos rápidos',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tus herramientas financieras a un toque',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: quickAccessHeight,
          child: ListView(
            key: const ValueKey('home_quick_access_list'),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildQuickAccessCard(
                context,
                icon: Icons.notifications_none_rounded,
                title: 'Recordatorios',
                subtitle: 'Pagos y avisos',
                color: AppTheme.corporateBlue,
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
              const SizedBox(width: 12),
              _buildQuickAccessCard(
                context,
                icon: Icons.flag_outlined,
                title: 'Metas',
                subtitle: 'Objetivos de ahorro',
                color: AppTheme.corporateGreen,
                onTap: () {
                  Navigator.push(
                    context,
                    AppPageRoute.build(
                      context,
                      builder: (_) => const FinancialGoalsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildQuickAccessCard(
                context,
                icon: Icons.pie_chart_outline_rounded,
                title: 'Presupuestos',
                subtitle: 'Límites por categoría',
                color: AppTheme.corporateRed,
                onTap: () {
                  Navigator.push(
                    context,
                    AppPageRoute.build(
                      context,
                      builder: (_) => const BudgetsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 1.6).toDouble();
    final cardWidth = 132 + ((textScale - 1) * 36);

    return SizedBox(
      width: cardWidth,
      child: Semantics(
        button: true,
        label: '$title, $subtitle',
        excludeSemantics: true,
        child: Material(
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.45)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.58,
                      ),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).withPressFeedback();
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettingsProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final reminderProvider = context.watch<ReminderProvider>();
    final dashboardData = dashboardProvider.data;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final showInsights =
        appSettings.isInitialized && appSettings.showHomeInsights;
    final showSavingRecommendations =
        appSettings.isInitialized && appSettings.showHomeSavingRecommendations;
    final smartSummary = SmartSummaryService.build(
      dashboardData: dashboardData,
      reminders: reminderProvider.reminders,
      now: now,
    );
    final insights = showInsights
        ? SmartInsightService.build(
            dashboardData: dashboardData,
            reminders: reminderProvider.reminders,
            now: now,
            budgets: budgetProvider.budgets,
            monthlySpentByCategory: budgetProvider.monthlySpentByCategory,
          )
        : const <SmartInsightModel>[];
    final recommendations = showSavingRecommendations
        ? SavingRecommendationService.build(
            dashboardData: dashboardData,
            reminders: reminderProvider.reminders,
          )
        : const <SavingRecommendationModel>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas App'),
        actions: const [InternalNotificationAction()],
      ),
      body: dashboardProvider.isLoading && dashboardData.isEmpty
          ? const AppLoadingState(
              message: 'Preparando tu resumen financiero…',
            ).withStateTransition('loading')
          : dashboardProvider.error != null && dashboardData.isEmpty
          ? AppErrorState(
              message: dashboardProvider.error!,
              onRetry: loadUser,
            ).withStateTransition('error')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido $name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Así se mueve tu dinero hoy',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.72,
                      ),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildQuickAccessSection(context),
                  const SizedBox(height: 24),
                  _buildSmartSummaryCard(
                    context,
                    title: smartSummary.title,
                    message: smartSummary.message,
                    highlight: smartSummary.highlight,
                    icon: smartSummary.icon,
                    color: smartSummary.color,
                    chips: smartSummary.chips,
                  ),
                  if ((dashboardData['income_count'] ?? 0) == 0 &&
                      (dashboardData['expense_count'] ?? 0) == 0) ...[
                    _buildDashboardEmptyBanner(context),
                    const SizedBox(height: 12),
                  ],
                  _buildSummaryCard(
                    context,
                    title: 'Total ingresos',
                    amount: dashboardData['total_income'],
                    color: AppTheme.corporateGreen,
                    icon: Icons.arrow_downward_rounded,
                  ),
                  _buildSummaryCard(
                    context,
                    title: 'Total gastos',
                    amount: dashboardData['total_expense'],
                    color: AppTheme.corporateRed,
                    icon: Icons.arrow_upward_rounded,
                  ),
                  _buildSummaryCard(
                    context,
                    title: 'Balance',
                    amount: dashboardData['balance'],
                    color: AppTheme.corporateBlue,
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    context,
                    title: 'Resumen del mes',
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.corporateGreen.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.corporateGreen.withValues(
                                      alpha: 0.22,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: AppTheme.corporateGreen
                                                .withValues(alpha: 0.16),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_downward_rounded,
                                            color: AppTheme.corporateGreen,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Ingresos del mes',
                                            style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.75),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    AppAnimatedNumberText(
                                      value: _numericValue(
                                        dashboardData['month_income'],
                                      ),
                                      formatter: formatAmount,
                                      style: const TextStyle(
                                        color: AppTheme.corporateGreen,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.corporateRed.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.corporateRed.withValues(
                                      alpha: 0.22,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: AppTheme.corporateRed
                                                .withValues(alpha: 0.16),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_upward_rounded,
                                            color: AppTheme.corporateRed,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Gastos del mes',
                                            style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.75),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    AppAnimatedNumberText(
                                      value: _numericValue(
                                        dashboardData['month_expense'],
                                      ),
                                      formatter: formatAmount,
                                      style: const TextStyle(
                                        color: AppTheme.corporateRed,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (showInsights) ...[
                    const SizedBox(height: 12),
                    _buildInsightsSection(context, insights),
                  ],
                  if (showSavingRecommendations) ...[
                    const SizedBox(height: 12),
                    _buildRecommendationsSection(context, recommendations),
                  ],
                  const SizedBox(height: 12),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMiniStat(
                          context,
                          label: 'Cantidad de ingresos',
                          value: dashboardData['income_count'] ?? 0,
                          icon: Icons.trending_up_rounded,
                          accentColor: AppTheme.corporateGreen,
                          description: 'Ingresos registrados',
                        ),
                        const SizedBox(width: 12),
                        _buildMiniStat(
                          context,
                          label: 'Cantidad de gastos',
                          value: dashboardData['expense_count'] ?? 0,
                          icon: Icons.trending_down_rounded,
                          accentColor: AppTheme.corporateRed,
                          description: 'Gastos registrados',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).withStateTransition('content'),
    );
  }
}
