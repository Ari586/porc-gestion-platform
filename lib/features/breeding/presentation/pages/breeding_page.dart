import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/building_record.dart';
import '../../../../core/models/batch_record.dart';
import '../../../../core/models/growth_record.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';

class BreedingPage extends StatefulWidget {
  const BreedingPage({super.key});

  @override
  State<BreedingPage> createState() => _BreedingPageState();
}

class _BreedingPageState extends State<BreedingPage> {
  String _activeTab = 'batiments';

  final _buildings = <BuildingRecord>[
    BuildingRecord(id: '1', name: 'Maternité A', type: 'Maternité', capacity: 20, occupied: 14),
    BuildingRecord(id: '2', name: 'Engraissement B', type: 'Engraissement', capacity: 80, occupied: 62),
    BuildingRecord(id: '3', name: 'Quarantaine', type: 'Quarantaine', capacity: 10, occupied: 3),
  ];

  final _batches = <BatchRecord>[
    BatchRecord(id: '1', name: 'Bande 2026-01', stage: 'Maternité', startDate: DateTime(2026, 1, 15), animals: 18, avgWeight: 1.4),
    BatchRecord(id: '2', name: 'Bande 2025-12', stage: 'Post-sevrage', startDate: DateTime(2025, 12, 1), animals: 45, avgWeight: 28.5),
    BatchRecord(id: '3', name: 'Bande 2025-10', stage: 'Engraissement', startDate: DateTime(2025, 10, 8), animals: 38, avgWeight: 78.2),
  ];

  final _growths = <GrowthRecord>[
    GrowthRecord(id: '1', batchId: '2', date: DateTime(2026, 3, 25), avgWeight: 28.5, dailyGain: 0.52),
    GrowthRecord(id: '2', batchId: '2', date: DateTime(2026, 3, 18), avgWeight: 24.9, dailyGain: 0.48),
    GrowthRecord(id: '3', batchId: '3', date: DateTime(2026, 3, 25), avgWeight: 78.2, dailyGain: 0.82),
    GrowthRecord(id: '4', batchId: '3', date: DateTime(2026, 3, 18), avgWeight: 72.5, dailyGain: 0.79),
  ];

  final _df = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.s14),
                  _buildTabChips(),
                  const SizedBox(height: AppSpacing.s16),
                  if (_activeTab == 'batiments') _buildBuildingsSection(),
                  if (_activeTab == 'bandes') _buildBatchesSection(),
                  if (_activeTab == 'croissance') _buildGrowthSection(),
                  const SizedBox(height: AppSpacing.s16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Élevage', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.s4),
              Text('Bâtiments, bandes et croissance', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Ajouter'),
        ),
      ],
    );
  }

  Widget _buildTabChips() {
    final tabs = {'batiments': 'Bâtiments', 'bandes': 'Bandes', 'croissance': 'Croissance'};
    return Wrap(
      spacing: 8,
      children: tabs.entries.map((e) => ChoiceChip(
        label: Text(e.value),
        selected: _activeTab == e.key,
        selectedColor: AppColors.primaryPale,
        onSelected: (_) => setState(() => _activeTab = e.key),
      )).toList(),
    );
  }

  Widget _buildBuildingsSection() {
    if (_buildings.isEmpty) return const EmptyState(icon: LucideIcons.warehouse, message: 'Aucun bâtiment enregistré.');
    return SectionCard(
      title: 'Bâtiments',
      subtitle: '${_buildings.length} bâtiment(s)',
      child: LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth > 800 ? 3 : c.maxWidth > 500 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.0),
            itemCount: _buildings.length,
            itemBuilder: (_, i) => _buildBuildingCard(_buildings[i]),
          );
        },
      ),
    );
  }

  Widget _buildBuildingCard(BuildingRecord b) {
    final ratio = b.capacity > 0 ? (b.occupied / b.capacity).clamp(0.0, 1.0) : 0.0;
    final color = ratio > 0.85 ? AppColors.error : ratio > 0.6 ? AppColors.warning : AppColors.success;
    return Container(
      padding: AppUiTokens.entityPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppUiTokens.entityRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.warehouse, size: 18, color: color),
              const SizedBox(width: AppSpacing.s8),
              Expanded(child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary))),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          Text('${b.type} • ${b.occupied}/${b.capacity} places', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: ratio, minHeight: 8, backgroundColor: AppColors.surfaceContainer, valueColor: AlwaysStoppedAnimation(color)),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchesSection() {
    if (_batches.isEmpty) return const EmptyState(icon: LucideIcons.layers, message: 'Aucune bande enregistrée.');
    return SectionCard(
      title: 'Bandes de production',
      subtitle: '${_batches.length} bande(s)',
      child: Column(
        children: _batches.map((b) => _buildBatchTile(b)).toList(),
      ),
    );
  }

  Widget _buildBatchTile(BatchRecord b) {
    final stageColor = b.stage == 'Maternité' ? AppColors.primary : b.stage == 'Post-sevrage' ? AppColors.info : AppColors.success;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      padding: AppUiTokens.entityPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(color: stageColor.withAlpha(25), borderRadius: BorderRadius.circular(10)),
            child: Icon(LucideIcons.layers, size: 18, color: stageColor),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                Text('Démarrage: ${_df.format(b.startDate)} • ${b.animals} animaux', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: stageColor.withAlpha(25), borderRadius: BorderRadius.circular(999)),
            child: Text(b.stage, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: stageColor)),
          ),
          const SizedBox(width: AppSpacing.s8),
          Text('${b.avgWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildGrowthSection() {
    if (_growths.isEmpty) return const EmptyState(icon: LucideIcons.trendingUp, message: 'Aucune pesée enregistrée.');
    return SectionCard(
      title: 'Suivi croissance',
      subtitle: '${_growths.length} pesée(s)',
      child: Column(
        children: _growths.map((g) {
          final batchName = _batches.where((b) => b.id == g.batchId).firstOrNull?.name ?? g.batchId;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s8),
            padding: AppUiTokens.entityPadding,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(LucideIcons.trendingUp, size: 18, color: AppColors.success),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(batchName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                      Text(_df.format(g.date), style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${g.avgWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
                    Text('GMQ: ${(g.dailyGain * 1000).toStringAsFixed(0)} g/j', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
