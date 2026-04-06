import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/sow.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../theme/app_colors.dart';

class SowCard extends StatelessWidget {
  final Sow sow;
  final VoidCallback onDetail;
  final VoidCallback onDelete;

  const SowCard({
    super.key,
    required this.sow,
    required this.onDetail,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppUiTokens.entityRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppUiTokens.entityRadius),
              ),
            ),
            child: Center(
              child: buildAnimalPhoto(
                imageBase64: sow.imageBase64,
                size: 120,
                fallbackIcon: LucideIcons.piggyBank,
                borderRadius: AppUiTokens.entityRadius,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: AppUiTokens.entityPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & code
                  Text(
                    sow.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8,
                      vertical: AppSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPale,
                      borderRadius:
                          BorderRadius.circular(AppUiTokens.chipRadius),
                    ),
                    child: Text(
                      sow.code,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s8),

                  // Info rows
                  _InfoRow(
                    icon: LucideIcons.tag,
                    label: sow.breed,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  _InfoRow(
                    icon: LucideIcons.repeat,
                    label: 'Parité ${sow.parity}',
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  _InfoRow(
                    icon: LucideIcons.calendar,
                    label: dateFormat.format(sow.birthDate),
                  ),
                  if (sow.sireCode.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s4),
                    _InfoRow(
                      icon: LucideIcons.arrowUpRight,
                      label: 'Pere: ${sow.sireCode}',
                    ),
                  ],
                  if (sow.damCode.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s4),
                    _InfoRow(
                      icon: LucideIcons.arrowDownRight,
                      label: 'Mere: ${sow.damCode}',
                    ),
                  ],

                  const Spacer(),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onDetail,
                          icon: const Icon(LucideIcons.eye, size: 14),
                          label: const Text('Detail'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.s8,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(LucideIcons.trash2, size: 14),
                          label: const Text('Supprimer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.s8,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.s6),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
