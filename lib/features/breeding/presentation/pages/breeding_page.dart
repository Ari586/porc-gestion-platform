import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/building_record.dart';
import '../../../../core/models/batch_record.dart';
import '../../../../core/models/growth_record.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/providers/language_provider.dart';
import '../../domain/providers.dart';

class BreedingPage extends ConsumerStatefulWidget {
  const BreedingPage({super.key});

  @override
  ConsumerState<BreedingPage> createState() => _BreedingPageState();
}

class _BreedingPageState extends ConsumerState<BreedingPage> {
  String _activeTab = 'batiments';
  final _df = DateFormat('dd/MM/yyyy');

  bool get _isMg => ref.watch(languageProvider) == 'Malagasy';

  String _t(String fr, String mg) => _isMg ? mg : fr;

  Future<void> _addBuilding() async {
    final nameCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: _t('Maternité', 'Trano fiterahana'));
    final capacityCtrl = TextEditingController();
    
    final types = [
      _t('Maternité', 'Trano fiterahana'), 
      _t('Post-sevrage', 'Aorian\'ny fisarahanono'), 
      _t('Engraissement', 'Fanatavezana'), 
      _t('Quarantaine', 'Fihibohana'), 
      _t('Verraterie', 'Tranon-dahy')
    ];

    final result = await showDialog<BuildingRecord>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    const Icon(LucideIcons.warehouse, color: AppColors.primary, size: 22),
                    const SizedBox(width: AppSpacing.s10),
                    Text(_t('Nouveau bâtiment', 'Trano vaovao'), style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  ]),
                  const SizedBox(height: AppSpacing.s20),
                  TextFormField(controller: nameCtrl, decoration: InputDecoration(labelText: _t('Nom', 'Anarana'), hintText: _t('Ex: Maternité A', 'Ohata: Trano fiterahana A'), border: const OutlineInputBorder())),
                  const SizedBox(height: AppSpacing.s12),
                  DropdownButtonFormField<String>(
                    value: typeCtrl.text,
                    decoration: InputDecoration(labelText: _t('Type', 'Karazany'), border: const OutlineInputBorder()),
                    items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => typeCtrl.text = v); },
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  TextFormField(controller: capacityCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: _t('Capacité', 'Fahafahana'), hintText: 'Ex: 20', border: const OutlineInputBorder())),
                  const SizedBox(height: AppSpacing.s20),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(_t('Annuler', 'Foana'))),
                    const SizedBox(width: AppSpacing.s12),
                    FilledButton.icon(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty || capacityCtrl.text.trim().isEmpty) return;
                        Navigator.pop(ctx, BuildingRecord(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameCtrl.text.trim(),
                          type: typeCtrl.text,
                          capacity: int.tryParse(capacityCtrl.text.trim()) ?? 0,
                          occupied: 0,
                        ));
                      },
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: Text(_t('Ajouter', 'Manampy')),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (result != null) {
      await ref.read(breedingRepositoryProvider).addBuilding(result);
    }
  }

  Future<void> _addBatch() async {
    final nameCtrl = TextEditingController();
    final stageCtrl = TextEditingController(text: _t('Maternité', 'Trano fiterahana'));
    final animalsCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    
    final stages = [
      _t('Maternité', 'Trano fiterahana'), 
      _t('Post-sevrage', 'Aorian\'ny fisarahanono'), 
      _t('Engraissement', 'Fanatavezana'), 
      _t('Finition', 'Famaranana')
    ];

    final result = await showDialog<BatchRecord>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    const Icon(LucideIcons.layers, color: AppColors.primary, size: 22),
                    const SizedBox(width: AppSpacing.s10),
                    Text(_t('Nouvelle bande', 'Andiany vaovao'), style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  ]),
                  const SizedBox(height: AppSpacing.s20),
                  TextFormField(controller: nameCtrl, decoration: InputDecoration(labelText: _t('Nom', 'Anarana'), hintText: _t('Ex: Bande 2026', 'Ohata: Andiany 2026'), border: const OutlineInputBorder())),
                  const SizedBox(height: AppSpacing.s12),
                  DropdownButtonFormField<String>(
                    value: stageCtrl.text,
                    decoration: InputDecoration(labelText: _t('Stade', 'Dingana'), border: const OutlineInputBorder()),
                    items: stages.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => stageCtrl.text = v); },
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  TextFormField(controller: animalsCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: _t('Nombre d\'animaux', 'Isan\'ny biby'), border: const OutlineInputBorder())),
                  const SizedBox(height: AppSpacing.s12),
                  TextFormField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: _t('Poids moyen (kg)', 'Lanja antonony (kg)'), border: const OutlineInputBorder())),
                  const SizedBox(height: AppSpacing.s20),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(_t('Annuler', 'Foana'))),
                    const SizedBox(width: AppSpacing.s12),
                    FilledButton.icon(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        Navigator.pop(ctx, BatchRecord(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameCtrl.text.trim(),
                          stage: stageCtrl.text,
                          startDate: DateTime.now(),
                          animals: int.tryParse(animalsCtrl.text.trim()) ?? 0,
                          avgWeight: double.tryParse(weightCtrl.text.trim()) ?? 0,
                        ));
                      },
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: Text(_t('Ajouter', 'Manampy')),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (result != null) {
      await ref.read(breedingRepositoryProvider).addBatch(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(breedingDataProvider);
    final buildings = ref.watch(buildingListProvider);
    final batches = ref.watch(batchListProvider);
    final growths = ref.watch(growthListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: (_activeTab == 'batiments' || _activeTab == 'bandes')
          ? FloatingActionButton.extended(
              onPressed: _activeTab == 'batiments' ? _addBuilding : _addBatch,
              backgroundColor: AppColors.primary,
              icon: const Icon(LucideIcons.plus, color: Colors.white),
              label: Text(
                _activeTab == 'batiments' ? _t('Bâtiment', 'Trano') : _t('Bande', 'Andiany'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            )
          : null,
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
                  dataAsync.when(
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                    error: (e, _) => Center(child: Text('Erreur: $e', style: TextStyle(color: AppColors.error))),
                    data: (_) {
                      if (_activeTab == 'batiments') return _buildBuildingsSection(buildings);
                      if (_activeTab == 'bandes') return _buildBatchesSection(batches);
                      return _buildGrowthSection(growths, batches);
                    },
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

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_t('Élevage', 'Fiompiana'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.s4),
              Text(_t('Bâtiments, bandes et croissance', 'Trano, andiany ary fitomboana'), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabChips() {
    final tabs = {
      'batiments': _t('Bâtiments', 'Trano'), 
      'bandes': _t('Bandes', 'Andiany'), 
      'croissance': _t('Croissance', 'Fitomboana')
    };
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

  Widget _buildBuildingsSection(List<BuildingRecord> buildings) {
    if (buildings.isEmpty) {
      return EmptyState(
        icon: LucideIcons.warehouse,
        message: _t('Aucun bâtiment enregistré.', 'Tsy misy trano voasoratra.'),
        actionLabel: _t('Ajouter un bâtiment', 'Manampy trano'),
        onAction: _addBuilding,
      );
    }
    return SectionCard(
      title: _t('Bâtiments', 'Trano'),
      subtitle: '${buildings.length} ${_t('bâtiment(s)', 'trano')}',
      child: LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth > 800 ? 3 : c.maxWidth > 500 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.0),
            itemCount: buildings.length,
            itemBuilder: (_, i) => _buildBuildingCard(buildings[i]),
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
          Row(children: [
            Icon(LucideIcons.warehouse, size: 18, color: color),
            const SizedBox(width: AppSpacing.s8),
            Expanded(child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary))),
          ]),
          const SizedBox(height: AppSpacing.s4),
          Text('${b.type} • ${b.occupied}/${b.capacity} ${_t('places', 'toerana')}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: ratio, minHeight: 8, backgroundColor: AppColors.surfaceContainer, valueColor: AlwaysStoppedAnimation(color)),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchesSection(List<BatchRecord> batches) {
    if (batches.isEmpty) {
      return EmptyState(
        icon: LucideIcons.layers,
        message: _t('Aucune bande enregistrée.', 'Tsy misy andiany voasoratra.'),
        actionLabel: _t('Ajouter une bande', 'Manampy andiany'),
        onAction: _addBatch,
      );
    }
    return SectionCard(
      title: _t('Bandes de production', 'Andian\'ny famokarana'),
      subtitle: '${batches.length} ${_t('bande(s)', 'andiany')}',
      child: Column(children: batches.map((b) => _buildBatchTile(b)).toList()),
    );
  }

  Widget _buildBatchTile(BatchRecord b) {
    final stageColor = b.stage == 'Maternité' || b.stage == 'Trano fiterahana' ? AppColors.primary : b.stage == 'Post-sevrage' ? AppColors.info : AppColors.success;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      padding: AppUiTokens.entityPadding,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius), border: Border.all(color: AppColors.borderLight)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(AppSpacing.s8), decoration: BoxDecoration(color: stageColor.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: Icon(LucideIcons.layers, size: 18, color: stageColor)),
        const SizedBox(width: AppSpacing.s12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(b.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
          Text('${_t('Démarrage', 'Fiandohana')}: ${_df.format(b.startDate)} • ${b.animals} ${_t('animaux', 'biby')}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: stageColor.withAlpha(25), borderRadius: BorderRadius.circular(999)), child: Text(b.stage, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: stageColor))),
        const SizedBox(width: AppSpacing.s8),
        Text('${b.avgWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
      ]),
    );
  }

  Widget _buildGrowthSection(List<GrowthRecord> growths, List<BatchRecord> batches) {
    if (growths.isEmpty) return EmptyState(icon: LucideIcons.trendingUp, message: _t('Aucune pesée enregistrée.', 'Tsy misy fandanjana voasoratra.'));
    return SectionCard(
      title: _t('Suivi croissance', 'Fanaraha-maso fitomboana'),
      subtitle: '${growths.length} ${_t('pesée(s)', 'fandanjana')}',
      child: Column(
        children: growths.map((g) {
          final batchName = batches.where((b) => b.id == g.batchId).firstOrNull?.name ?? g.batchId;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s8),
            padding: AppUiTokens.entityPadding,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius), border: Border.all(color: AppColors.borderLight)),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(AppSpacing.s8), decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.trendingUp, size: 18, color: AppColors.success)),
              const SizedBox(width: AppSpacing.s12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(batchName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                Text(_df.format(g.date), style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${g.avgWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
                Text('GMQ: ${(g.dailyGain * 1000).toStringAsFixed(0)} g/j', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
              ]),
            ]),
          );
        }).toList(),
      ),
    );
  }
}
