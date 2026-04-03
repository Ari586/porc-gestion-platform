import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class PipelineStage {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const PipelineStage({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

class PipelineBoard extends StatelessWidget {
  final List<PipelineStage> stages;

  const PipelineBoard({super.key, required this.stages});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? stages.length : 1;
        if (crossAxisCount == 1) {
          return Column(
            children: stages
                .map((stage) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.s8),
                      child: _PipelineStageCard(stage: stage),
                    ))
                .toList(),
          );
        }
        return Row(
          children: stages.asMap().entries.map((entry) {
            final isLast = entry.key == stages.length - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : AppSpacing.s10),
                child: _PipelineStageCard(stage: entry.value),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _PipelineStageCard extends StatelessWidget {
  final PipelineStage stage;

  const _PipelineStageCard({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: stage.backgroundColor,
        borderRadius: BorderRadius.circular(AppUiTokens.metricRadius),
        border: Border.all(color: stage.color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(
              color: stage.color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stage.icon, size: 20, color: stage.color),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${stage.count}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: stage.color,
                      ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  stage.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
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
