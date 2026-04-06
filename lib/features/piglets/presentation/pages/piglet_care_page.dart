import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/calendar_event.dart';
import '../../../../core/utils/gestation_calendar_builder.dart';
import '../../../../core/widgets/month_calendar_grid.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/stat_mini_card.dart';
import '../../../../core/providers/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PigletCarePage extends ConsumerStatefulWidget {
  const PigletCarePage({super.key});

  @override
  ConsumerState<PigletCarePage> createState() => _PigletCarePageState();
}

class _PigletCarePageState extends ConsumerState<PigletCarePage> {
  DateTime _calendarMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;

  bool get _isMg => ref.watch(languageProvider) == 'Malagasy';
  String _t(String fr, String mg) => _isMg ? mg : fr;

  // ── Demo litters ──────────────────────────────────────────────────────

  static final _now = DateTime.now();

  static final List<_Litter> _demoLitters = [
    _Litter(
      code: 'P-2026-A',
      sowCode: 'T-042',
      birthDate: _now.subtract(const Duration(days: 5)),
      pigletCount: 12,
      status: 'En cours',
    ),
    _Litter(
      code: 'P-2026-B',
      sowCode: 'T-015',
      birthDate: _now.subtract(const Duration(days: 18)),
      pigletCount: 10,
      status: 'En cours',
    ),
    _Litter(
      code: 'P-2026-C',
      sowCode: 'T-033',
      birthDate: _now.subtract(const Duration(days: 32)),
      pigletCount: 9,
      status: 'Sevré',
    ),
    _Litter(
      code: 'P-2026-D',
      sowCode: 'T-056',
      birthDate: _now.add(const Duration(days: 3)),
      pigletCount: 0,
      status: 'Prévu',
    ),
  ];

  // ── Calendar events ──────────────────────────────────────────────────

  Map<DateTime, List<CalendarEvent>> get _calendarEvents {
    final allEvents = <CalendarEvent>[];
    for (final litter in _demoLitters) {
      allEvents.addAll(buildPigletCareEvents(
        birthDate: litter.birthDate,
        litterCode: litter.code,
        pigletCount: litter.pigletCount,
      ));
    }
    return groupEventsByDate(allEvents);
  }

  int get _totalPiglets =>
      _demoLitters.fold<int>(0, (sum, l) => sum + l.pigletCount);

  int get _activeLitters =>
      _demoLitters.where((l) => l.status == 'En cours').length;

