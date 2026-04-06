import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/boar.dart';
import '../../../../core/utils/image_picker_helper.dart';

class BoarCard extends StatelessWidget {
  final Boar boar;
  final VoidCallback onDetail;
  final VoidCallback onDelete;

  const BoarCard({
    super.key,
    required this.boar,
    required this.onDetail,
    required this.onDelete,
  });

  String _computeAge(DateTime birthDate) {
    final now = DateTime.now();
    final months =
        (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (months < 12) {
      return '$months mois';
    }
    final years = months ~/ 12;
    final remaining = months % 12;
    if (remaining == 0) {
      return '$years an${years > 1 ? 's' : ''}';
    }
    return '$years an${years > 1 ? 's' : ''} $remaining mois';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final age = _computeAge(boar.birthDate);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: buildAnimalPhoto(
                imageBase64: boar.imageBase64,
                size: 120,
                fallbackIcon: LucideIcons.piggyBank,
                borderRadius: 20,
              ),
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Code
                Text(
                  boar.name,
                  style: textTheme.titleSmall?.copyWith(
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
                    boar.code,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s10),

                // Info rows
                _InfoRow(
                  icon: LucideIcons.dna,
                  label: 'Race',
                  value: boar.breed,
                ),
                const SizedBox(height: AppSpacing.s4),
                _InfoRow(
                  icon: LucideIcons.calendar,
                  label: 'Age',
                  value: age,
                ),
                const SizedBox(height: AppSpacing.s4),
                _InfoRow(
                  icon: LucideIcons.mapPin,
                  label: 'Origine',
                  value: boar.origin,
                ),
                const SizedBox(height: AppSpacing.s4),
                _InfoRow(
                  icon: LucideIcons.testTube,
                  label: 'Semence',
                  value: boar.semenType,
                ),
                if (boar.sireCode.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s4),
                  _InfoRow(
                    icon: LucideIcons.arrowUpCircle,
                    label: 'Sire',
                    value: boar.sireCode,
                  ),
                ],
                if (boar.damCode.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s4),
                  _InfoRow(
                    icon: LucideIcons.arrowDownCircle,
                    label: 'Dam',
                    value: boar.damCode,
                  ),
                ],
              ],
            ),
          ),

          const Spacer(),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s12,
              0,
              AppSpacing.s12,
              AppSpacing.s12,
            ),
            child: Row(
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
                      textStyle: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: Icon(
                      LucideIcons.trash2,
                      size: 14,
                      color: AppColors.error,
                    ),
                    label: Text(
                      'Supprimer',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s8,
                      ),
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
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
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.s6),
        Text(
          '$label: ',
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
