class JournalEntry {
  JournalEntry({
    this.id,
    required this.userId,
    this.createdAt,
    this.title,
    this.content,
  });

  final int? id;
  final String userId;
  final DateTime? createdAt;
  final String? title;
  final String? content;

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      title: json['title'] as String?,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'title': title,
      'content': content,
    };
  }

  JournalEntry copyWith({
    String? title,
    String? content,
  }) {
    return JournalEntry(
      id: id,
      userId: userId,
      createdAt: createdAt,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }
}
