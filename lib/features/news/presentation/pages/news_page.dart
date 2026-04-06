import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/providers/language_provider.dart';

class _NewsPost {
  final String id;
  final String authorName;
  final String authorRole;
  final DateTime createdAt;
  final String content;
  final String? imagePath;
  int likes;
  int comments;
  bool isLiked;
  final String? category;

  _NewsPost({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.createdAt,
    required this.content,
    this.imagePath,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.category,
  });
}

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends ConsumerState<NewsPage> {
  final _df = DateFormat('dd MMM, HH:mm', 'fr_FR');

  bool get _isMg => ref.watch(languageProvider) == 'Malagasy';

  String _t(String fr, String mg) => _isMg ? mg : fr;

  late List<_NewsPost> _posts;

  @override
  void initState() {
    super.initState();
  }

  void _initPosts() {
    _posts = [
      _NewsPost(
        id: '1',
        authorName: 'Dr Rakoto',
        authorRole: 'Vétérinaire',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        content: _t(
          'Rappel : campagne de vaccination anti-parvovirose prévue cette semaine.',
          'Fampahatsiahivana: fampielezan-kevitra momba ny fanaovana vaksiny anti-parvovirose amin\'ity herinandro ity.',
        ),
        likes: 24,
        comments: 5,
        category: _t('Santé', 'Fahasalamana'),
        imagePath: 'assets/images/pig_vet_check.png',
      ),
      _NewsPost(
        id: '2',
        authorName: 'Jean Razafy',
        authorRole: 'Responsable',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        content: _t(
          'Excellents résultats du mois de mars ! Notre taux de fertilité a grimpé à 82%.',
          'Vokatra tsara tamin\'ny volana martsa! Nitombo hatramin\'ny 82% ny taham-pahavokarana.',
        ),
        likes: 156,
        comments: 12,
        isLiked: true,
        category: _t('Résultats', 'Vokatra'),
        imagePath: 'assets/images/piglets_growth.png',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _initPosts(); // Re-initialize posts on build to pick up language changes
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildStoryBar()),
            SliverToBoxAdapter(child: _buildCreatePostArea()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPostCard(_posts[index]),
                  childCount: _posts.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.white.withOpacity(0.95),
      elevation: 0.5,
      centerTitle: false,
      title: Text(
        _t('Actualités', 'Vaovao farany'),
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
          letterSpacing: -1.2,
        ),
      ),
      actions: [
        _buildCircularAction(LucideIcons.search, () {}),
        const SizedBox(width: 10),
        _buildCircularAction(LucideIcons.bell, () {}),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildCircularAction(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.black87),
        onPressed: onTap,
        splashRadius: 24,
      ),
    );
  }

  Widget _buildStoryBar() {
    final stories = [
      {'name': _t('Maternité', 'Fiterahana'), 'icon': LucideIcons.baby, 'color': Colors.pink},
      {'name': _t('Santé', 'Fahasalamana'), 'icon': LucideIcons.heartPulse, 'color': Colors.red},
      {'name': _t('Stock', 'Tahiry'), 'icon': LucideIcons.package, 'color': Colors.orange},
      {'name': _t('Ventes', 'Varotra'), 'icon': LucideIcons.shoppingCart, 'color': Colors.teal},
      {'name': _t('Équipe', 'Ekipa'), 'icon': LucideIcons.users, 'color': Colors.blue},
    ];

    return Container(
      height: 125,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) return _buildAddStory();
          final story = stories[i - 1];
          return Container(
            width: 85,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: (story['color'] as Color).withOpacity(0.12),
                      child: Icon(story['icon'] as IconData, color: story['color'] as Color, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  story['name'] as String,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddStory() {
    return Container(
      width: 85,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 33,
                backgroundColor: Colors.grey[100],
                child: const Icon(LucideIcons.user, color: Colors.grey, size: 36),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _t('Votre story', 'Halehibe'),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostArea() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(LucideIcons.user, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey[300]!.withOpacity(0.5)),
                  ),
                  child: Text(
                    _t('Quoi de neuf ?', 'Inona no vaovao ?'),
                    style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(LucideIcons.video, _t('Direct', 'Mivantana'), Colors.redAccent),
              _buildQuickAction(LucideIcons.image, _t('Photo', 'Sary'), Colors.green),
              _buildQuickAction(LucideIcons.smile, _t('Humeur', 'Toe-po'), Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(_NewsPost post) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(post.authorName[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.2)),
                      Row(
                        children: [
                          Text(_df.format(post.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(width: 4),
                          const Text('•', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Icon(LucideIcons.globe, size: 12, color: Colors.grey[600]),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(LucideIcons.moreHorizontal, size: 20), onPressed: () {}),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              post.content,
              style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 12),
          if (post.imagePath != null)
             ClipRRect(
               child: Image.asset(
                 post.imagePath!,
                 width: double.infinity,
                 height: 350,
                 fit: BoxFit.cover,
                 errorBuilder: (context, error, stackTrace) => Container(
                   height: 200,
                   color: Colors.grey[100],
                   child: const Icon(LucideIcons.image, color: Colors.grey, size: 40),
                 ),
               ),
             ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFF1877F2), shape: BoxShape.circle),
                  child: const Icon(Icons.thumb_up, color: Colors.white, size: 10),
                ),
                const SizedBox(width: 6),
                Text('${post.likes}', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text('${post.comments} ${_t('comm.', 'comm.')}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(width: 8),
                Text('2 ${_t('partages', 'hizara')}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 24, thickness: 0.5),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInteractionButton(
                  LucideIcons.thumbsUp,
                  _t('J\'aime', 'Tiako'),
                  post.isLiked ? const Color(0xFF1877F2) : Colors.grey[700]!,
                  onTap: () => setState(() => post.isLiked = !post.isLiked),
                ),
                _buildInteractionButton(LucideIcons.messageSquare, _t('Commenter', 'Hevitra'), Colors.grey[700]!),
                _buildInteractionButton(LucideIcons.share2, _t('Partager', 'Hizara'), Colors.grey[700]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
