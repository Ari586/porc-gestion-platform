import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_colors.dart';
import '../constants/app_spacing.dart';
import '../models/calendar_event.dart';

/// A legend item displayed above the calendar grid.
class CalendarLegendItem {
  final String label;
  final Color color;

  const CalendarLegendItem({required this.label, required this.color});
}

/// Reusable monthly calendar grid widget with event dots, day selection,
/// and a detail panel for the selected day.
class MonthCalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final Map<DateTime, List<CalendarEvent>> events;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;
  final List<CalendarLegendItem> legend;
  final String title;
  final String? subtitle;

  const MonthCalendarGrid({
    super.key,
    required this.currentMonth,
    this.selectedDate,
    required this.events,
    required this.onMonthChanged,
    required this.onDaySelected,
    required this.legend,
    this.title = 'Calendrier',
    this.subtitle,
  });

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth =
        DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final leadingEmptyCells = monthStart.weekday - 1; // Monday = 1
    final totalCells = leadingEmptyCells + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    final today = _normalize(DateTime.now());
    final effectiveSelected =
        selectedDate != null ? _normalize(selectedDate!) : today;
    final selectedEvents =
        events[_normalize(effectiveSelected)] ?? const <CalendarEvent>[];

    const weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final screenWidth = MediaQuery.of(context).size.width;
    final compactCalendar = screenWidth < 760;
    final tinyCalendar = screenWidth < 440;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppUiTokens.sectionRadius),
        border: Border.all(color: AppColors.borderLight),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF6EF), Colors.white],
        ),
      ),
      padding: AppUiTokens.sectionPaddingRegular,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──────────────────────────────────────────────────
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.s2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.s12),

          // ── Month navigation ───────────────────────────────────────
          if (tinyCalendar)
            Column(
              children: [
                _buildMonthNavRow(monthStart, compactCalendar),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildTodayButton(),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildMonthNavRow(monthStart, compactCalendar),
                ),
                const SizedBox(width: AppSpacing.s8),
                _buildTodayButton(),
              ],
            ),

          const SizedBox(height: AppSpacing.s8),

          // ── Legend ──────────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: legend
                .map((item) =>
                    _buildLegendChip(item.label, item.color, context))
                .toList(),
          ),

          const SizedBox(height: AppSpacing.s12),

          // ── Calendar grid ──────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final gap =
                  tinyCalendar ? 3.0 : (compactCalendar ? 4.0 : 6.0);
              final availableWidth = math.max(220.0, constraints.maxWidth);
              final cellWidth = (availableWidth - (gap * 6)) / 7;
              final targetCellHeight =
                  tinyCalendar ? 42.0 : (compactCalendar ? 50.0 : 62.0);
              final childAspectRatio =
                  (cellWidth / targetCellHeight).clamp(1.35, 3.5);

              return Column(
                children: [
                  // Week-day header
                  Row(
                    children: weekDays
                        .map(
                          (dayName) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: compactCalendar
                                    ? AppSpacing.s4
                                    : AppSpacing.s6,
                              ),
                              child: Text(
                                dayName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w800,
                                  fontSize: tinyCalendar
                                      ? 10
                                      : (compactCalendar ? 11 : 12),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  // Day cells
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rowCount * 7,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: gap,
                      mainAxisSpacing: gap,
                    ),
                    itemBuilder: (context, index) {
                      final dayNumber = index - leadingEmptyCells + 1;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }

                      final dayDate = DateTime(
                        monthStart.year,
                        monthStart.month,
                        dayNumber,
                      );
                      final normalizedDay = _normalize(dayDate);
                      final dayEvents =
                          events[normalizedDay] ?? const <CalendarEvent>[];
                      final isSelected =
                          _isSame(normalizedDay, effectiveSelected);
                      final isToday = _isSame(normalizedDay, today);

                      return _DayCell(
                        dayNumber: dayNumber,
                        dayEvents: dayEvents,
                        isSelected: isSelected,
                        isToday: isToday,
                        tinyCalendar: tinyCalendar,
                        compactCalendar: compactCalendar,
                        onTap: () => onDaySelected(normalizedDay),
                      );
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.s14),

          // ── Selected day detail ────────────────────────────────────
          _SelectedDayCard(
            selectedDate: effectiveSelected,
            events: selectedEvents,
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildMonthNavRow(DateTime monthStart, bool compact) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Mois precedent',
          onPressed: () => onMonthChanged(
            DateTime(monthStart.year, monthStart.month - 1, 1),
          ),
          icon: const Icon(LucideIcons.chevronLeft),
          iconSize: 20,
        ),
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy', 'fr_FR').format(monthStart),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: compact ? 14 : 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Mois suivant',
          onPressed: () => onMonthChanged(
            DateTime(monthStart.year, monthStart.month + 1, 1),
          ),
          icon: const Icon(LucideIcons.chevronRight),
          iconSize: 20,
        ),
      ],
    );
  }

  Widget _buildTodayButton() {
    final today = DateTime.now();
    return OutlinedButton.icon(
      onPressed: () {
        onMonthChanged(DateTime(today.year, today.month, 1));
        onDaySelected(_normalize(today));
      },
      icon: const Icon(Icons.today_outlined, size: 14),
      label: const Text("Aujourd'hui"),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.borderLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
        ),
      ),
    );
  }

  Widget _buildLegendChip(String label, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.s6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Day cell widget ──────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int dayNumber;
  final List<CalendarEvent> dayEvents;
  final bool isSelected;
  final bool isToday;
  final bool tinyCalendar;
  final bool compactCalendar;
  final VoidCallback onTap;

  const _DayCell({
    required this.dayNumber,
    required this.dayEvents,
    required this.isSelected,
    required this.isToday,
    required this.tinyCalendar,
    required this.compactCalendar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(
          tinyCalendar
              ? AppSpacing.s3
              : (compactCalendar ? AppSpacing.s4 : AppSpacing.s6),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPale
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: tinyCalendar ? 11 : 12,
                      color: isToday
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (dayEvents.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s4,
                      vertical: AppSpacing.s1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${dayEvents.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: tinyCalendar ? 8 : 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            if (dayEvents.isNotEmpty)
              Wrap(
                spacing: 3,
                runSpacing: 3,
                children: dayEvents
                    .take(tinyCalendar ? 2 : (compactCalendar ? 3 : 4))
                    .map(
                      (event) => Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: event.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Selected day detail card ─────────────────────────────────────────────────

class _SelectedDayCard extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEvent> events;

  const _SelectedDayCard({
    required this.selectedDate,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions du $formatted',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          if (events.isEmpty)
            Text(
              'Aucune action planifiee sur cette date.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(event.icon, size: 16, color: event.color),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        event.label,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      event.type,
                      style: TextStyle(
                        color: event.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
