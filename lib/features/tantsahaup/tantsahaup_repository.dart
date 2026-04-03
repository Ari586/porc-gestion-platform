import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'tantsahaup_models.dart';

class TantsahaUpRepository {
  static const _postsKey = 'tantsahaup_posts';
  static const _themeKey = 'tantsahaup_dark_mode';
  static const _apiBaseUrl = String.fromEnvironment('TANTSAHAUP_API_BASE_URL');

  String? get _baseUrl {
    final trimmed = _apiBaseUrl.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<TantsahaUpStateSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPosts = prefs.getString(_postsKey);
    final isDarkMode = prefs.getBool(_themeKey) ?? false;

    if (_baseUrl != null) {
      final remotePosts = await _fetchRemotePosts();
      if (remotePosts != null) {
        await _savePostsCache(remotePosts);
        return TantsahaUpStateSnapshot(
          isDarkMode: isDarkMode,
          posts: remotePosts,
        );
      }
    }

    if (storedPosts == null || storedPosts.isEmpty) {
      return TantsahaUpStateSnapshot(
        isDarkMode: isDarkMode,
        posts: _seedPosts(),
      );
    }

    try {
      final decoded = jsonDecode(storedPosts) as List<dynamic>;
      final posts = decoded
          .map((item) => TantsahaUpPost.fromJson(item as Map<String, dynamic>))
          .toList();
      return TantsahaUpStateSnapshot(isDarkMode: isDarkMode, posts: posts);
    } catch (_) {
      return TantsahaUpStateSnapshot(
        isDarkMode: isDarkMode,
        posts: _seedPosts(),
      );
    }
  }

  Future<void> savePosts(List<TantsahaUpPost> posts) async {
    if (_baseUrl != null) {
      await _savePostsCache(posts);
      return;
    }
    await _savePostsCache(posts);
  }

  Future<List<TantsahaUpPost>> createPost({
    required String authorName,
    required String authorInitials,
    required String content,
    required TantsahaUpComposerType type,
    String? imageBase64,
  }) async {
    if (_baseUrl == null) {
      final newPost = TantsahaUpPost(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        authorName: authorName,
        authorInitials: authorInitials,
        content: content.isEmpty ? 'Nouvelle publication' : content,
        createdAt: DateTime.now(),
        type: type,
        imageBase64: imageBase64,
      );
      final current = (await load()).posts;
      final updated = [newPost, ...current];
      await _savePostsCache(updated);
      return updated;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'author_name': authorName,
          'author_initials': authorInitials,
          'content': content.isEmpty ? 'Nouvelle publication' : content,
          'type': type.name,
          'image_base64': imageBase64,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final posts = await _fetchRemotePosts();
        if (posts != null) {
          await _savePostsCache(posts);
          return posts;
        }
      }
    } catch (_) {
      // Fall through to error below for explicit feedback.
    }

    throw Exception('Impossible de publier le post sur le backend.');
  }

  Future<List<TantsahaUpPost>> toggleLike({
    required String postId,
    required List<TantsahaUpPost> currentPosts,
  }) async {
    if (_baseUrl == null) {
      final updated = currentPosts.map((post) {
        if (post.id != postId) {
          return post;
        }
        final nextLiked = !post.isLiked;
        return post.copyWith(
          isLiked: nextLiked,
          likeCount: nextLiked
              ? post.likeCount + 1
              : (post.likeCount > 0 ? post.likeCount - 1 : 0),
        );
      }).toList();
      await _savePostsCache(updated);
      return updated;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/posts/$postId/like'),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final posts = await _fetchRemotePosts();
        if (posts != null) {
          await _savePostsCache(posts);
          return posts;
        }
      }
    } catch (_) {
      // Fall through to error below.
    }
    throw Exception('Impossible de liker ce post.');
  }

  Future<List<TantsahaUpPost>> incrementCounter({
    required String postId,
    required String action,
    required List<TantsahaUpPost> currentPosts,
  }) async {
    if (_baseUrl == null) {
      final updated = currentPosts.map((post) {
        if (post.id != postId) {
          return post;
        }
        switch (action) {
          case 'comment':
            return post.copyWith(commentCount: post.commentCount + 1);
          case 'share':
            return post.copyWith(shareCount: post.shareCount + 1);
          default:
            return post;
        }
      }).toList();
      await _savePostsCache(updated);
      return updated;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/posts/$postId/$action'),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final posts = await _fetchRemotePosts();
        if (posts != null) {
          await _savePostsCache(posts);
          return posts;
        }
      }
    } catch (_) {
      // Fall through to error below.
    }
    throw Exception('Impossible de mettre a jour ce post.');
  }

  Future<String> chatAssistant(String message) async {
    if (_baseUrl == null) {
      return "Le backend AgentScope n'est pas configure. Lance le serveur Docker et ajoute TANTSAHAUP_API_BASE_URL.";
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/assistant/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return (payload['reply'] ?? '') as String;
      }
      return (payload['detail'] ??
              payload['error'] ??
              'Assistant indisponible.')
          as String;
    } catch (_) {
      return "Impossible de joindre le backend AgentScope. Verifie que Docker tourne sur $_baseUrl.";
    }
  }

  Future<List<TantsahaUpPost>?> _fetchRemotePosts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/feed'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final posts = (payload['posts'] as List<dynamic>? ?? const [])
          .map((item) => TantsahaUpPost.fromJson(item as Map<String, dynamic>))
          .toList();
      return posts;
    } catch (_) {
      return null;
    }
  }

  Future<void> _savePostsCache(List<TantsahaUpPost> posts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _postsKey,
      jsonEncode(posts.map((post) => post.toJson()).toList()),
    );
  }

  Future<void> saveDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  List<TantsahaUpPost> _seedPosts() {
    return [
      TantsahaUpPost(
        id: 'seed-1',
        authorName: 'Justin Be Riziky',
        authorInitials: 'JR',
        content: '😍😍😍😍 Chocolat #111 #tinnay',
        createdAt: DateTime.now().subtract(const Duration(days: 72)),
        type: TantsahaUpComposerType.photo,
        likeCount: 24,
        commentCount: 7,
        shareCount: 3,
      ),
      TantsahaUpPost(
        id: 'seed-2',
        authorName: 'Miora Rabe',
        authorInitials: 'MR',
        content:
            'Alerte quartier: petite coupure d eau ce soir a Ambanidia. #se #quartier',
        createdAt: DateTime.now().subtract(const Duration(hours: 19)),
        type: TantsahaUpComposerType.debate,
        likeCount: 10,
        commentCount: 5,
        shareCount: 2,
      ),
    ];
  }
}
