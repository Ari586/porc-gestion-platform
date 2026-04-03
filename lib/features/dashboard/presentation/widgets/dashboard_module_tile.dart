import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class DashboardModuleData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String route;

  const DashboardModuleData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class DashboardModuleTile extends StatelessWidget {
  final DashboardModuleData data;

  const DashboardModuleTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppUiTokens.metricRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppUiTokens.metricRadius),
        hoverColor: data.color.withAlpha(12),
        onTap: () => context.go(data.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppUiTokens.metricRadius),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: data.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 18, color: data.color),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                data.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                data.value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
