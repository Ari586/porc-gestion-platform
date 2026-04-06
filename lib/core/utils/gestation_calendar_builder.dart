import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/calendar_event.dart';
import '../models/insemination_record.dart';
import '../models/health_record.dart';

/// Builds calendar events from insemination records for gestation tracking.
///
/// Key milestones from IA date:
/// - J0  : Insémination (IA)
/// - J21 : Contrôle retour chaleur
/// - J28 : Échographie confirmation
/// - J114: Mise-bas prévue
List<CalendarEvent> buildGestationEvents(List<InseminationRecord> records) {
  final events = <CalendarEvent>[];

  for (final r in records) {
    if (r.status == 'Échouée') continue;

    final iaDate = DateTime(r.dose1Date.year, r.dose1Date.month, r.dose1Date.day);

    // J0 - IA
    events.add(CalendarEvent(
      date: iaDate,
      label: '${r.sowCode} - IA (${r.boarCode})',
      type: 'IA',
      color: const Color(0xFF2563EB),
      icon: LucideIcons.syringe,
    ));

    // J21 - Contrôle retour chaleur
    final j21 = iaDate.add(const Duration(days: 21));
    events.add(CalendarEvent(
      date: j21,
      label: '${r.sowCode} - Contrôle J21',
      type: 'Contrôle',
      color: const Color(0xFFD97706),
      icon: LucideIcons.eye,
    ));

    // J28 - Échographie
    final j28 = iaDate.add(const Duration(days: 28));
    events.add(CalendarEvent(
      date: j28,
      label: '${r.sowCode} - Écho J28',
      type: 'Écho',
      color: const Color(0xFF7C3AED),
      icon: LucideIcons.scan,
    ));

    // J114 - Mise-bas prévue
    final j114 = iaDate.add(const Duration(days: 114));
    events.add(CalendarEvent(
      date: j114,
      label: '${r.sowCode} - Mise-bas prévue',
      type: 'Mise-bas',
      color: const Color(0xFFDC2626),
      icon: LucideIcons.baby,
    ));
  }

  return events;
}

/// Builds calendar events from health records.
List<CalendarEvent> buildHealthEvents(List<HealthRecord> records) {
  final events = <CalendarEvent>[];

  for (final r in records) {
    final eventDate = DateTime(r.eventDate.year, r.eventDate.month, r.eventDate.day);
    final isVaccination = r.eventType == 'Vaccination';

    events.add(CalendarEvent(
      date: eventDate,
      label: '${r.animalCode} - ${r.product}',
      type: r.eventType,
      color: isVaccination ? const Color(0xFF0891B2) : const Color(0xFFD97706),
      icon: isVaccination ? LucideIcons.syringe : LucideIcons.pill,
    ));

    // Next appointment
    if (r.nextDate != null) {
      final nextDate = DateTime(r.nextDate!.year, r.nextDate!.month, r.nextDate!.day);
      events.add(CalendarEvent(
        date: nextDate,
        label: '${r.animalCode} - Rappel ${r.product}',
        type: 'Rappel',
        color: const Color(0xFFDC2626),
        icon: LucideIcons.bell,
      ));
    }
  }

  return events;
}

/// Builds piglet/newborn care calendar events.
///
/// Based on standard neonatal piglet care protocol:
/// - J0 : Naissance - soins immédiats (cordon, séchage, colostrum)
/// - J1 : Injection fer + coupe queue
/// - J3 : Castration mâles
/// - J7 : Primo-vaccination Mycoplasme
/// - J14: Début alimentation complémentaire (creep feeding)
/// - J21: Vaccination PCV2
/// - J28: Sevrage
/// - J35: Rappel vaccination
/// - J42: Contrôle post-sevrage
List<CalendarEvent> buildPigletCareEvents({
  required DateTime birthDate,
  required String litterCode,
  int pigletCount = 0,
}) {
  final d0 = DateTime(birthDate.year, birthDate.month, birthDate.day);
  final countLabel = pigletCount > 0 ? ' ($pigletCount porcelets)' : '';
  final events = <CalendarEvent>[];

  // J0 - Naissance
  events.add(CalendarEvent(
    date: d0,
    label: '$litterCode - Naissance$countLabel',
    type: 'Soin',
    color: const Color(0xFFDC2626),
    icon: LucideIcons.baby,
  ));

  // J1 - Injection fer + coupe queue
  events.add(CalendarEvent(
    date: d0.add(const Duration(days: 1)),
    label: '$litterCode - Fer + coupe queue',
    type: 'Soin',
    color: const Color(0xFFEA580C),
    icon: LucideIcons.syringe,
  ));

  // J3 - Castration
  events.add(CalendarEvent(
    date: d0.add(const Duration(days: 3)),
    label: '$litterCode - Castration mâles',
    type: 'Soin',
    color: const Color(0xFFD97706),
    icon: LucideIcons.scissors,
  ));

  // J7 - Primo-vaccination Mycoplasme
  events.add(CalendarEvent(
    date: d0.add(const Duration(days: 7)),
    label: '$litterCode - Vaccin Mycoplasme',
    type: 'Vaccination',
    color: const Color(0xFF0891B2),
    icon: LucideIcons.syringe,
  ));

  // J14 - Creep feeding
  events.add(CalendarEvent(
    date: d0.add(const Duration(days: 14)),
    label: '$litterCode - Début creep feeding',
    type: 'Alimentation',
    color: const Color(0xFF16A34A),
    icon: LucideIcons.wheat,
  ));

  // J21 - Vaccination PCV2
  events.add(CalendarEvent(
    date: d0.add(const Duration(days: 21)),
    label: '$litterCode - Vaccin PCV2',
    type: 'Vaccination',
    color: const Color(0xFF7C3AED),
    icon: LucideIcons.syringe,
  ));

  // J28 - Sevrage
  events.add(CalendarEvent(
    date: d0.add(const Duration(days: 28)),
    label: '$litterCode - Sevrage',
    type: 'Sevrage',
    color: const Color(0xFF2563EB),
    icon: LucideIcons.logOut,
  ));

  // J35 - Rappel vaccination
  events.add(CalendarEvent(
    date: d0.add(const Duration(days: 35)),
    label: '$litterCode - Rappel vaccins',
    type: 'Rappel',
    color: const Color(0xFFDC2626),
    icon: LucideIcons.bell,
  ));

  // J42 - Contrôle post-sevrage
  events.add(CalendarEvent(
    date: d0.add(const Duration(days: 42)),
    label: '$litterCode - Contrôle post-sevrage',
    type: 'Contrôle',
    color: const Color(0xFF0D9488),
    icon: LucideIcons.clipboardCheck,
  ));

  return events;
}

/// Groups a flat list of [CalendarEvent]s into a date-keyed map suitable for
/// [MonthCalendarGrid].
Map<DateTime, List<CalendarEvent>> groupEventsByDate(
    List<CalendarEvent> events) {
  final map = <DateTime, List<CalendarEvent>>{};
  for (final e in events) {
    final key = DateTime(e.date.year, e.date.month, e.date.day);
    map.putIfAbsent(key, () => []).add(e);
  }
  return map;
}
