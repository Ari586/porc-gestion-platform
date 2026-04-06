import 'package:flutter/material.dart';

class CalendarEvent {
  final DateTime date;
  final String label;
  final String type;
  final Color color;
  final IconData icon;

  const CalendarEvent({
    required this.date,
    required this.label,
    required this.type,
    required this.color,
    required this.icon,
  });
}
