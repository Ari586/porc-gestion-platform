import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';

class InseminationOutcomeChart extends StatelessWidget {
  final int successCount;
  final int failedCount;
  final int pendingCount;

  const InseminationOutcomeChart({
    super.key,
    required this.successCount,
    required this.failedCount,
    required this.pendingCount,
  });

  int get _total => successCount + failedCount + pendingCount;
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Résultats IA',
      subtitle: '$_total inséminations au total',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          if (isWide) {
            return Row(
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: _DonutChart(
                    successCount: successCount,
                    failedCount: failedCount,
                    pendingCount: pendingCount,
                    total: _total,
                  ),
                ),
                const SizedBox(width: AppSpacing.s24),
                Expanded(child: _buildBars(context)),
              ],
            );
          }
          return Column(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: _DonutChart(
                  successCount: successCount,
                  failedCount: failedCount,
                  pendingCount: pendingCount,
                  total: _total,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildBars(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBars(BuildContext context) {
    return Column(
      children: [
        _buildBar(context, 'Confirmées', successCount, AppColors.success),
        const SizedBox(height: AppSpacing.s8),
        _buildBar(context, 'Échouées', failedCount, AppColors.error),
        const SizedBox(height: AppSpacing.s8),
        _buildBar(context, 'En attente', pendingCount, AppColors.warning),
      ],
    );
  }

  Widget _buildBar(BuildContext context, String label, int count, Color color) {
    final ratio = _total == 0 ? 0.0 : count / _total;
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        SizedBox(
          width: 32,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DonutChart extends StatelessWidget {
  final int successCount;
  final int failedCount;
  final int pendingCount;
  final int total;

  const _DonutChart({
    required this.successCount,
    required this.failedCount,
    required this.pendingCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutPainter(
        successCount: successCount,
        failedCount: failedCount,
        pendingCount: pendingCount,
        total: total,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$total',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'IA totales',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int successCount;
  final int failedCount;
  final int pendingCount;
  final int total;

  _DonutPainter({
    required this.successCount,
    required this.failedCount,
    required this.pendingCount,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 16.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final segments = [
      (successCount, AppColors.success),
      (failedCount, AppColors.error),
      (pendingCount, AppColors.warning),
    ];

    var startAngle = -math.pi / 2;
    for (final (count, color) in segments) {
      if (count == 0) continue;
      final sweepAngle = (count / total) * 2 * math.pi;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle - 0.04, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.total != total ||
        oldDelegate.successCount != successCount ||
        oldDelegate.failedCount != failedCount;
  }
}
