import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';

class _NewsPost {
  final String id;
  final String authorName;
  final String authorRole;
  final DateTime createdAt;
  final String content;
  final int likes;
  final int comments;
  final String? category;

  const _NewsPost({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.createdAt,
    required this.content,
    this.likes = 0,
    this.comments = 0,
    this.category,
  });
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final _df = DateFormat('dd MMM yyyy, HH:mm', 'fr_FR');

  final _posts = <_NewsPost>[
    _NewsPost(
      id: '1',
      authorName: 'Dr Rakoto',
      authorRole: 'Vétérinaire',
      createdAt: DateTime(2026, 4, 1, 8, 30),
      content: 'Rappel : campagne de vaccination anti-parvovirose prévue cette semaine. Merci de signaler les truies gestantes pour adapter le calendrier.',
      likes: 5,
      comments: 2,
      category: 'Santé',
    ),
    _NewsPost(
      id: '2',
      authorName: 'Jean Razafy',
      authorRole: 'Responsable',
      createdAt: DateTime(2026, 3, 31, 14, 0),
      content: 'Excellents résultats du mois de mars : taux de fertilité à 82%, 48 porcelets nés vivants. Félicitations à toute l\'équipe !',
      likes: 12,
      comments: 4,
      category: 'Résultats',
    ),
    _NewsPost(
      id: '3',
      authorName: 'Marie Rabe',
      authorRole: 'Éleveur',
      createdAt: DateTime(2026, 3, 30, 10, 15),
      content: 'Le verrat V-002 (Atlas) a montré une baisse de motilité lors du dernier prélèvement. À surveiller lors du prochain contrôle qualité.',
      likes: 3,
      comments: 6,
      category: 'Reproduction',
    ),
    _NewsPost(
      id: '4',
      authorName: 'Paul Andria',
      authorRole: 'Inséminateur',
      createdAt: DateTime(2026, 3, 29, 16, 45),
      content: 'Nouvelle livraison d\'aliment porcelet reçue ce matin. Stock mis à jour. Attention : le lot a une date limite plus courte que d\'habitude (30 jours).',
      likes: 2,
      comments: 1,
      category: 'Stock',
    ),
    _NewsPost(
      id: '5',
      authorName: 'Jean Razafy',
      authorRole: 'Responsable',
      createdAt: DateTime(2026, 3, 28, 9, 0),
      content: 'Réunion d\'équipe prévue lundi prochain à 10h pour planifier les inséminations du mois d\'avril et discuter de l\'agrandissement du bâtiment maternité.',
      likes: 8,
      comments: 3,
      category: 'Organisation',
    ),
  ];

  String _activeCategory = 'Tous';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.s14),
                  _buildCategoryChips(),
                  const SizedBox(height: AppSpacing.s16),
                  _buildNewsFeed(),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.newsHeaderStart, AppColors.newsHeaderEnd],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actualités', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: AppSpacing.s4),
                Text('Fil d\'actualités de l\'exploitation', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Publier'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['Tous', 'Santé', 'Reproduction', 'Résultats', 'Stock', 'Organisation'];
    return Wrap(
      spacing: 8,
      children: categories.map((cat) => ChoiceChip(
        label: Text(cat),
        selected: _activeCategory == cat,
        selectedColor: AppColors.primaryPale,
        onSelected: (_) => setState(() => _activeCategory = cat),
      )).toList(),
    );
  }

  Widget _buildNewsFeed() {
    final filtered = _activeCategory == 'Tous' ? _posts : _posts.where((p) => p.category == _activeCategory).toList();
    if (filtered.isEmpty) {
      return SectionCard(
        title: 'Aucune actualité',
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.s24),
            child: Text('Aucun post dans cette catégorie.', style: TextStyle(color: AppColors.textMuted)),
          ),
        ),
      );
    }
    return Column(
      children: filtered.map((post) => _buildPostCard(post)).toList(),
    );
  }

  Widget _buildPostCard(_NewsPost post) {
    final roleColor = post.authorRole == 'Vétérinaire'
        ? AppColors.error
        : post.authorRole == 'Responsable'
            ? AppColors.primary
            : post.authorRole == 'Inséminateur'
                ? AppColors.info
                : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.newsCardSurface,
        borderRadius: BorderRadius.circular(AppUiTokens.entityRadius),
        border: Border.all(color: AppColors.newsCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: roleColor.withAlpha(20),
                child: Text(post.authorName.split(' ').map((w) => w[0]).take(2).join(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: roleColor)),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: roleColor.withAlpha(20), borderRadius: BorderRadius.circular(999)),
                      child: Text(post.authorRole, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: roleColor)),
                    ),
                    const SizedBox(width: 6),
                    Text(_df.format(post.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ]),
                ],
              )),
              if (post.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(999)),
                  child: Text(post.category!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(post.content, style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              _buildAction(LucideIcons.heart, '${post.likes}', AppColors.error),
              const SizedBox(width: AppSpacing.s16),
              _buildAction(LucideIcons.messageCircle, '${post.comments}', AppColors.info),
              const Spacer(),
              Icon(LucideIcons.share2, size: 16, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withAlpha(150)),
        const SizedBox(width: 4),
        Text(count, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
