import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'tantsahaup_models.dart';
import 'tantsahaup_repository.dart';

class TantsahaUpAppPage extends StatefulWidget {
  const TantsahaUpAppPage({super.key});

  @override
  State<TantsahaUpAppPage> createState() => _TantsahaUpAppPageState();
}

class _TantsahaUpAppPageState extends State<TantsahaUpAppPage> {
  final TantsahaUpRepository _repository = TantsahaUpRepository();
  final TextEditingController _composerController = TextEditingController();
  final TextEditingController _assistantController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _assistantFocusNode = FocusNode();

  bool _isLoading = true;
  bool _isDarkMode = false;
  bool _isSaving = false;
  bool _isAssistantLoading = false;
  TantsahaUpTab _tab = TantsahaUpTab.home;
  TantsahaUpComposerType _selectedType = TantsahaUpComposerType.photo;
  List<TantsahaUpPost> _posts = const [];
  final List<_AssistantMessage> _assistantMessages = [
    _AssistantMessage(
      role: _AssistantRole.assistant,
      text:
          'Bonjour. Je suis l’assistant TantsahaUp. Pose-moi une question sur la communaute ou le market.',
    ),
  ];
  Uint8List? _selectedImage;
  String? _selectedImageBase64;

  static const List<TantsahaUpStory> _stories = [
    TantsahaUpStory(
      initials: 'RK',
      label: 'Creer une story',
      isCreateCard: true,
    ),
    TantsahaUpStory(initials: 'JR', label: 'Justin'),
    TantsahaUpStory(initials: 'MR', label: 'Miora'),
  ];

  static const List<TantsahaUpFeature> _features = [
    TantsahaUpFeature(
      title: 'TantsahaUp Market (Smart Match)',
      description:
          'Publiez ce que vous cherchez, laissez les vendeurs repondre, et rapprochez offre et demande locale.',
      accentColorValue: 0xFF54A942,
    ),
    TantsahaUpFeature(
      title: 'TantsahaUp Radar',
      description:
          'Flux d informations locales pour embouteillages, coupures, evenements et alertes utiles.',
      accentColorValue: 0xFFEF4E65,
    ),
    TantsahaUpFeature(
      title: 'SOS Papiers',
      description:
          'Diffusez rapidement une alerte de document perdu ou trouve dans votre zone.',
      accentColorValue: 0xFFF97316,
    ),
    TantsahaUpFeature(
      title: "L'Arene",
      description:
          'Un espace de debat structure ou l on garde les echanges clairs et lisibles.',
      accentColorValue: 0xFF6D4DD8,
    ),
    TantsahaUpFeature(
      title: 'Alerte Quartier',
      description:
          'Un bouton communautaire pour signaler un danger ou une situation urgente a proximite.',
      accentColorValue: 0xFFE11D48,
    ),
    TantsahaUpFeature(
      title: 'Coup de Main',
      description:
          'Demandez un petit service localement et laissez la communaute repondre.',
      accentColorValue: 0xFF5C5CEB,
    ),
    TantsahaUpFeature(
      title: 'Mode Zero (Eco)',
      description:
          'Passez en mode leger pour continuer a utiliser l app avec une faible connexion.',
      accentColorValue: 0xFF475467,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void dispose() {
    _composerController.dispose();
    _assistantController.dispose();
    _scrollController.dispose();
    _assistantFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final snapshot = await _repository.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _posts = snapshot.posts;
      _isDarkMode = snapshot.isDarkMode;
      _isLoading = false;
    });
  }

