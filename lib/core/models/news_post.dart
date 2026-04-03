import '../constants/roles.dart';
import 'json_helpers.dart';

class NewsComment {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  const NewsComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  static NewsComment? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final authorId = JsonHelpers.readString(json['authorId']).trim();
    final authorName = JsonHelpers.readString(json['authorName']).trim();
    final text = JsonHelpers.readString(json['text']).trim();
    final createdAt = JsonHelpers.parseDateTime(JsonHelpers.readString(json['createdAt']));
    if (id.isEmpty || authorName.isEmpty || text.isEmpty || createdAt == null) {
      return null;
    }
    return NewsComment(
      id: id,
      authorId: authorId,
      authorName: authorName,
      text: text,
      createdAt: createdAt,
    );
  }
}

class NewsPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String text;
  final DateTime createdAt;
  final String imageBase64;
  final String imageName;
  final List<String> likedByUserIds;
  final List<NewsComment> comments;

  const NewsPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.text,
    required this.createdAt,
    this.imageBase64 = '',
    this.imageName = '',
    this.likedByUserIds = const [],
    this.comments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'text': text,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'imageBase64': imageBase64,
      'imageName': imageName,
      'likedByUserIds': likedByUserIds,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  static NewsPost? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final authorId = JsonHelpers.readString(json['authorId']).trim();
    final authorName = JsonHelpers.readString(json['authorName']).trim();
    final authorRole = JsonHelpers.readString(json['authorRole']).trim();
    final text = JsonHelpers.readString(json['text']).trim();
    final createdAt = JsonHelpers.parseDateTime(JsonHelpers.readString(json['createdAt']));
    final imageBase64 = JsonHelpers.readString(json['imageBase64']).trim();
    if (id.isEmpty || authorName.isEmpty || createdAt == null || (text.isEmpty && imageBase64.isEmpty)) {
      return null;
    }
    final comments = <NewsComment>[];
    if (json['comments'] is List) {
      for (final item in (json['comments'] as List)) {
        if (item is! Map) continue;
        final comment = NewsComment.fromJson(Map<String, dynamic>.from(item));
        if (comment != null) comments.add(comment);
      }
    }
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return NewsPost(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole.isEmpty ? Roles.breeder : authorRole,
      text: text,
      createdAt: createdAt,
      imageBase64: imageBase64,
      imageName: JsonHelpers.readString(json['imageName']).trim(),
      likedByUserIds: JsonHelpers.readStringList(json['likedByUserIds']),
      comments: comments,
    );
  }
}
