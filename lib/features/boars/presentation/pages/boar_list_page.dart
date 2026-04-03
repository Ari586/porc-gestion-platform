import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/boar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/providers.dart';
import '../widgets/boar_card.dart';
import '../widgets/boar_form_dialog.dart';

class BoarListPage extends ConsumerStatefulWidget {
  const BoarListPage({super.key});

  @override
  ConsumerState<BoarListPage> createState() => _BoarListPageState();
}

class _BoarListPageState extends ConsumerState<BoarListPage> {
  String _searchQuery = '';

  List<Boar> _filter(List<Boar> boars) {
    if (_searchQuery.isEmpty) return boars;
    final q = _searchQuery.toLowerCase();
    return boars
        .where((b) =>
            b.code.toLowerCase().contains(q) ||
            b.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _addBoar() async {
    final result = await BoarFormDialog.show(context);
    if (result != null) {
      await ref.read(boarRepositoryProvider).add(result);
    }
  }

  Future<void> _deleteBoar(Boar boar) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Supprimer le verrat',
      message:
          'Voulez-vous vraiment supprimer le verrat "${boar.name}" (${boar.code}) ? Cette action est irréversible.',
      confirmLabel: 'Supprimer',
      isDestructive: true,
    );
    if (confirmed) {
      await ref.read(boarRepositoryProvider).delete(boar.id);
    }
  }

  void _showDetail(Boar boar) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detail de ${boar.name} (${boar.code})'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final boarsAsync = ref.watch(boarListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, textTheme, boarsAsync.valueOrNull?.length ?? 0),
              const SizedBox(height: AppSpacing.s16),
              _buildSearchBar(context, textTheme),
              const SizedBox(height: AppSpacing.s16),
              boarsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Erreur de chargement',
                      style: TextStyle(color: AppColors.error)),
                ),
                data: (boars) {
                  final filtered = _filter(boars);
                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: LucideIcons.piggyBank,
                      message: _searchQuery.isNotEmpty
                          ? 'Aucun verrat ne correspond à votre recherche.'
                          : 'Aucun verrat enregistré.\nCommencez par en ajouter un.',
                      actionLabel:
                          _searchQuery.isEmpty ? 'Ajouter un verrat' : null,
                      onAction: _searchQuery.isEmpty ? _addBoar : null,
                    );
                  }
                  return _buildGrid(context, filtered);
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

  Widget _buildHeader(BuildContext context, TextTheme textTheme, int count) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestion des verrats',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                '$count verrat${count > 1 ? 's' : ''} enregistre${count > 1 ? 's' : ''}',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: _addBoar,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Ajouter'),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Rechercher par code ou nom...',
          hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          prefixIcon:
              const Icon(LucideIcons.search, size: 18, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s12,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<Boar> boars) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int crossAxisCount;
        if (width > 1180) {
          crossAxisCount = 4;
        } else if (width > 820) {
          crossAxisCount = 3;
        } else if (width > 560) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.s12,
            mainAxisSpacing: AppSpacing.s12,
            childAspectRatio: 0.62,
          ),
          itemCount: boars.length,
          itemBuilder: (context, index) {
            final boar = boars[index];
            return BoarCard(
              boar: boar,
              onDetail: () => _showDetail(boar),
              onDelete: () => _deleteBoar(boar),
            );
          },
        );
      },
    );
  }
}
