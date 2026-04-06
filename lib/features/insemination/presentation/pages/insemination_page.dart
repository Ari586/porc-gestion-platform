import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/insemination_record.dart';
import '../../../../core/models/calendar_event.dart';
import '../../../../core/utils/gestation_calendar_builder.dart';
import '../../../../core/widgets/month_calendar_grid.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../widgets/insemination_form_dialog.dart';
import '../widgets/insemination_record_tile.dart';
import '../widgets/pipeline_board.dart';
import '../../../../core/providers/language_provider.dart';
import '../../domain/providers.dart';

class InseminationPage extends ConsumerStatefulWidget {
  const InseminationPage({super.key});

  @override
  ConsumerState<InseminationPage> createState() => _InseminationPageState();
}

class _InseminationPageState extends ConsumerState<InseminationPage> {
  bool _showCalendar = false;
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;

  bool get _isMg => ref.watch(languageProvider) == 'Malagasy';
  String _t(String fr, String mg) => _isMg ? mg : fr;

  // ── Derived data using providers ──────────────────────────────────────

  List<InseminationRecord> _getTodayActions(List<InseminationRecord> records) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return records.where((r) {
      final d1 = DateTime(r.dose1Date.year, r.dose1Date.month, r.dose1Date.day);
      final d2 = r.dose2Date != null
          ? DateTime(r.dose2Date!.year, r.dose2Date!.month, r.dose2Date!.day)
          : null;
      return d1 == today || d2 == today;
    }).toList();
  }

  // ── Calendar events ──────────────────────────────────────────────────

  Map<DateTime, List<CalendarEvent>> _getCalendarEvents(List<InseminationRecord> records) {
    final events = buildGestationEvents(records);
    return groupEventsByDate(events);
  }

  // ── Actions ───────────────────────────────────────────────────────────

  Future<void> _addRecord() async {
    final result = await InseminationFormDialog.show(context);
    if (result != null) {
      await ref.read(inseminationRepositoryProvider).add(result);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(inseminationListProvider);
    final filteredRecords = ref.watch(filteredInseminationsProvider);
    final stats = ref.watch(inseminationStatsProvider);
    final filter = ref.watch(inseminationFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: Text(_t('Ajouter', 'Manampy'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
                  _buildViewToggle(context),
                  const SizedBox(height: AppSpacing.s16),
                  recordsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erreur: $e')),
                    data: (allRecords) {
                      if (_showCalendar) {
                        return _buildCalendarView(context, allRecords);
                      }
                      return Column(
                        children: [
                          _buildPipeline(context, stats),
                          const SizedBox(height: AppSpacing.s16),
                          _buildTodayActions(context, _getTodayActions(allRecords)),
                          const SizedBox(height: AppSpacing.s16),
                          _buildFilterChips(context, filter),
                          const SizedBox(height: AppSpacing.s12),
                          _buildRecordsList(context, filteredRecords),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── View toggle ──────────────────────────────────────────────────────

  Widget _buildViewToggle(BuildContext context) {
    return Row(
      children: [
        _buildToggleButton(
          icon: LucideIcons.list,
          label: _t('Liste', 'Lisitra'),
          isActive: !_showCalendar,
          onTap: () => setState(() => _showCalendar = false),
        ),
        const SizedBox(width: AppSpacing.s8),
        _buildToggleButton(
          icon: LucideIcons.calendar,
          label: _t('Calendrier', 'Tetiandro'),
          isActive: _showCalendar,
          onTap: () => setState(() => _showCalendar = true),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.primaryPale : AppColors.surface,
      borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s14,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isActive ? AppColors.primaryDark : AppColors.textMuted),
              const SizedBox(width: AppSpacing.s6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primaryDark : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Calendar view ────────────────────────────────────────────────────

  Widget _buildCalendarView(BuildContext context, List<InseminationRecord> records) {
    return MonthCalendarGrid(
      title: _t('Calendrier de gestation', 'Tetiandro fitondrana vohoka'),
      subtitle: _t('Suivi IA, contrôles, échographies et mises-bas', 'Fanaraha-maso Fampanarahana Artifisialy sy fahaterahana'),
      currentMonth: _calendarMonth,
      selectedDate: _selectedDate,
      events: _getCalendarEvents(records),
      onMonthChanged: (m) => setState(() => _calendarMonth = m),
      onDaySelected: (d) => setState(() => _selectedDate = d),
      legend: [
        CalendarLegendItem(label: _t('IA', 'Insémination'), color: const Color(0xFF2563EB)),
        CalendarLegendItem(label: _t('Contrôle J21', 'Fanaraha-maso J21'), color: const Color(0xFFD97706)),
        CalendarLegendItem(label: _t('Écho J28', 'Fanaovana Eko J28'), color: const Color(0xFF7C3AED)),
        CalendarLegendItem(label: _t('Mise-bas', 'Teraka'), color: const Color(0xFFDC2626)),
      ],
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
                _t('Inséminations', 'Inséminations'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                _t('Gestion des inséminations artificielles', 'Fitantanana insémination'),
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
          label: Text(_t('Nouvelle IA', 'Insémination vaovao')),
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

  Widget _buildPipeline(BuildContext context, Map<String, int> stats) {
    return SectionCard(
      title: 'Pipeline',
      subtitle: _t('Statut des inséminations en cours', 'Satan\'ny insémination misy'),
      child: PipelineBoard(
        stages: [
          PipelineStage(
            label: _t('En attente', 'Miandry'),
            count: stats['pending'] ?? 0,
            icon: LucideIcons.clock,
            color: AppColors.warning,
            backgroundColor: AppColors.warningLight,
          ),
          PipelineStage(
            label: _t('Confirmée', 'Voamarina'),
            count: stats['confirmed'] ?? 0,
            icon: LucideIcons.checkCircle,
            color: AppColors.success,
            backgroundColor: AppColors.successLight,
          ),
          PipelineStage(
            label: _t('Échouée', 'Tsy nahomby'),
            count: stats['failed'] ?? 0,
            icon: LucideIcons.xCircle,
            color: AppColors.error,
            backgroundColor: AppColors.errorLight,
          ),
        ],
      ),
    );
  }

  // ── Today's actions ───────────────────────────────────────────────────

  Widget _buildTodayActions(BuildContext context, List<InseminationRecord> actions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return SectionCard(
      title: _t("Actions du jour", "Hetsika anio"),
      subtitle: '${actions.length} ${_t('insémination(s) prévue(s)', 'insémination voalahatra')}',
      child: actions.isEmpty
          ? EmptyState(
              icon: LucideIcons.calendarCheck,
              message: _t('Aucune action prévue aujourd\'hui', 'Tsy misy hetsika voalahatra anio'),
            )
          : Column(
              children: actions.map((r) {
                final isDose2Today = r.dose2Date != null &&
                    DateTime(r.dose2Date!.year, r.dose2Date!.month,
                            r.dose2Date!.day) == today;
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

  Widget _buildFilterChips(BuildContext context, String currentFilter) {
    final filters = ['Tous', 'En attente', 'Confirmée', 'Échouée'];
    return Wrap(
      spacing: AppSpacing.s8,
      children: filters.map((filter) {
        final isSelected = currentFilter == filter;
        final label = filter == 'Tous' ? _t('Tous', 'Rehetra') :
                      filter == 'En attente' ? _t('En attente', 'Miandry') :
                      filter == 'Confirmée' ? _t('Confirmée', 'Voamarina') : _t('Échouée', 'Tsy nahomby');
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            ref.read(inseminationFilterProvider.notifier).state = filter;
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

  Widget _buildRecordsList(BuildContext context, List<InseminationRecord> records) {
    if (records.isEmpty) {
      return EmptyState(
        icon: LucideIcons.syringe,
        message: _t('Aucune insémination trouvée pour ce filtre', 'Tsy misy insémination hita amin\'ity sivana ity'),
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
