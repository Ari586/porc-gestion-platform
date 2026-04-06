import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/sow.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/providers/language_provider.dart';
import '../../domain/providers.dart';
import '../widgets/sow_card.dart';
import '../widgets/sow_form_dialog.dart';

class SowListPage extends ConsumerStatefulWidget {
  const SowListPage({super.key});

  @override
  ConsumerState<SowListPage> createState() => _SowListPageState();
}

class _SowListPageState extends ConsumerState<SowListPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  
  bool get _isMg => ref.watch(languageProvider) == 'Malagasy';
  String _t(String fr, String mg) => _isMg ? mg : fr;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Sow> _filter(List<Sow> sows) {
    if (_searchQuery.isEmpty) return sows;
    final q = _searchQuery.toLowerCase();
    return sows
        .where((s) =>
            s.code.toLowerCase().contains(q) ||
            s.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _addSow() async {
    final result = await SowFormDialog.show(context);
    if (result != null) {
      await ref.read(sowRepositoryProvider).add(result);
    }
  }

  Future<void> _editSow(Sow sow) async {
    final result = await SowFormDialog.show(context, sow: sow);
    if (result != null) {
      await ref.read(sowRepositoryProvider).update(result);
    }
  }

  Future<void> _deleteSow(Sow sow) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: _t('Supprimer la truie', 'Fafao ny kisoa vavy'),
      message: _t(
          'Voulez-vous vraiment supprimer ${sow.name} (${sow.code}) ? Cette action est irréversible.',
          'Vonona hamafa tokoa ve ianao ${sow.name} (${sow.code}) ? Tsy azo averina intsony ity hetsika ity.'),
      confirmLabel: _t('Supprimer', 'Fafao'),
      isDestructive: true,
    );
    if (confirmed) {
      await ref.read(sowRepositoryProvider).delete(sow.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sowsAsync = ref.watch(sowListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, sowsAsync.valueOrNull?.length ?? 0),
              const SizedBox(height: AppSpacing.s16),
              _buildSearchBar(context),
              const SizedBox(height: AppSpacing.s16),
              Expanded(
                child: sowsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text('Erreur de chargement',
                        style: TextStyle(color: AppColors.error)),
                  ),
                  data: (sows) {
                    final filtered = _filter(sows);
                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: LucideIcons.piggyBank,
                        message: _searchQuery.isNotEmpty
                            ? _t('Aucune truie ne correspond à votre recherche.', 'Tsy misy kisoa vavy mifanaraka amin\'ny fikarohana.')
                            : _t('Aucune truie enregistrée.\nCommencez par en ajouter une.', 'Tsy misy kisoa vavy voasoratra.\nAtombohy amin\'ny fampidirana iray.'),
                        actionLabel:
                            _searchQuery.isEmpty ? _t('Ajouter une truie', 'Manampy kisoa vavy') : null,
                        onAction: _searchQuery.isEmpty ? _addSow : null,
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 1180
                            ? 4
                            : constraints.maxWidth > 820
                                ? 3
                                : constraints.maxWidth > 560
                                    ? 2
                                    : 1;
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: AppSpacing.s12,
                            mainAxisSpacing: AppSpacing.s12,
                            childAspectRatio: 0.58,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final sow = filtered[index];
                            return SowCard(
                              sow: sow,
                              onDetail: () => _editSow(sow),
                              onDelete: () => _deleteSow(sow),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('Gestion des truies', 'Fitantanana kisoa vavy'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                '$count ${_t('truie', 'kisoa vavy')}${count > 1 ? (_isMg ? '' : 's') : ''} ${_t('enregistrée', 'voasoratra')}${count > 1 ? (_isMg ? '' : 's') : ''}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: _addSow,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: Text(_t('Ajouter', 'Manampy')),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText: _t('Rechercher par code ou nom...', 'Mikaroka amin\'ny laharana na anarana...'),
        prefixIcon: const Icon(LucideIcons.search, size: 18),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(LucideIcons.x, size: 16),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.entityRadius),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.entityRadius),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.entityRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
      ),
    );
  }
}
