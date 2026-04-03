import 'dart:convert';

enum TantsahaUpComposerType { photo, video, humour, debate }

enum TantsahaUpTab { home, about }

class TantsahaUpPost {
  final String id;
  final String authorName;
  final String authorInitials;
  final String content;
  final DateTime createdAt;
  final TantsahaUpComposerType type;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final String? imageBase64;

  const TantsahaUpPost({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.content,
    required this.createdAt,
    required this.type,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.imageBase64,
  });

  TantsahaUpPost copyWith({
    String? id,
    String? authorName,
    String? authorInitials,
    String? content,
    DateTime? createdAt,
    TantsahaUpComposerType? type,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
    String? imageBase64,
    bool clearImage = false,
  }) {
    return TantsahaUpPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorInitials: authorInitials ?? this.authorInitials,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      imageBase64: clearImage ? null : imageBase64 ?? this.imageBase64,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorInitials': authorInitials,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'isLiked': isLiked,
      'imageBase64': imageBase64,
    };
  }

  factory TantsahaUpPost.fromJson(Map<String, dynamic> json) {
    return TantsahaUpPost(
      id: (json['id'] ?? '') as String,
      authorName: (json['authorName'] ?? json['author_name']) as String,
      authorInitials:
          (json['authorInitials'] ?? json['author_initials']) as String,
      content: (json['content'] ?? '') as String,
      createdAt: DateTime.parse(
        (json['createdAt'] ?? json['created_at']) as String,
      ),
      type: TantsahaUpComposerType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => TantsahaUpComposerType.photo,
      ),
      likeCount:
          ((json['likeCount'] ?? json['like_count']) as num?)?.toInt() ?? 0,
      commentCount:
          ((json['commentCount'] ?? json['comment_count']) as num?)?.toInt() ??
          0,
      shareCount:
          ((json['shareCount'] ?? json['share_count']) as num?)?.toInt() ?? 0,
      isLiked: (json['isLiked'] ?? json['is_liked']) as bool? ?? false,
      imageBase64: (json['imageBase64'] ?? json['image_base64']) as String?,
    );
  }
}

class TantsahaUpStory {
  final String initials;
  final String label;
  final bool isCreateCard;

  const TantsahaUpStory({
    required this.initials,
    required this.label,
    this.isCreateCard = false,
  });
}

class TantsahaUpFeature {
  final String title;
  final String description;
  final int accentColorValue;

  const TantsahaUpFeature({
    required this.title,
    required this.description,
    required this.accentColorValue,
  });
}

class TantsahaUpStateSnapshot {
  final bool isDarkMode;
  final List<TantsahaUpPost> posts;

  const TantsahaUpStateSnapshot({
    required this.isDarkMode,
    required this.posts,
  });

  String encodePosts() {
    return jsonEncode(posts.map((post) => post.toJson()).toList());
  }
}
