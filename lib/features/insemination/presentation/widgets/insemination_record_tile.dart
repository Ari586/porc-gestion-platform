import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/insemination_record.dart';

class InseminationRecordTile extends StatelessWidget {
  final InseminationRecord record;
  final VoidCallback? onTap;

  const InseminationRecordTile({
    super.key,
    required this.record,
    this.onTap,
  });

  static final _dateFmt = DateFormat('dd/MM/yyyy');

  Color _statusColor() {
    switch (record.status.toLowerCase()) {
      case 'confirmée':
        return AppColors.success;
      case 'échouée':
        return AppColors.error;
      case 'en attente':
      default:
        return AppColors.warning;
    }
  }

  IconData _statusIcon() {
    switch (record.status.toLowerCase()) {
      case 'confirmée':
        return LucideIcons.checkCircle;
      case 'échouée':
        return LucideIcons.xCircle;
      case 'en attente':
      default:
        return LucideIcons.clock;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

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
            // Status icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.s8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_statusIcon(), size: 18, color: color),
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
                        record.sowCode,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                      ),
                      const SizedBox(width: AppSpacing.s6),
                      Icon(LucideIcons.x, size: 10, color: AppColors.textMuted),
                      const SizedBox(width: AppSpacing.s6),
                      Text(
                        record.boarCode,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Row(
                    children: [
                      _infoChip(
                          context, 'Lot: ${record.semenLot}'),
                      const SizedBox(width: AppSpacing.s8),
                      _infoChip(
                          context,
                          'D1: ${_dateFmt.format(record.dose1Date)}'),
                      if (record.dose2Date != null) ...[
                        const SizedBox(width: AppSpacing.s8),
                        _infoChip(
                            context,
                            'D2: ${_dateFmt.format(record.dose2Date!)}'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            // Status badge + inseminator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _statusBadge(context, color),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  record.inseminator,
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

  Widget _statusBadge(BuildContext context, Color color) {
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
      child: Text(
        record.status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
    );
  }
}
