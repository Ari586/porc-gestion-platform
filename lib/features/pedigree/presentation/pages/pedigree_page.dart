import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';

class _PedigreeAnimal {
  final String code;
  final String name;
  final String breed;
  final String sex;
  final String? sireCode;
  final String? damCode;
  final int generation;

  const _PedigreeAnimal({
    required this.code,
    required this.name,
    required this.breed,
    required this.sex,
    this.sireCode,
    this.damCode,
    // ignore: unused_element_parameter
    this.generation = 0,
  });
}

class PedigreePage extends StatefulWidget {
  const PedigreePage({super.key});

  @override
  State<PedigreePage> createState() => _PedigreePageState();
}

class _PedigreePageState extends State<PedigreePage> {
  String _selectedAnimalCode = 'V-001';

  final _animals = <_PedigreeAnimal>[
    const _PedigreeAnimal(code: 'V-001', name: 'Titan', breed: 'Large White', sex: 'M', sireCode: 'V-010', damCode: 'T-020'),
    const _PedigreeAnimal(code: 'V-002', name: 'Atlas', breed: 'Piétrain', sex: 'M', sireCode: 'V-011', damCode: 'T-021'),
    const _PedigreeAnimal(code: 'T-001', name: 'Bella', breed: 'Large White', sex: 'F', sireCode: 'V-001', damCode: 'T-022'),
    const _PedigreeAnimal(code: 'T-002', name: 'Nala', breed: 'Landrace', sex: 'F', sireCode: 'V-002', damCode: 'T-023'),
    const _PedigreeAnimal(code: 'V-010', name: 'Zeus', breed: 'Large White', sex: 'M'),
    const _PedigreeAnimal(code: 'T-020', name: 'Hera', breed: 'Large White', sex: 'F'),
    const _PedigreeAnimal(code: 'V-011', name: 'Odin', breed: 'Piétrain', sex: 'M'),
    const _PedigreeAnimal(code: 'T-021', name: 'Freya', breed: 'Piétrain', sex: 'F'),
    const _PedigreeAnimal(code: 'T-022', name: 'Luna', breed: 'Landrace', sex: 'F'),
    const _PedigreeAnimal(code: 'T-023', name: 'Stella', breed: 'Landrace', sex: 'F'),
  ];

  final _inbreedingAlerts = <Map<String, String>>[
    {'pair': 'V-001 × T-001', 'coefficient': '12.5%', 'risk': 'Élevé', 'detail': 'Père-fille directe'},
    {'pair': 'V-002 × T-002', 'coefficient': '3.1%', 'risk': 'Modéré', 'detail': 'Demi-cousins'},
  ];

  _PedigreeAnimal? _findAnimal(String code) {
    return _animals.where((a) => a.code == code).firstOrNull;
  }

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
              _buildAnimalSelector(),
              const SizedBox(height: AppSpacing.s16),
              _buildPedigreeTree(),
              const SizedBox(height: AppSpacing.s16),
              _buildInbreedingAlerts(),
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
              Text('Pédigrée', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.s4),
              Text('Arbre généalogique et consanguinité', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalSelector() {
    final selectableAnimals = _animals.where((a) => a.sireCode != null || a.damCode != null).toList();
    return SectionCard(
      title: 'Animal sélectionné',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selectableAnimals.map((a) => ChoiceChip(
          avatar: Icon(a.sex == 'M' ? LucideIcons.circle : LucideIcons.heart, size: 14, color: a.sex == 'M' ? AppColors.info : AppColors.primary),
          label: Text('${a.code} — ${a.name}'),
          selected: _selectedAnimalCode == a.code,
          selectedColor: AppColors.primaryPale,
          onSelected: (_) => setState(() => _selectedAnimalCode = a.code),
        )).toList(),
      ),
    );
  }

