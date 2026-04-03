import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/health_record.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/stat_mini_card.dart';
import '../widgets/health_record_form_dialog.dart';
import '../widgets/health_record_tile.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  String _selectedFilter = 'Tous';

  static final _filters = ['Tous', 'Vaccination', 'Traitement'];

  // ── Demo data ──────────────────────────────────────────────────────────

  static final _now = DateTime.now();

  static final List<HealthRecord> _demoRecords = [
    HealthRecord(
      id: 'H-001',
      animalType: 'Truie',
      animalCode: 'T-042',
      eventType: 'Vaccination',
      eventDate: _now.subtract(const Duration(days: 10)),
      product: 'Parvo/Erysipele',
      dose: '2 mL',
      reason: 'Protocole reproductrice',
      nextDate: _now.add(const Duration(days: 5)),
      responsible: 'Dr. Rabe',
    ),
    HealthRecord(
      id: 'H-002',
      animalType: 'Truie',
      animalCode: 'T-015',
      eventType: 'Traitement',
      eventDate: _now.subtract(const Duration(days: 3)),
      product: 'Amoxicilline',
      dose: '10 mg/kg',
      reason: 'Infection urinaire',
      responsible: 'Dr. Rabe',
    ),
    HealthRecord(
      id: 'H-003',
      animalType: 'Verrat',
      animalCode: 'V-008',
      eventType: 'Vaccination',
      eventDate: _now.subtract(const Duration(days: 15)),
      product: 'PCV2',
      dose: '2 mL',
      reason: 'Rappel annuel',
      nextDate: _now.add(const Duration(days: 10)),
      responsible: 'Dr. Rabe',
    ),
    HealthRecord(
      id: 'H-004',
      animalType: 'Truie',
      animalCode: 'T-028',
      eventType: 'Traitement',
      eventDate: _now.subtract(const Duration(days: 1)),
      product: 'Fer injectable',
      dose: '200 mg',
      reason: 'Anemie post-mise-bas',
      responsible: 'Marie L.',
    ),
    HealthRecord(
      id: 'H-005',
      animalType: 'Truie',
      animalCode: 'T-056',
      eventType: 'Vaccination',
      eventDate: _now.subtract(const Duration(days: 20)),
      product: 'E. coli / Clostridium',
      dose: '2 mL',
      reason: 'Pre-mise-bas',
      nextDate: _now.add(const Duration(days: 3)),
      responsible: 'Dr. Rabe',
    ),
    HealthRecord(
      id: 'H-006',
      animalType: 'Porcelet',
      animalCode: 'P-112',
      eventType: 'Vaccination',
      eventDate: _now.subtract(const Duration(days: 7)),
      product: 'Mycoplasme',
      dose: '1 mL',
      reason: 'Primo-vaccination',
      nextDate: _now.add(const Duration(days: 14)),
      responsible: 'Jean R.',
    ),
    HealthRecord(
      id: 'H-007',
      animalType: 'Truie',
      animalCode: 'T-033',
      eventType: 'Traitement',
      eventDate: _now,
      product: 'Oxytocine',
      dose: '2 mL',
      reason: 'Assistance mise-bas',
      responsible: 'Dr. Rabe',
    ),
  ];

  // ── Derived data ──────────────────────────────────────────────────────

  List<HealthRecord> get _filteredRecords {
    if (_selectedFilter == 'Tous') return _demoRecords;
    return _demoRecords
        .where((r) => r.eventType == _selectedFilter)
        .toList();
  }

  List<HealthRecord> get _upcomingVaccinations {
    final cutoff = _now.add(const Duration(days: 14));
    return _demoRecords.where((r) {
      if (r.nextDate == null) return false;
      return r.nextDate!.isAfter(_now.subtract(const Duration(days: 1))) &&
          r.nextDate!.isBefore(cutoff);
    }).toList();
  }

  int get _vaccinationCount =>
      _demoRecords.where((r) => r.eventType == 'Vaccination').length;

  int get _traitementCount =>
      _demoRecords.where((r) => r.eventType == 'Traitement').length;

  // ── Actions ───────────────────────────────────────────────────────────

  Future<void> _addRecord() async {
    final result = await HealthRecordFormDialog.show(context);
    if (result != null) setState(() => _demoRecords.add(result));
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.s16),
                  _buildSummaryCards(context),
                  const SizedBox(height: AppSpacing.s16),
                  _buildUpcomingVaccinations(context),
                  const SizedBox(height: AppSpacing.s16),
                  _buildFilterChips(context),
                  const SizedBox(height: AppSpacing.s12),
                  _buildRecordsList(context),
                  const SizedBox(height: AppSpacing.s16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suivi santé',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'Vaccinations et traitements',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () {
            // TODO: open new health record form
          },
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Ajouter'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppUiTokens.entityRadius),
            ),
          ),
        ),
      ],
    );
  }

  // ── Summary cards ─────────────────────────────────────────────────────

  Widget _buildSummaryCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
        if (crossAxisCount == 1) {
          return Column(
            children: [
              StatMiniCard(
                label: 'Total événements',
                value: '${_demoRecords.length}',
                icon: LucideIcons.activity,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.s8),
              StatMiniCard(
                label: 'Vaccinations',
                value: '$_vaccinationCount',
                icon: LucideIcons.syringe,
                iconColor: AppColors.info,
              ),
              const SizedBox(height: AppSpacing.s8),
              StatMiniCard(
                label: 'Traitements',
                value: '$_traitementCount',
                icon: LucideIcons.pill,
                iconColor: AppColors.warning,
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: StatMiniCard(
                label: 'Total événements',
                value: '${_demoRecords.length}',
                icon: LucideIcons.activity,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: StatMiniCard(
                label: 'Vaccinations',
                value: '$_vaccinationCount',
                icon: LucideIcons.syringe,
                iconColor: AppColors.info,
              ),
            ),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: StatMiniCard(
                label: 'Traitements',
                value: '$_traitementCount',
                icon: LucideIcons.pill,
                iconColor: AppColors.warning,
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Upcoming vaccinations ─────────────────────────────────────────────

  Widget _buildUpcomingVaccinations(BuildContext context) {
    final upcoming = _upcomingVaccinations;
    final dateFmt = DateFormat('dd/MM/yyyy');

    return SectionCard(
      title: 'Vaccinations à venir',
      subtitle: '${upcoming.length} rappel(s) dans les 14 prochains jours',
      child: upcoming.isEmpty
          ? const EmptyState(
              icon: LucideIcons.calendarCheck,
              message: 'Aucun rappel de vaccination prévu',
            )
          : Column(
              children: upcoming.map((r) {
                final daysUntil =
                    r.nextDate!.difference(_now).inDays;
                final urgencyColor =
                    daysUntil <= 3 ? AppColors.error : AppColors.info;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: urgencyColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(LucideIcons.bell,
                            size: 16, color: urgencyColor),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r.animalCode} - ${r.product}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            Text(
                              r.reason,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8,
                          vertical: AppSpacing.s4,
                        ),
                        decoration: BoxDecoration(
                          color: urgencyColor.withAlpha(20),
                          borderRadius:
                              BorderRadius.circular(AppUiTokens.chipRadius),
                        ),
                        child: Text(
                          daysUntil <= 0
                              ? "Aujourd'hui"
                              : 'J+$daysUntil (${dateFmt.format(r.nextDate!)})',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: urgencyColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────

  Widget _buildFilterChips(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s8,
      children: _filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return FilterChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedFilter = filter);
          },
          selectedColor: AppColors.primaryPale,
          checkmarkColor: AppColors.primaryDark,
          backgroundColor: AppColors.surface,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
          ),
          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
              ),
        );
      }).toList(),
    );
  }

  // ── Records list ──────────────────────────────────────────────────────

  Widget _buildRecordsList(BuildContext context) {
    final records = _filteredRecords;

    if (records.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.shieldCheck,
        message: 'Aucun événement santé pour ce filtre',
      );
    }

    return Column(
      children: records
          .map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                child: HealthRecordTile(record: r),
              ))
          .toList(),
    );
  }
}
