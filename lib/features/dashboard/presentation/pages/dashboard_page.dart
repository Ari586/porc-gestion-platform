import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/stat_mini_card.dart';
import '../widgets/dashboard_highlight_card.dart';
import '../widgets/dashboard_module_tile.dart';
import '../widgets/insemination_outcome_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.s18),
                  _buildWelcomeBanner(context),
                  const SizedBox(height: AppSpacing.s18),
                  _buildHighlightCards(context),
                  const SizedBox(height: AppSpacing.s18),
                  _buildQuickModules(context),
                  const SizedBox(height: AppSpacing.s18),
                  _buildInseminationChart(context),
                  const SizedBox(height: AppSpacing.s18),
                  _buildKpiSection(context),
                  const SizedBox(height: AppSpacing.s18),
                  _buildRecentActivity(context),
                  const SizedBox(height: AppSpacing.s16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(now);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tableau de bord',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                dateStr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s6,
          ),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.s6),
              Text(
                'Synchronisé',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Bonjour'
        : hour < 18
            ? 'Bon après-midi'
            : 'Bonsoir';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting !',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  'Vue d\'ensemble de votre exploitation',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.piggyBank,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCards(BuildContext context) {
    final highlights = [
      DashboardHighlightData(
        title: 'Fertilité IA',
        value: '78%',
        caption: '14 dossiers confirmés',
        icon: LucideIcons.trendingUp,
        startColor: AppColors.primaryDark,
        endColor: AppColors.success,
      ),
      DashboardHighlightData(
        title: 'Diagnostics urgents',
        value: '2',
        caption: 'Contrôle terrain à lancer',
        icon: LucideIcons.alertTriangle,
        startColor: AppColors.warning,
        endColor: AppColors.error,
      ),
      DashboardHighlightData(
        title: 'Mise-bas proches',
        value: '3',
        caption: '5 IA encore en attente',
        icon: LucideIcons.piggyBank,
        startColor: AppColors.primaryDark,
        endColor: AppColors.secondary,
      ),
      DashboardHighlightData(
        title: 'Ventes 7 jours',
        value: '1.2M Ar',
        caption: 'Flux commercial stable',
        icon: Icons.payments_outlined,
        startColor: AppColors.info,
        endColor: AppColors.primaryLight,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 560
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.s12,
            mainAxisSpacing: AppSpacing.s12,
            childAspectRatio: 2.2,
          ),
          itemCount: highlights.length,
          itemBuilder: (context, index) => DashboardHighlightCard(
            data: highlights[index],
          ),
        );
      },
    );
  }

  Widget _buildQuickModules(BuildContext context) {
    final modules = [
      DashboardModuleData(
        label: 'Reproduction',
        value: '18',
        icon: LucideIcons.syringe,
        color: AppColors.primary,
        route: '/inseminations',
      ),
      DashboardModuleData(
        label: 'Santé',
        value: '12',
        icon: LucideIcons.shieldCheck,
        color: AppColors.info,
        route: '/health',
      ),
      DashboardModuleData(
        label: 'Stock',
        value: 'Stable',
        icon: LucideIcons.package,
        color: AppColors.warning,
        route: '/commercial',
      ),
      DashboardModuleData(
        label: 'Messages',
        value: 'Aucun',
        icon: Icons.forum_outlined,
        color: AppColors.secondary,
        route: '/messenger',
      ),
    ];

    return SectionCard(
      title: 'Modules rapides',
      subtitle: 'Accès direct aux fonctionnalités',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppSpacing.s10,
              mainAxisSpacing: AppSpacing.s10,
              childAspectRatio: 1.8,
            ),
            itemCount: modules.length,
            itemBuilder: (context, index) => DashboardModuleTile(
              data: modules[index],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInseminationChart(BuildContext context) {
    return const InseminationOutcomeChart(
      successCount: 14,
      failedCount: 2,
      pendingCount: 5,
    );
  }

  Widget _buildKpiSection(BuildContext context) {
    return SectionCard(
      title: 'Indicateurs zootechniques',
      subtitle: 'Performance de l\'élevage',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.s10,
            mainAxisSpacing: AppSpacing.s10,
            childAspectRatio: 1.6,
            children: const [
              StatMiniCard(
                label: 'Nés vivants/portée',
                value: '12.3',
                icon: LucideIcons.baby,
                iconColor: AppColors.success,
              ),
              StatMiniCard(
                label: 'Sevrés/portée',
                value: '10.8',
                icon: LucideIcons.heart,
                iconColor: AppColors.primary,
              ),
              StatMiniCard(
                label: 'Taux fertilité',
                value: '78%',
                icon: LucideIcons.trendingUp,
                iconColor: AppColors.info,
              ),
              StatMiniCard(
                label: 'GMQ engraissement',
                value: '820g/j',
                icon: LucideIcons.barChart2,
                iconColor: AppColors.warning,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return SectionCard(
      title: 'Activité récente',
      subtitle: 'Dernières actions enregistrées',
      child: Column(
        children: [
          _buildActivityRow(
            context,
            icon: LucideIcons.syringe,
            color: AppColors.primary,
            title: 'Insémination dose 1',
            subtitle: 'Truie T-042 x Verrat V-008',
            time: 'Il y a 2h',
          ),
          const Divider(height: 1),
          _buildActivityRow(
            context,
            icon: LucideIcons.shieldCheck,
            color: AppColors.success,
            title: 'Vaccination effectuée',
            subtitle: 'Lot Parvo/Erysipèle — 8 truies',
            time: 'Il y a 5h',
          ),
          const Divider(height: 1),
          _buildActivityRow(
            context,
            icon: LucideIcons.piggyBank,
            color: AppColors.info,
            title: 'Mise-bas enregistrée',
            subtitle: 'Truie T-028 — 13 nés vivants',
            time: 'Hier',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
