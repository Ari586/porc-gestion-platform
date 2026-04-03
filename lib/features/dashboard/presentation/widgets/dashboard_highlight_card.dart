import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

class DashboardHighlightData {
  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color startColor;
  final Color endColor;

  const DashboardHighlightData({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.startColor,
    required this.endColor,
  });
}

class DashboardHighlightCard extends StatefulWidget {
  final DashboardHighlightData data;

  const DashboardHighlightCard({super.key, required this.data});

  @override
  State<DashboardHighlightCard> createState() => _DashboardHighlightCardState();
}

class _DashboardHighlightCardState extends State<DashboardHighlightCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _hovered
            ? (Matrix4.identity()..setEntry(0, 0, 1.03)..setEntry(1, 1, 1.03))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [widget.data.startColor, widget.data.endColor],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.data.startColor.withAlpha(_hovered ? 80 : 50),
              blurRadius: _hovered ? 24 : 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.data.title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.data.icon, color: Colors.white70, size: 16),
                ),
              ],
            ),
            const Spacer(),
            Text(
              widget.data.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              widget.data.caption,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
