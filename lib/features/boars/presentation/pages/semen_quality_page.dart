import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/semen_quality_record.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/stat_mini_card.dart';
import '../../domain/providers.dart';
import '../widgets/semen_quality_form_dialog.dart';

class SemenQualityPage extends ConsumerStatefulWidget {
  const SemenQualityPage({super.key});

  @override
  ConsumerState<SemenQualityPage> createState() => _SemenQualityPageState();
}

class _SemenQualityPageState extends ConsumerState<SemenQualityPage> {
  final _df = DateFormat('dd/MM/yyyy');

  Future<void> _addRecord() async {
    final result = await SemenQualityFormDialog.show(context);
    if (result != null) {
      await ref.read(semenQualityRepositoryProvider).add(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(semenQualityListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Contrôle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.s16),
                  recordsAsync.when(
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                    error: (e, _) => Center(child: Text('Erreur: $e', style: TextStyle(color: AppColors.error))),
                    data: (records) => Column(
                      children: [
                        _buildSummaryCards(context, records),
                        const SizedBox(height: AppSpacing.s16),
                        _buildRecordsList(context, records),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gestion semence', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.s4),
              Text('Contrôle qualité des lots de semence', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: _addRecord,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Nouveau contrôle'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppUiTokens.entityRadius)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, List<SemenQualityRecord> records) {
    final avgMotility = records.isNotEmpty
        ? records.fold<double>(0, (s, r) => s + r.motilityPercent) / records.length
        : 0.0;
    final avgConcentration = records.isNotEmpty
        ? records.fold<double>(0, (s, r) => s + r.concentration) / records.length
        : 0.0;
    final uniqueBoars = records.map((r) => r.boarCode).toSet().length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 600;
        final cards = [
          StatMiniCard(label: 'Contrôles', value: '${records.length}', icon: LucideIcons.testTube, iconColor: AppColors.primary),
          StatMiniCard(label: 'Motilité moy.', value: '${avgMotility.toStringAsFixed(1)}%', icon: LucideIcons.activity, iconColor: const Color(0xFF16A34A)),
          StatMiniCard(label: 'Concentration moy.', value: '${avgConcentration.toStringAsFixed(0)} M/mL', icon: LucideIcons.droplets, iconColor: const Color(0xFF2563EB)),
          StatMiniCard(label: 'Verrats', value: '$uniqueBoars', icon: LucideIcons.piggyBank, iconColor: const Color(0xFFD97706)),
        ];
        if (!wide) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
            children: cards,
          );
        }
        return Row(children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c))).toList());
      },
    );
  }

  Widget _buildRecordsList(BuildContext context, List<SemenQualityRecord> records) {
    if (records.isEmpty) {
      return EmptyState(
        icon: LucideIcons.testTube,
        message: 'Aucun contrôle qualité enregistré.\nAjoutez votre premier contrôle.',
        actionLabel: 'Ajouter un contrôle',
        onAction: _addRecord,
      );
    }

    return SectionCard(
      title: 'Historique des contrôles',
      subtitle: '${records.length} contrôle(s)',
      child: Column(
        children: records.map((r) {
          final motilityColor = r.motilityPercent >= 70
              ? AppColors.success
              : r.motilityPercent >= 50
                  ? AppColors.warning
                  : AppColors.error;

          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s10),
            padding: AppUiTokens.entityPadding,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(color: AppColors.primary.withAlpha(25), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.testTube, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${r.lotCode} — ${r.boarCode}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                    Text('${_df.format(r.collectionDate)} • Approuvé par ${r.approvedBy}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  ])),
                ]),
                const SizedBox(height: AppSpacing.s8),
                Row(children: [
                  _buildMetricChip('Motilité', '${r.motilityPercent.toStringAsFixed(0)}%', motilityColor),
                  const SizedBox(width: AppSpacing.s6),
                  _buildMetricChip('Conc.', '${r.concentration.toStringAsFixed(0)} M/mL', const Color(0xFF2563EB)),
                  const SizedBox(width: AppSpacing.s6),
                  _buildMetricChip('Temp.', '${r.temperatureC.toStringAsFixed(1)}°C', const Color(0xFFD97706)),
                  if (r.storageHours > 0) ...[
                    const SizedBox(width: AppSpacing.s6),
                    _buildMetricChip('Stock.', '${r.storageHours}h', AppColors.textMuted),
                  ],
                ]),
                if (r.notes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(r.notes, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
