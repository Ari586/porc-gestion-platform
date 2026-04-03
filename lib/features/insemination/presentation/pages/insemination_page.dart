import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/insemination_record.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../widgets/insemination_form_dialog.dart';
import '../widgets/insemination_record_tile.dart';
import '../widgets/pipeline_board.dart';

class InseminationPage extends StatefulWidget {
  const InseminationPage({super.key});

  @override
  State<InseminationPage> createState() => _InseminationPageState();
}

class _InseminationPageState extends State<InseminationPage> {
  String _selectedFilter = 'Tous';

  static final _filters = ['Tous', 'En attente', 'Confirmée', 'Échouée'];

  // ── Demo data ──────────────────────────────────────────────────────────

  static final _now = DateTime.now();

  static final List<InseminationRecord> _demoRecords = [
    InseminationRecord(
      id: 'IA-001',
      sowCode: 'T-042',
      boarCode: 'V-008',
      semenLot: 'LOT-2026-03A',
      dose1Date: _now.subtract(const Duration(days: 2)),
      dose2Date: _now.subtract(const Duration(days: 1)),
      inseminator: 'Jean R.',
      status: 'Confirmée',
    ),
    InseminationRecord(
      id: 'IA-002',
      sowCode: 'T-015',
      boarCode: 'V-003',
      semenLot: 'LOT-2026-03B',
      dose1Date: _now.subtract(const Duration(days: 1)),
      dose2Date: _now,
      inseminator: 'Marie L.',
      status: 'En attente',
    ),
    InseminationRecord(
      id: 'IA-003',
      sowCode: 'T-028',
      boarCode: 'V-008',
      semenLot: 'LOT-2026-02C',
      dose1Date: _now.subtract(const Duration(days: 5)),
      dose2Date: _now.subtract(const Duration(days: 4)),
      inseminator: 'Jean R.',
      status: 'Échouée',
    ),
    InseminationRecord(
      id: 'IA-004',
      sowCode: 'T-056',
      boarCode: 'V-012',
      semenLot: 'LOT-2026-03A',
      dose1Date: _now,
      inseminator: 'Paul D.',
      status: 'En attente',
    ),
    InseminationRecord(
      id: 'IA-005',
      sowCode: 'T-033',
      boarCode: 'V-003',
      semenLot: 'LOT-2026-03C',
      dose1Date: _now.subtract(const Duration(days: 3)),
      dose2Date: _now.subtract(const Duration(days: 2)),
      inseminator: 'Marie L.',
      status: 'Confirmée',
    ),
    InseminationRecord(
      id: 'IA-006',
      sowCode: 'T-011',
      boarCode: 'V-005',
      semenLot: 'LOT-2026-03B',
      dose1Date: _now.subtract(const Duration(days: 4)),
      dose2Date: _now.subtract(const Duration(days: 3)),
      inseminator: 'Jean R.',
      status: 'Confirmée',
    ),
    InseminationRecord(
      id: 'IA-007',
      sowCode: 'T-071',
      boarCode: 'V-008',
      semenLot: 'LOT-2026-03D',
      dose1Date: _now,
      inseminator: 'Paul D.',
      status: 'En attente',
    ),
  ];

  // ── Derived counts ────────────────────────────────────────────────────

  int _countByStatus(String status) =>
      _demoRecords.where((r) => r.status == status).length;

  List<InseminationRecord> get _filteredRecords {
    if (_selectedFilter == 'Tous') return _demoRecords;
    return _demoRecords.where((r) => r.status == _selectedFilter).toList();
  }

  List<InseminationRecord> get _todayActions {
    final today = DateTime(_now.year, _now.month, _now.day);
    return _demoRecords.where((r) {
      final d1 = DateTime(r.dose1Date.year, r.dose1Date.month, r.dose1Date.day);
      final d2 = r.dose2Date != null
          ? DateTime(r.dose2Date!.year, r.dose2Date!.month, r.dose2Date!.day)
          : null;
      return d1 == today || d2 == today;
    }).toList();
  }

  // ── Actions ───────────────────────────────────────────────────────────

  Future<void> _addRecord() async {
    final result = await InseminationFormDialog.show(context);
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
                  _buildPipeline(context),
                  const SizedBox(height: AppSpacing.s16),
                  _buildTodayActions(context),
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
                'Inséminations',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'Gestion des inséminations artificielles',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: _addRecord,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Nouvelle IA'),
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

  // ── Pipeline board ────────────────────────────────────────────────────

  Widget _buildPipeline(BuildContext context) {
    return SectionCard(
      title: 'Pipeline',
      subtitle: 'Statut des inséminations en cours',
      child: PipelineBoard(
        stages: [
          PipelineStage(
            label: 'En attente',
            count: _countByStatus('En attente'),
            icon: LucideIcons.clock,
            color: AppColors.warning,
            backgroundColor: AppColors.warningLight,
          ),
          PipelineStage(
            label: 'Confirmée',
            count: _countByStatus('Confirmée'),
            icon: LucideIcons.checkCircle,
            color: AppColors.success,
            backgroundColor: AppColors.successLight,
          ),
          PipelineStage(
            label: 'Échouée',
            count: _countByStatus('Échouée'),
            icon: LucideIcons.xCircle,
            color: AppColors.error,
            backgroundColor: AppColors.errorLight,
          ),
        ],
      ),
    );
  }

  // ── Today's actions ───────────────────────────────────────────────────

  Widget _buildTodayActions(BuildContext context) {
    final actions = _todayActions;

    return SectionCard(
      title: "Actions du jour",
      subtitle: '${actions.length} insémination(s) prévue(s)',
      child: actions.isEmpty
          ? const EmptyState(
              icon: LucideIcons.calendarCheck,
              message: 'Aucune action prévue aujourd\'hui',
            )
          : Column(
              children: actions.map((r) {
                final isDose2Today = r.dose2Date != null &&
                    DateTime(r.dose2Date!.year, r.dose2Date!.month,
                            r.dose2Date!.day) ==
                        DateTime(_now.year, _now.month, _now.day);
                final label =
                    isDose2Today ? 'Dose 2 - ${r.sowCode}' : 'Dose 1 - ${r.sowCode}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.syringe,
                            size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            Text(
                              '${r.boarCode} - Lot ${r.semenLot}',
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
                      Text(
                        r.inseminator,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
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
        icon: LucideIcons.syringe,
        message: 'Aucune insémination trouvée pour ce filtre',
      );
    }

    return Column(
      children: records
          .map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                child: InseminationRecordTile(record: r),
              ))
          .toList(),
    );
  }
}
