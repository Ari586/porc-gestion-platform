import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/health_record.dart';
import '../../../../core/models/calendar_event.dart';
import '../../../../core/utils/gestation_calendar_builder.dart';
import '../../../../core/widgets/month_calendar_grid.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/stat_mini_card.dart';
import '../widgets/health_record_form_dialog.dart';
import '../widgets/health_record_tile.dart';
import '../../../../core/providers/language_provider.dart';
import '../../domain/providers.dart';

class HealthPage extends ConsumerStatefulWidget {
  const HealthPage({super.key});

  @override
  ConsumerState<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends ConsumerState<HealthPage> {
  bool _showCalendar = false;
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;

  bool get _isMg => ref.watch(languageProvider) == 'Malagasy';
  String _t(String fr, String mg) => _isMg ? mg : fr;

  // ── Derived data using providers ──────────────────────────────────────

  int _getEventCount(List<HealthRecord> records, String type) =>
      records.where((r) => r.eventType == type).length;

  // ── Calendar events ──────────────────────────────────────────────────

  Map<DateTime, List<CalendarEvent>> _getCalendarEvents(List<HealthRecord> records) {
    final events = buildHealthEvents(records);
    return groupEventsByDate(events);
  }

  // ── Actions ───────────────────────────────────────────────────────────

  Future<void> _addRecord() async {
    final result = await HealthRecordFormDialog.show(context);
    if (result != null) {
      await ref.read(healthRepositoryProvider).add(result);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(healthRecordListProvider);
    final filteredRecords = ref.watch(filteredHealthRecordsProvider);
    final upcomingVaccinations = ref.watch(upcomingVaccinationsProvider);
    final filter = ref.watch(healthFilterProvider);

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
                          _buildSummaryCards(context, allRecords),
                          const SizedBox(height: AppSpacing.s16),
                          _buildUpcomingVaccinations(context, upcomingVaccinations),
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

  Widget _buildCalendarView(BuildContext context, List<HealthRecord> records) {
    return MonthCalendarGrid(
      title: _t('Calendrier santé', 'Tetiandro fahasalamana'),
      subtitle: _t('Vaccinations, traitements et rappels', 'Vaksiny, fitsaboana ary fampahatsiahivana'),
      currentMonth: _calendarMonth,
      selectedDate: _selectedDate,
      events: _getCalendarEvents(records),
      onMonthChanged: (m) => setState(() => _calendarMonth = m),
      onDaySelected: (d) => setState(() => _selectedDate = d),
      legend: [
        CalendarLegendItem(label: _t('Vaccination', 'Vaksiny'), color: const Color(0xFF0891B2)),
        CalendarLegendItem(label: _t('Traitement', 'Fitsaboana'), color: const Color(0xFFD97706)),
        CalendarLegendItem(label: _t('Rappel', 'Fampahatsiahivana'), color: const Color(0xFFDC2626)),
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
                _t('Suivi santé', 'Fanaraha-maso fahasalamana'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                _t('Vaccinations et traitements', 'Vaksiny sy fitsaboana'),
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
          label: Text(_t('Ajouter', 'Manampy')),
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

  Widget _buildSummaryCards(BuildContext context, List<HealthRecord> records) {
    final vaccCount = _getEventCount(records, 'Vaccination');
    final treatCount = _getEventCount(records, 'Traitement');

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
        if (crossAxisCount == 1) {
          return Column(
            children: [
              StatMiniCard(
                label: 'Total événements',
                value: '${records.length}',
                icon: LucideIcons.activity,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.s8),
              StatMiniCard(
                label: 'Vaccinations',
                value: '$vaccCount',
                icon: LucideIcons.syringe,
                iconColor: AppColors.info,
              ),
              const SizedBox(height: AppSpacing.s8),
              StatMiniCard(
                label: 'Traitements',
                value: '$treatCount',
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
                value: '${records.length}',
                icon: LucideIcons.activity,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: StatMiniCard(
                label: 'Vaccinations',
                value: '$vaccCount',
                icon: LucideIcons.syringe,
                iconColor: AppColors.info,
              ),
            ),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: StatMiniCard(
                label: 'Traitements',
                value: '$treatCount',
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

  Widget _buildUpcomingVaccinations(BuildContext context, List<HealthRecord> upcoming) {
    final now = DateTime.now();
    final dateFmt = DateFormat('dd/MM/yyyy');

    return SectionCard(
      title: _t('Vaccinations à venir', 'Vaksiny ho avy'),
      subtitle: '${upcoming.length} ${_t('rappel(s) dans les prochaines semaines', 'fampahatsiahivana ato anatin\'ny herinandro vitsivitsy')}',
      child: upcoming.isEmpty
          ? EmptyState(
              icon: LucideIcons.calendarCheck,
              message: _t('Aucun rappel de vaccination prévu', 'Tsy misy fampahatsiahivana vaksiny voalahatra'),
            )
          : Column(
              children: upcoming.map((r) {
                final daysUntil =
                    r.nextDate!.difference(now).inDays;
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
                              ? _t("Aujourd'hui", "Anio")
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

  Widget _buildFilterChips(BuildContext context, String currentFilter) {
    final filters = ['Tous', 'Vaccination', 'Traitement'];
    return Wrap(
      spacing: AppSpacing.s8,
      children: filters.map((filter) {
        final isSelected = currentFilter == filter;
        final label = filter == 'Tous' ? _t('Tous', 'Rehetra') :
                      filter == 'Vaccination' ? _t('Vaccination', 'Vaksiny') : _t('Traitement', 'Fitsaboana');
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            ref.read(healthFilterProvider.notifier).state = filter;
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

  Widget _buildRecordsList(BuildContext context, List<HealthRecord> records) {
    if (records.isEmpty) {
      return EmptyState(
        icon: LucideIcons.shieldCheck,
        message: _t('Aucun événement santé pour ce filtre', 'Tsy misy tranga fahasalamana amin\'ity sivana ity'),
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

