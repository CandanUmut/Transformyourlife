class Habit {
  Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.path,
    this.createdAt,
    this.isActive = true,
  });

  final int id;
  final String userId;
  final String name;
  final String? path;
  final DateTime? createdAt;
  final bool isActive;

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: (json['id'] as num).toInt(),
      userId: json['user_id'] as String,
      name: json['name'] as String,
      path: json['path'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'path': path,
      'created_at': createdAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  Habit copyWith({
    String? name,
    String? path,
    bool? isActive,
  }) {
    return Habit(
      id: id,
      userId: userId,
      name: name ?? this.name,
      path: path ?? this.path,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
