import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/health_record.dart';

class HealthRecordTile extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback? onTap;

  const HealthRecordTile({
    super.key,
    required this.record,
    this.onTap,
  });

  static final _dateFmt = DateFormat('dd/MM/yyyy');

  Color _eventColor() {
    switch (record.eventType.toLowerCase()) {
      case 'vaccination':
        return AppColors.info;
      case 'traitement':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }

  IconData _eventIcon() {
    switch (record.eventType.toLowerCase()) {
      case 'vaccination':
        return LucideIcons.syringe;
      case 'traitement':
        return LucideIcons.pill;
      default:
        return LucideIcons.stethoscope;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _eventColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppUiTokens.entityRadius),
      child: Container(
        padding: AppUiTokens.entityPadding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppUiTokens.entityRadius),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            // Event icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.s8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_eventIcon(), size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.s12),
            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        record.animalCode,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      _typeBadge(context, color),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Row(
                    children: [
                      Text(
                        record.product,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        'Dose: ${record.dose}',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            // Date + responsible
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _dateFmt.format(record.eventDate),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  record.responsible,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s3,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        record.eventType,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
      ),
    );
  }
}