  Future<void> _toggleTheme() async {
    final nextValue = !_isDarkMode;
    setState(() {
      _isDarkMode = nextValue;
    });
    await _repository.saveDarkMode(nextValue);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null || !mounted) {
      return;
    }
    setState(() {
      _selectedImage = bytes;
      _selectedImageBase64 = base64Encode(bytes);
    });
  }

  Future<void> _publishPost() async {
    final text = _composerController.text.trim();
    if (text.isEmpty && _selectedImageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez un texte ou une image avant de publier.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedPosts = await _repository.createPost(
        authorName: 'rindra kattie',
        authorInitials: 'RK',
        content: text,
        type: _selectedType,
        imageBase64: _selectedImageBase64,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = updatedPosts;
        _composerController.clear();
        _selectedImage = null;
        _selectedImageBase64 = null;
        _isSaving = false;
        _tab = TantsahaUpTab.home;
      });
    } catch (exc) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      _showSnackBar('$exc');
      return;
    }
    if (!mounted) {
      return;
    }
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _toggleLike(String id) async {
    try {
      final updatedPosts = await _repository.toggleLike(
        postId: id,
        currentPosts: _posts,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = updatedPosts;
      });
    } catch (exc) {
      _showSnackBar('$exc');
    }
  }

  Future<void> _incrementCounter(String id, String type) async {
    try {
      final updatedPosts = await _repository.incrementCounter(
        postId: id,
        action: type,
        currentPosts: _posts,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = updatedPosts;
      });
    } catch (exc) {
      _showSnackBar('$exc');
    }
  }

  Future<void> _sendAssistantMessage() async {
    final message = _assistantController.text.trim();
    if (message.isEmpty || _isAssistantLoading) {
      return;
    }

    setState(() {
      _assistantMessages.add(
        _AssistantMessage(role: _AssistantRole.user, text: message),
      );
      _assistantController.clear();
      _isAssistantLoading = true;
    });

    try {
      final reply = await _repository.chatAssistant(message);
      if (!mounted) {
        return;
      }
      setState(() {
        _assistantMessages.add(
          _AssistantMessage(role: _AssistantRole.assistant, text: reply),
        );
        _isAssistantLoading = false;
      });
    } catch (exc) {
      if (!mounted) {
        return;
      }
      setState(() {
        _assistantMessages.add(
          _AssistantMessage(
            role: _AssistantRole.assistant,
            text: 'Erreur assistant: $exc',
          ),
        );
        _isAssistantLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<MapEntry<String, int>> _trendingTags() {
    final counts = <String, int>{};
    for (final post in _posts) {
      final matches = RegExp(r'#([A-Za-z0-9_]+)').allMatches(post.content);
      for (final match in matches) {
        final tag = '#${match.group(1)}';
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _TantsahaUpPalette(_isDarkMode);
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: palette.background,
        colorScheme: theme.colorScheme.copyWith(
          surface: palette.surface,
          primary: palette.blue,
          onSurface: palette.text,
        ),
      ),
      child: Scaffold(
        backgroundColor: palette.background,
        drawer: LayoutBuilder(
          builder: (context, constraints) {
            final width = MediaQuery.of(context).size.width;
            if (width > 860) {
              return const SizedBox.shrink();
            }
            return Drawer(
              child: SafeArea(
                child: _SidebarMenu(
                  palette: palette,
                  onSelectAbout: () {
                    Navigator.of(context).pop();
                    setState(() => _tab = TantsahaUpTab.about);
                  },
                ),
              ),
            );
          },
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: palette.blue))
            : SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final showRightRail = width >= 1150;
                    final showLeftRail = width >= 860;
                    return Column(
                      children: [
                        _buildTopBar(
                          context: context,
                          palette: palette,
                          showMenuButton: !showLeftRail,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1280,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showLeftRail)
                                      SizedBox(
                                        width: 280,
                                        child: _SidebarMenu(
                                          palette: palette,
                                          onSelectAbout: () {
                                            setState(
                                              () => _tab = TantsahaUpTab.about,
                                            );
                                          },
                                        ),
                                      ),
                                    if (showLeftRail) const SizedBox(width: 28),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 520,
                                          ),
                                          child: _tab == TantsahaUpTab.home
                                              ? _buildHomeFeed(palette)
                                              : _buildAboutPage(palette),
                                        ),
                                      ),
                                    ),
                                    if (showRightRail)
                                      const SizedBox(width: 28),
                                    if (showRightRail)
                                      SizedBox(
                                        width: 280,
                                        child: _RightRail(
                                          palette: palette,
                                          trends: _trendingTags(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildTopBar({
    required BuildContext context,
    required _TantsahaUpPalette palette,
    required bool showMenuButton,
  }) {
    final isAbout = _tab == TantsahaUpTab.about;
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.line)),
        boxShadow: [palette.shadow],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showMenuButton)
            IconButton(
              onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
              icon: Icon(Icons.menu, color: palette.text),
            ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.blue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              't',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.search, color: palette.muted, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: isAbout
                            ? 'tantsahaup/about'
                            : 'Rechercher...',
                        hintStyle: TextStyle(color: palette.muted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          if (MediaQuery.of(context).size.width >= 860)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TopNavButton(
                    palette: palette,
                    icon: Icons.home_filled,
                    isActive: _tab == TantsahaUpTab.home,
                    onTap: () => setState(() => _tab = TantsahaUpTab.home),
                  ),
                  _TopNavButton(
                    palette: palette,
                    icon: Icons.ondemand_video_rounded,
                    isActive: false,
                    onTap: () {},
                  ),
                  _TopNavButton(
                    palette: palette,
                    icon: Icons.balance_outlined,
                    isActive: false,
                    onTap: () {},
                  ),
                  _TopNavButton(
                    palette: palette,
                    icon: Icons.wifi_tethering_rounded,
                    isActive: false,
                    onTap: () {},
                  ),
                  _TopNavButton(
                    palette: palette,
                    icon: Icons.storefront_rounded,
                    isActive: _tab == TantsahaUpTab.about,
                    onTap: () => setState(() => _tab = TantsahaUpTab.about),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),
          _CircleAction(
            palette: palette,
            icon: Icons.chat_bubble,
            onTap: () {
              setState(() {
                _tab = TantsahaUpTab.home;
              });
              _assistantFocusNode.requestFocus();
            },
          ),
          const SizedBox(width: 8),
          _CircleAction(
            palette: palette,
            icon: Icons.notifications,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _CircleAction(palette: palette, icon: Icons.groups, onTap: () {}),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF4F46B8),
              shape: BoxShape.circle,
            ),
            child: const Text(
              'RK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleAction(
            palette: palette,
            icon: _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            onTap: _toggleTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeFeed(_TantsahaUpPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SurfaceCard(
          palette: palette,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  const _AvatarBadge(initials: 'RK', size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _composerController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Quoi de neuf ?',
                        hintStyle: TextStyle(color: palette.muted),
                        fillColor: palette.background,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.sentiment_satisfied_alt,
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: palette.line, height: 1),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ComposerChip(
                    palette: palette,
                    icon: Icons.photo,
                    label: 'Photo',
                    color: const Color(0xFF4CAF50),
                    isSelected: _selectedType == TantsahaUpComposerType.photo,
                    onTap: () async {
                      setState(
                        () => _selectedType = TantsahaUpComposerType.photo,
                      );
                      await _pickImage();
                    },
                  ),
                  _ComposerChip(
                    palette: palette,
                    icon: Icons.videocam,
                    label: 'Video',
                    color: const Color(0xFFF43F5E),
                    isSelected: _selectedType == TantsahaUpComposerType.video,
                    onTap: () => setState(
                      () => _selectedType = TantsahaUpComposerType.video,
                    ),
                  ),
                  _ComposerChip(
                    palette: palette,
                    icon: Icons.emoji_emotions,
                    label: 'Humour',
                    color: const Color(0xFFEAB308),
                    isSelected: _selectedType == TantsahaUpComposerType.humour,
                    onTap: () => setState(
                      () => _selectedType = TantsahaUpComposerType.humour,
                    ),
                  ),
                  _ComposerChip(
                    palette: palette,
                    icon: Icons.balance,
                    label: 'Debat',
                    color: const Color(0xFF8B5CF6),
                    isSelected: _selectedType == TantsahaUpComposerType.debate,
                    onTap: () => setState(
                      () => _selectedType = TantsahaUpComposerType.debate,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _publishPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    child: Text(_isSaving ? '...' : 'Publier'),
                  ),
                ],
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _selectedImage!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        _AssistantPanel(
          palette: palette,
          controller: _assistantController,
          focusNode: _assistantFocusNode,
          messages: _assistantMessages,
          isLoading: _isAssistantLoading,
          onSend: _sendAssistantMessage,
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 165,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) =>
                _StoryCard(story: _stories[index], palette: palette),
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: _stories.length,
          ),
        ),
        const SizedBox(height: 18),
        ..._posts.map(
          (post) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _PostCard(
              post: post,
              palette: palette,
              onLike: () => _toggleLike(post.id),
              onComment: () => _incrementCounter(post.id, 'comment'),
              onShare: () => _incrementCounter(post.id, 'share'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutPage(_TantsahaUpPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.line)),
          ),
          child: Text(
            '🚀 Les Innovations TantsahaUp (Smart Features)',
            style: TextStyle(
              color: palette.text,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final useSingleColumn = constraints.maxWidth < 700;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: useSingleColumn ? 1 : 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: useSingleColumn ? 1.6 : 1.2,
              ),
              itemCount: _features.length,
              itemBuilder: (context, index) {
                final feature = _features[index];
                return _SurfaceCard(
                  palette: palette,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.title,
                        style: TextStyle(
                          color: Color(feature.accentColorValue),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        feature.description,
                        style: TextStyle(
                          color: palette.text,
                          height: 1.55,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _SidebarMenu extends StatelessWidget {
  final _TantsahaUpPalette palette;
  final VoidCallback onSelectAbout;

  const _SidebarMenu({required this.palette, required this.onSelectAbout});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SidebarItem('Accueil', Icons.home, const Color(0xFF1877F2), null),
      _SidebarItem(
        'Activer les Alertes',
        Icons.notification_important,
        const Color(0xFFD97706),
        null,
      ),
      _SidebarItem(
        'Mode Zero (Eco)',
        Icons.wifi_off,
        const Color(0xFF111827),
        null,
      ),
      _SidebarItem('Ami(e)s', Icons.groups, const Color(0xFF1877F2), null),
      _SidebarItem('Reels', Icons.slideshow, const Color(0xFFEF476F), null),
      _SidebarItem('Groupes', Icons.group_work, const Color(0xFF1877F2), null),
      _SidebarItem('Pages', Icons.flag, const Color(0xFFD4A017), null),
      _SidebarItem(
        'Lancer un Debat',
        Icons.balance,
        const Color(0xFF7C3AED),
        null,
      ),
      _SidebarItem(
        'TantsahaUp Market',
        Icons.storefront,
        const Color(0xFF4CAF50),
        null,
      ),
      _SidebarItem(
        'TantsahaUp AI Assistant',
        Icons.auto_awesome,
        const Color(0xFF9333EA),
        null,
      ),
      _SidebarItem(
        'TantsahaUp Radar',
        Icons.radar,
        const Color(0xFFEF4444),
        null,
      ),
      _SidebarItem('SOS Papiers', Icons.badge, const Color(0xFFEA580C), null),
      _SidebarItem(
        'Match Secret',
        Icons.favorite,
        const Color(0xFFDB2777),
        null,
      ),
      _SidebarItem(
        'Alerte Quartier',
        Icons.notifications_active,
        const Color(0xFFE11D48),
        null,
      ),
      _SidebarItem(
        'Coup de Main',
        Icons.volunteer_activism,
        const Color(0xFF7C3AED),
        null,
      ),
      _SidebarItem(
        'Laoka du Jour',
        Icons.restaurant,
        const Color(0xFFF59E0B),
        null,
      ),
      _SidebarItem(
        'A propos',
        Icons.info,
        const Color(0xFF6B7280),
        onSelectAbout,
      ),
      _SidebarItem(
        'Espace Ambassadeur',
        Icons.eco,
        const Color(0xFF4CAF50),
        null,
        isSpecial: true,
      ),
      _SidebarItem(
        'Mises a jour',
        Icons.campaign,
        const Color(0xFF1877F2),
        null,
      ),
      _SidebarItem(
        'Coach Linguistique',
        Icons.headset_mic,
        const Color(0xFF4CAF50),
        null,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              const _AvatarBadge(initials: 'RK', size: 36),
              const SizedBox(width: 12),
              Text(
                'rindra kattie',
                style: TextStyle(
                  color: palette.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: item.onTap,
                child: Container(
                  decoration: item.isSpecial
                      ? BoxDecoration(
                          border: Border.all(color: const Color(0xFF9FD48C)),
                          color: const Color(0xFFF1FFEA),
                          borderRadius: BorderRadius.circular(8),
                        )
                      : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, color: item.color, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color:
                                item.label == 'Activer les Alertes' ||
                                    item.label == 'Alerte Quartier'
                                ? const Color(0xFFDF6B00)
                                : item.isSpecial
                                ? const Color(0xFF4C7C2F)
                                : palette.text,
                            fontWeight:
                                item.label == 'Accueil' ||
                                    item.label == 'Activer les Alertes' ||
                                    item.label == 'Alerte Quartier' ||
                                    item.isSpecial
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'A propos · Confidentialite · CGU · Mises a jour',
          style: TextStyle(color: palette.muted, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          '© 2026 TantsahaUp · Powered by Mada Tools Media',
          style: TextStyle(color: palette.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _RightRail extends StatelessWidget {
  final _TantsahaUpPalette palette;
  final List<MapEntry<String, int>> trends;

  const _RightRail({required this.palette, required this.trends});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SurfaceCard(
          palette: palette,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Contacts',
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(Icons.search, color: palette.muted, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Ajoutez des amis pour discuter !',
                  style: TextStyle(color: palette.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _SurfaceCard(
          palette: palette,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tendances pour vous',
                style: TextStyle(
                  color: palette.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              ...trends.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final tag = entry.value.key;
                final count = entry.value.value;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: palette.line)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$rank. $tag',
                        style: TextStyle(
                          color: palette.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$count posts',
                        style: TextStyle(color: palette.muted, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopNavButton extends StatelessWidget {
  final _TantsahaUpPalette palette;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TopNavButton({
    required this.palette,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 112,
        height: 50,
        decoration: BoxDecoration(
          border: isActive
              ? Border(bottom: BorderSide(color: palette.blue, width: 3))
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isActive ? palette.blue : palette.muted,
          size: 28,
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final _TantsahaUpPalette palette;
  final IconData icon;
  final VoidCallback onTap;

  const _CircleAction({
    required this.palette,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.background,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: palette.text, size: 20),
        ),
      ),
    );
  }
}

class _ComposerChip extends StatelessWidget {
  final _TantsahaUpPalette palette;
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ComposerChip({
    required this.palette,
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? palette.blueSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? palette.text : palette.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantPanel extends StatelessWidget {
  final _TantsahaUpPalette palette;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<_AssistantMessage> messages;
  final bool isLoading;
  final VoidCallback onSend;

  const _AssistantPanel({
    required this.palette,
    required this.controller,
    required this.focusNode,
    required this.messages,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      palette: palette,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: palette.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'TantsahaUp AI Assistant',
                style: TextStyle(
                  color: palette.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message.role == _AssistantRole.user;
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? palette.blue : palette.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.line),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isUser ? Colors.white : palette.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: messages.length,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'Posez une question sur la communaute...',
                    hintStyle: TextStyle(color: palette.muted),
                    fillColor: palette.background,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isLoading ? null : onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isLoading ? '...' : 'Envoyer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final TantsahaUpStory story;
  final _TantsahaUpPalette palette;

  const _StoryCard({required this.story, required this.palette});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      palette: palette,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF4F46B8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                alignment: Alignment.center,
                child: Text(
                  story.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (story.isCreateCard)
                    Positioned(
                      top: -18,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: palette.blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: palette.surface,
                              width: 4,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        story.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.text,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final TantsahaUpPost post;
  final _TantsahaUpPalette palette;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const _PostCard({
    required this.post,
    required this.palette,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMM', 'fr_FR').format(post.createdAt);
    final image = post.imageBase64 == null
        ? null
        : base64Decode(post.imageBase64!);

    return _SurfaceCard(
      palette: palette,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _AvatarBadge(initials: post.authorInitials, size: 40),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: TextStyle(
                            color: palette.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$formattedDate · ⦿',
                          style: TextStyle(color: palette.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(Icons.more_horiz, color: palette.muted),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Text(
              post.content,
              style: TextStyle(color: palette.text, fontSize: 15),
            ),
          ),
          if (image != null)
            Image.memory(image, height: 360, fit: BoxFit.cover)
          else
            SizedBox(
              height: 520,
              child: CustomPaint(
                painter: _PortraitPainter(isDarkMode: palette.isDarkMode),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                Text(
                  '${post.likeCount} J\'aime',
                  style: TextStyle(color: palette.muted, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '${post.commentCount} commentaires',
                  style: TextStyle(color: palette.muted, fontSize: 13),
                ),
                const SizedBox(width: 12),
                Text(
                  '${post.shareCount} partages',
                  style: TextStyle(color: palette.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Divider(color: palette.line, height: 1),
          SizedBox(
            height: 44,
            child: Row(
              children: [
                _PostActionButton(
                  palette: palette,
                  label: "J'aime",
                  icon: post.isLiked
                      ? Icons.thumb_up
                      : Icons.thumb_up_alt_outlined,
                  active: post.isLiked,
                  onTap: onLike,
                ),
                _PostActionButton(
                  palette: palette,
                  label: 'Commenter',
                  icon: Icons.mode_comment_outlined,
                  onTap: onComment,
                ),
                _PostActionButton(
                  palette: palette,
                  label: 'Partager',
                  icon: Icons.reply,
                  onTap: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final _TantsahaUpPalette palette;
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _PostActionButton({
    required this.palette,
    required this.label,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? palette.blue : palette.muted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? palette.blue : palette.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final _TantsahaUpPalette palette;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({
    required this.palette,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.line),
        boxShadow: [palette.shadow],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String initials;
  final double size;

  const _AvatarBadge({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF4F46B8),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

class _SidebarItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isSpecial;

  const _SidebarItem(
    this.label,
    this.icon,
    this.color,
    this.onTap, {
    this.isSpecial = false,
  });
}

enum _AssistantRole { user, assistant }

class _AssistantMessage {
  final _AssistantRole role;
  final String text;

  const _AssistantMessage({required this.role, required this.text});
}

class _TantsahaUpPalette {
  final bool isDarkMode;

  const _TantsahaUpPalette(this.isDarkMode);

  Color get background =>
      isDarkMode ? const Color(0xFF18191A) : const Color(0xFFF0F2F5);
  Color get surface => isDarkMode ? const Color(0xFF242526) : Colors.white;
  Color get surfaceSoft =>
      isDarkMode ? const Color(0xFF3A3B3C) : const Color(0xFFF7F8FA);
  Color get line =>
      isDarkMode ? const Color(0xFF3F4144) : const Color(0xFFDFE3E8);
  Color get text =>
      isDarkMode ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21);
  Color get muted =>
      isDarkMode ? const Color(0xFFB0B3B8) : const Color(0xFF6B7280);
  Color get blue => const Color(0xFF1877F2);
  Color get blueSoft =>
      isDarkMode ? const Color(0x2E1877F2) : const Color(0xFFE7F3FF);
  BoxShadow get shadow => BoxShadow(
    color: isDarkMode ? const Color(0x4D000000) : const Color(0x1A101828),
    blurRadius: 2,
    offset: const Offset(0, 1),
  );
}

class _PortraitPainter extends CustomPainter {
  final bool isDarkMode;

  const _PortraitPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF0E5D7), Color(0xFFDDD0BF), Color(0xFFCABAA8)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final linePaint = Paint()
      ..color = const Color(0x66574339)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, size.height * 0.18),
      Offset(size.width, size.height * 0.12),
      linePaint,
    );

    final hairRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.47),
      width: size.width * 0.55,
      height: size.height * 0.66,
    );
    final hairPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF17141A),
          Color(0xFF2B232B),
          Color(0xFF16161D),
          Color(0xFF46343A),
        ],
      ).createShader(hairRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(hairRect, const Radius.circular(130)),
      hairPaint,
    );

    final facePaint = Paint()..color = const Color(0xFFF1D1BF);
    final faceRect = Rect.fromCenter(
      center: Offset(size.width * 0.51, size.height * 0.53),
      width: size.width * 0.28,
      height: size.height * 0.34,
    );
    canvas.drawOval(faceRect, facePaint);

    final shoulderPaint = Paint()
      ..shader =
          const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A4B3D), Color(0xFF3B2A27)],
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height * 0.72,
              size.width,
              size.height * 0.28,
            ),
          );
    final shoulderPath = Path()
      ..moveTo(size.width * 0.18, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.64,
        size.width * 0.82,
        size.height * 0.78,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(shoulderPath, shoulderPaint);
  }

  @override
  bool shouldRepaint(covariant _PortraitPainter oldDelegate) {
    return oldDelegate.isDarkMode != isDarkMode;
  }
}
