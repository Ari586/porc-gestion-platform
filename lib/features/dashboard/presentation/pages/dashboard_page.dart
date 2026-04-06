import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/stat_mini_card.dart';
import '../../../../core/providers/language_provider.dart';
import '../widgets/dashboard_highlight_card.dart';
import '../widgets/dashboard_module_tile.dart';
import '../widgets/insemination_outcome_chart.dart';

import '../../../boars/domain/providers.dart';
import '../../../sows/domain/providers.dart';
import '../../../insemination/domain/providers.dart';
import '../../../health/domain/providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  String _t(WidgetRef ref, String fr, String mg) {
    final isMg = ref.watch(languageProvider) == 'Malagasy';
    return isMg ? mg : fr;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boarsAsync = ref.watch(boarListProvider);
    final sowsAsync = ref.watch(sowListProvider);
    final iaStats = ref.watch(inseminationStatsProvider);
    final healthAsync = ref.watch(healthRecordListProvider);
    final isMg = ref.watch(languageProvider) == 'Malagasy';

    final totalLivestock = (boarsAsync.valueOrNull?.length ?? 0) + 
                          (sowsAsync.valueOrNull?.length ?? 0);
    
    final iaSuccessRate = iaStats['total'] == 0 
        ? 0 
        : ((iaStats['confirmed'] ?? 0) * 100 / iaStats['total']!).round();

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
                  _buildHeader(context, ref),
                  const SizedBox(height: AppSpacing.s18),
                  _buildWelcomeBanner(context, ref),
                  const SizedBox(height: AppSpacing.s18),
                  _buildHighlightCards(context, ref, iaSuccessRate, iaStats['pending'] ?? 0, totalLivestock),
                  const SizedBox(height: AppSpacing.s18),
                  _buildQuickModules(context, ref, iaStats['total'] ?? 0, healthAsync.valueOrNull?.length ?? 0),
                  const SizedBox(height: AppSpacing.s18),
                  _buildInseminationChart(context, ref, iaStats),
                  const SizedBox(height: AppSpacing.s18),
                  _buildKpiSection(context, ref, iaSuccessRate),
                  const SizedBox(height: AppSpacing.s18),
                  _buildRecentActivity(context, ref),
                  const SizedBox(height: AppSpacing.s16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isMg = ref.watch(languageProvider) == 'Malagasy';
    final dateStr = DateFormat('EEEE d MMMM yyyy', isMg ? 'en_US' : 'fr_FR').format(now);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t(ref, 'Tableau de bord', 'Topy maso'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.0,
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
            boxShadow: [
              BoxShadow(color: AppColors.success.withAlpha(20), blurRadius: 4, offset: const Offset(0, 2)),
            ],
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
                _t(ref, 'Synchronisé', 'Voasynkao'),
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

  Widget _buildWelcomeBanner(BuildContext context, WidgetRef ref) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? _t(ref, 'Bonjour', 'Salama')
        : hour < 18
            ? _t(ref, 'Bon après-midi', 'Salama')
            : _t(ref, 'Bonsoir', 'Salama hariva');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primary.withAlpha(200),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              LucideIcons.piggyBank,
              size: 120,
              color: Colors.white.withAlpha(20),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting !',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      _t(ref, 'Vue d\'ensemble de votre exploitation', 'Topi-maso an\'ny toeram-piompiana'),
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(60), width: 1),
                ),
                child: const Icon(
                  LucideIcons.barChart3,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCards(BuildContext context, WidgetRef ref, int iaRate, int pendingIa, int livestock) {
    final highlights = [
      DashboardHighlightData(
        title: _t(ref, 'Fertilité IA', 'Fahavokarana IA'),
        value: '$iaRate%',
        caption: _t(ref, 'Basé sur l\'historique', 'Araka ny tantara'),
        icon: LucideIcons.trendingUp,
        startColor: AppColors.primaryDark,
        endColor: AppColors.success,
      ),
      DashboardHighlightData(
        title: _t(ref, 'Diagnostics IA', 'Fandinihana IA'),
        value: '$pendingIa',
        caption: _t(ref, 'En attente de résultat', 'Miandry vokatra'),
        icon: LucideIcons.alertTriangle,
        startColor: AppColors.warning,
        endColor: AppColors.error,
      ),
      DashboardHighlightData(
        title: _t(ref, 'Effectif total', 'Isan\'ny biby'),
        value: '$livestock',
        caption: _t(ref, 'Verrats et truies', 'Verrats sy Truies'),
        icon: LucideIcons.piggyBank,
        startColor: AppColors.primaryDark,
        endColor: AppColors.secondary,
      ),
      DashboardHighlightData(
        title: _t(ref, 'Ventes 7 jours', 'Varotra 7 andro'),
        value: '1.2M Ar',
        caption: _t(ref, 'Estimation flux', 'Tombana'),
        icon: LucideIcons.banknote,
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
            childAspectRatio: 2.1,
          ),
          itemCount: highlights.length,
          itemBuilder: (context, index) => DashboardHighlightCard(
            data: highlights[index],
          ),
        );
      },
    );
  }

  Widget _buildQuickModules(BuildContext context, WidgetRef ref, int iaCount, int healthCount) {
    final modules = [
      DashboardModuleData(
        label: _t(ref, 'Reproduction', 'Fiterahana'),
        value: '$iaCount',
        icon: LucideIcons.syringe,
        color: AppColors.primary,
        route: '/inseminations',
      ),
      DashboardModuleData(
        label: _t(ref, 'Santé', 'Fahasalamana'),
        value: '$healthCount',
        icon: LucideIcons.shieldCheck,
        color: AppColors.info,
        route: '/health',
      ),
      DashboardModuleData(
        label: _t(ref, 'Stock', 'Tahiry'),
        value: _t(ref, 'Stable', 'Tsara'),
        icon: LucideIcons.package,
        color: AppColors.warning,
        route: '/commercial',
      ),
      DashboardModuleData(
        label: _t(ref, 'Messages', 'Hafatra'),
        value: _t(ref, 'En direct', 'Mivantana'),
        icon: LucideIcons.messageSquare,
        color: AppColors.secondary,
        route: '/messenger',
      ),
    ];

    return SectionCard(
      title: _t(ref, 'Modules rapides', 'Sahan-draharaha haingana'),
      subtitle: _t(ref, 'Accès direct aux fonctionnalités', 'Fidirana mivantana'),
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

  Widget _buildInseminationChart(BuildContext context, WidgetRef ref, Map<String, int> stats) {
    return InseminationOutcomeChart(
      successCount: stats['confirmed'] ?? 0,
      failedCount: stats['failed'] ?? 0,
      pendingCount: stats['pending'] ?? 0,
    );
  }

  Widget _buildKpiSection(BuildContext context, WidgetRef ref, int iaRate) {
    return SectionCard(
      title: _t(ref, 'Indicateurs zootechniques', 'Tondro ara-teknika'),
      subtitle: _t(ref, 'Performance de l\'élevage', 'Vokatry ny fiompiana'),
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
            children: [
              StatMiniCard(
                label: _t(ref, 'Nés vivants/portée', 'Teraka velona'),
                value: '12.3',
                icon: LucideIcons.baby,
                iconColor: AppColors.success,
              ),
              StatMiniCard(
                label: _t(ref, 'Sevrés/portée', 'Naisaraka'),
                value: '10.8',
                icon: LucideIcons.heart,
                iconColor: AppColors.primary,
              ),
              StatMiniCard(
                label: _t(ref, 'Taux fertilité', 'Taham-pahavokarana'),
                value: '$iaRate%',
                icon: LucideIcons.trendingUp,
                iconColor: AppColors.info,
              ),
              StatMiniCard(
                label: _t(ref, 'GMQ engraissement', 'Fitomboana isan\'andro'),
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

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: _t(ref, 'Activité récente', 'Hetsika farany'),
      subtitle: _t(ref, 'Dernières actions enregistrées', 'Asa vita farany'),
      child: Column(
        children: [
          _buildActivityRow(
            context,
            icon: LucideIcons.syringe,
            color: AppColors.primary,
            title: _t(ref, 'Insémination dose 1', 'Fampitomboana fatra 1'),
            subtitle: _t(ref, 'Dernier enregistrement', 'Fanoratana farany'),
            time: _t(ref, 'En direct', 'Mivantana'),
          ),
          const Divider(height: 1),
          _buildActivityRow(
            context,
            icon: LucideIcons.shieldCheck,
            color: AppColors.success,
            title: _t(ref, 'Santé animale', 'Fahasalaman\'ny biby'),
            subtitle: _t(ref, 'Historique à jour', 'Tantara voaray'),
            time: _t(ref, 'Aujourd\'hui', 'Androany'),
          ),
          const Divider(height: 1),
          _buildActivityRow(
            context,
            icon: LucideIcons.piggyBank,
            color: AppColors.info,
            title: _t(ref, 'Mouvement stock', 'Fihetsiky ny tahiry'),
            subtitle: _t(ref, 'Flux stable', 'Tsara'),
            time: _t(ref, 'Hier', 'Omaly'),
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
              borderRadius: BorderRadius.circular(12),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