  Widget _buildPedigreeTree() {
    final animal = _findAnimal(_selectedAnimalCode);
    if (animal == null) return const EmptyState(icon: LucideIcons.gitBranch, message: 'Animal introuvable.');

    final sire = animal.sireCode != null ? _findAnimal(animal.sireCode!) : null;
    final dam = animal.damCode != null ? _findAnimal(animal.damCode!) : null;
    final paternalGrandSire = sire?.sireCode != null ? _findAnimal(sire!.sireCode!) : null;
    final paternalGrandDam = sire?.damCode != null ? _findAnimal(sire!.damCode!) : null;
    final maternalGrandSire = dam?.sireCode != null ? _findAnimal(dam!.sireCode!) : null;
    final maternalGrandDam = dam?.damCode != null ? _findAnimal(dam!.damCode!) : null;

    return SectionCard(
      title: 'Arbre généalogique',
      subtitle: '${animal.code} — ${animal.name}',
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth > 700) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildGenColumn('Grands-parents paternels', [paternalGrandSire, paternalGrandDam])),
                const SizedBox(width: 8),
                Expanded(child: _buildGenColumn('Parents', [sire, dam])),
                const SizedBox(width: 8),
                Expanded(child: _buildGenColumn('Sujet', [animal])),
                const SizedBox(width: 8),
                Expanded(child: _buildGenColumn('Grands-parents maternels', [maternalGrandSire, maternalGrandDam])),
              ],
            );
          }
          return Column(
            children: [
              _buildAnimalNode(animal, 'Sujet'),
              const SizedBox(height: AppSpacing.s12),
              Row(children: [
                Expanded(child: _buildAnimalNode(sire, 'Père')),
                const SizedBox(width: 8),
                Expanded(child: _buildAnimalNode(dam, 'Mère')),
              ]),
              const SizedBox(height: AppSpacing.s12),
              Row(children: [
                Expanded(child: _buildAnimalNode(paternalGrandSire, 'GP paternel')),
                const SizedBox(width: 6),
                Expanded(child: _buildAnimalNode(paternalGrandDam, 'GM paternelle')),
                const SizedBox(width: 6),
                Expanded(child: _buildAnimalNode(maternalGrandSire, 'GP maternel')),
                const SizedBox(width: 6),
                Expanded(child: _buildAnimalNode(maternalGrandDam, 'GM maternelle')),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGenColumn(String title, List<_PedigreeAnimal?> animals) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        const SizedBox(height: AppSpacing.s8),
        ...animals.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s8),
          child: _buildAnimalNode(a, null),
        )),
      ],
    );
  }

  Widget _buildAnimalNode(_PedigreeAnimal? animal, String? label) {
    if (animal == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.s10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius),
          border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            if (label != null) Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            const Icon(LucideIcons.helpCircle, size: 16, color: AppColors.textMuted),
            const Text('Inconnu', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    final isMale = animal.sex == 'M';
    final color = isMale ? AppColors.info : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          if (label != null) Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          Icon(isMale ? LucideIcons.shield : LucideIcons.heart, size: 18, color: color),
          const SizedBox(height: 2),
          Text(animal.code, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color)),
          Text(animal.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textPrimary)),
          Text(animal.breed, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildInbreedingAlerts() {
    if (_inbreedingAlerts.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: 'Alertes consanguinité',
      subtitle: '${_inbreedingAlerts.length} alerte(s)',
      child: Column(
        children: _inbreedingAlerts.map((a) {
          final isHigh = a['risk'] == 'Élevé';
          final color = isHigh ? AppColors.error : AppColors.warning;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s8),
            padding: AppUiTokens.entityPadding,
            decoration: BoxDecoration(
              color: color.withAlpha(10),
              borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius),
              border: Border.all(color: color.withAlpha(50)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
                  child: Icon(LucideIcons.alertTriangle, size: 18, color: color),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['pair']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                    Text(a['detail']!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  ],
                )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(a['coefficient']!, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(999)),
                      child: Text(a['risk']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
                    ),
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
