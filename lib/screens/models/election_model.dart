// lib/models/note_model.dart

class Election {
  final int id;
  final String userId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  Election({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  factory Election.fromJson(Map<String, dynamic> json) {
    return Election(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