  List<_UpcomingAction> get _upcomingActions {
    final today = DateTime(_now.year, _now.month, _now.day);
    final cutoff = today.add(const Duration(days: 7));
    final actions = <_UpcomingAction>[];

    for (final litter in _demoLitters) {
      final events = buildPigletCareEvents(
        birthDate: litter.birthDate,
        litterCode: litter.code,
        pigletCount: litter.pigletCount,
      );
      for (final e in events) {
        final eDate = DateTime(e.date.year, e.date.month, e.date.day);
        if (!eDate.isBefore(today) && eDate.isBefore(cutoff)) {
          actions.add(_UpcomingAction(
            event: e,
            sowCode: litter.sowCode,
            daysFromNow: eDate.difference(today).inDays,
          ));
        }
      }
    }

    actions.sort((a, b) => a.daysFromNow.compareTo(b.daysFromNow));
    return actions;
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  _buildUpcomingActions(context),
                  const SizedBox(height: AppSpacing.s16),
                  _buildCalendar(context),
                  const SizedBox(height: AppSpacing.s16),
                  _buildLittersList(context),
                  const SizedBox(height: AppSpacing.s16),
                  _buildProtocolReference(context),
                  const SizedBox(height: AppSpacing.s24),
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
                _t('Soins nouveau-nés', 'Fikarakarana zanakisoa'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                _t('Calendrier de traitement des porcelets', 'Tetiandro fitsaboana zanakisoa'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Summary cards ─────────────────────────────────────────────────────

  Widget _buildSummaryCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 600;
        final cards = [
          StatMiniCard(
            label: _t('Portées actives', 'Andiany mavitrika'),
            value: '$_activeLitters',
            icon: LucideIcons.baby,
            iconColor: AppColors.primary,
          ),
          StatMiniCard(
            label: _t('Porcelets total', 'Tontalin\'ny zanakisoa'),
            value: '$_totalPiglets',
            icon: LucideIcons.users,
            iconColor: const Color(0xFF16A34A),
          ),
          StatMiniCard(
            label: _t('Actions à venir', 'Hetsika ho avy'),
            value: '${_upcomingActions.length}',
            icon: LucideIcons.calendarClock,
            iconColor: const Color(0xFFDC2626),
          ),
        ];

        if (!wide) {
          return Column(
            children: cards
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                      child: c,
                    ))
                .toList(),
          );
        }
        return Row(
          children: cards
              .map((c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s4),
                      child: c,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  // ── Upcoming actions ─────────────────────────────────────────────────

  Widget _buildUpcomingActions(BuildContext context) {
    final actions = _upcomingActions;

    return SectionCard(
      title: _t('Actions à venir', 'Hetsika ho avy'),
      subtitle: '${actions.length} ${_t('action(s) dans les 7 prochains jours', 'hetsika ato anatin\'ny 7 andro')}',
      child: actions.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
              child: Center(
                child: Text(
                  _t('Aucune action prévue cette semaine', 'Tsy misy hetsika voalahatra amin\'ity herinandro ity'),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : Column(
              children: actions.take(8).map((a) {
                final urgencyColor =
                    a.daysFromNow <= 1 ? AppColors.error : AppColors.info;
                final dayLabel = a.daysFromNow == 0
                    ? _t('Aujourd\'hui', 'Anio')
                    : 'J+${a.daysFromNow}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: a.event.color.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(a.event.icon,
                            size: 16, color: a.event.color),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.event.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            Text(
                              '${_t('Truie', 'Kisoa vavy')} ${a.sowCode}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textMuted),
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
                          dayLabel,
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

  // ── Calendar ─────────────────────────────────────────────────────────

  Widget _buildCalendar(BuildContext context) {
    return MonthCalendarGrid(
      title: _t('Calendrier des soins', 'Tetiandrom-pikarakarana'),
      subtitle: _t('Protocole néonatal par portée', 'Fitsipika fikarakarana isaky ny andiany'),
      currentMonth: _calendarMonth,
      selectedDate: _selectedDate,
      events: _calendarEvents,
      onMonthChanged: (m) => setState(() => _calendarMonth = m),
      onDaySelected: (d) => setState(() => _selectedDate = d),
      legend: [
        CalendarLegendItem(label: _t('Soin', 'Fikarakarana'), color: const Color(0xFFEA580C)),
        CalendarLegendItem(label: _t('Vaccination', 'Vaksiny'), color: const Color(0xFF0891B2)),
        CalendarLegendItem(label: _t('Alimentation', 'Sakafo'), color: const Color(0xFF16A34A)),
        CalendarLegendItem(label: _t('Sevrage', 'Fisarahanono'), color: const Color(0xFF2563EB)),
        CalendarLegendItem(label: _t('Rappel', 'Fampahatsiahivana'), color: const Color(0xFFDC2626)),
        CalendarLegendItem(label: _t('Contrôle', 'Fanaraha-maso'), color: const Color(0xFF0D9488)),
      ],
    );
  }

  // ── Litters list ──────────────────────────────────────────────────────

  Widget _buildLittersList(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return SectionCard(
      title: _t('Portées suivies', 'Andiany kisoa arahana'),
      subtitle: '${_demoLitters.length} ${_t('portée(s) enregistrée(s)', 'andiany voasoratra')}',
      child: Column(
        children: _demoLitters.map((litter) {
          final statusColor = switch (litter.status) {
            'En cours' => AppColors.success,
            'Sevré' => AppColors.info,
            'Prévu' => AppColors.warning,
            _ => AppColors.textMuted,
          };

          final ageInDays =
              _now.difference(litter.birthDate).inDays;
          final ageLabel = ageInDays < 0
              ? '${_t('Naissance', 'Hahateraka')} J${-ageInDays}'
              : '${_t('Âge', 'Taona')} : ${ageInDays}j';

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s10),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.baby,
                        size: 20, color: statusColor),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${litter.code} - ${_t('Truie', 'Kisoa vavy')} ${litter.sowCode}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dateFmt.format(litter.birthDate)} · ${litter.pigletCount} ${_t('porcelets', 'zanakisoa')} · $ageLabel',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s10,
                      vertical: AppSpacing.s4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      borderRadius:
                          BorderRadius.circular(AppUiTokens.chipRadius),
                      border: Border.all(color: statusColor.withAlpha(60)),
                    ),
                    child: Text(
                      litter.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Protocol reference ───────────────────────────────────────────────

  Widget _buildProtocolReference(BuildContext context) {
    final steps = [
      _ProtocolStep('J0', _t('Naissance', 'Fahaterahana'), _t('Soins immédiats', 'Fikarakarana avy hatrany'), const Color(0xFFDC2626)),
      _ProtocolStep('J1', _t('Injection fer', 'Fampidirana vy'), _t('Fer injectable', 'Vy hatsindrona'), const Color(0xFFEA580C)),
      _ProtocolStep('J3', _t('Castration', 'Fanosirana'), _t('Castration des mâles', 'Fanosirana ny lahy'), const Color(0xFFD97706)),
      _ProtocolStep('J7', _t('Vaccin Mycoplasme', 'Vaksiny Mycoplasme'), _t('Primo-vaccination', 'Vaksiny voalohany'), const Color(0xFF0891B2)),
      _ProtocolStep('J14', _t('Creep feeding', 'Sakafo voalohany'), _t('Début alimentation', 'Fanombohana sakafo manokana'), const Color(0xFF16A34A)),
      _ProtocolStep('J21', _t('Vaccin PCV2', 'Vaksiny PCV2'), _t('Protection circovirus', 'Fiarovana circovirus'), const Color(0xFF7C3AED)),
      _ProtocolStep('J28', _t('Sevrage', 'Fisarahanono'), _t('Séparation de la mère', 'Fisarahan-toerana amin\'ny reny'), const Color(0xFF2563EB)),
      _ProtocolStep('J35', _t('Rappel vaccins', 'Fampahatsiahivana'), _t('Rappel', 'Famerenana'), const Color(0xFFDC2626)),
      _ProtocolStep('J42', _t('Contrôle', 'Fanaraha-maso'), _t('Vérification', 'Fanamarinana'), const Color(0xFF0D9488)),
    ];

    return SectionCard(
      title: _t('Protocole de référence', 'Lalànan\'ny fikarakarana'),
      subtitle: _t('Standard néonatal porcin', 'Fomba fiasan\'ny zanakisoa'),
      child: Column(
        children: steps.map((step) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: step.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: step.color.withAlpha(60)),
                  ),
                  child: Text(
                    step.day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      color: step.color,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                      ),
                      Text(
                        step.description,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Helper models ───────────────────────────────────────────────────────────

class _Litter {
  final String code;
  final String sowCode;
  final DateTime birthDate;
  final int pigletCount;
  final String status;

  const _Litter({
    required this.code,
    required this.sowCode,
    required this.birthDate,
    required this.pigletCount,
    required this.status,
  });
}

class _UpcomingAction {
  final CalendarEvent event;
  final String sowCode;
  final int daysFromNow;

  const _UpcomingAction({
    required this.event,
    required this.sowCode,
    required this.daysFromNow,
  });
}

class _ProtocolStep {
  final String day;
  final String title;
  final String description;
  final Color color;

  const _ProtocolStep(this.day, this.title, this.description, this.color);
}
