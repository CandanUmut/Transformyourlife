class DailyCheckin {
  DailyCheckin({
    this.id,
    required this.userId,
    required this.date,
    this.mood,
    this.urgeLevel,
    this.slip = false,
    this.notes,
    this.halt = const {},
    this.lifestyle = const {},
    this.completedHabitIds = const [],
    this.insertedAt,
    this.updatedAt,
  });

  final int? id;
  final String userId;
  final DateTime date;
  final int? mood;
  final String? urgeLevel;
  final bool slip;
  final String? notes;
  final Map<String, dynamic> halt;
  final Map<String, dynamic> lifestyle;
  final List<int> completedHabitIds;
  final DateTime? insertedAt;
  final DateTime? updatedAt;

  factory DailyCheckin.fromJson(Map<String, dynamic> json) {
    return DailyCheckin(
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: (json['mood'] as num?)?.toInt(),
      urgeLevel: json['urge_level'] as String?,
      slip: json['slip'] as bool? ?? false,
      notes: json['notes'] as String?,
      halt: (json['halt'] as Map?)?.cast<String, dynamic>() ?? const {},
      lifestyle:
          (json['lifestyle'] as Map?)?.cast<String, dynamic>() ?? const {},
      completedHabitIds: (json['completed_habit_ids'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      insertedAt: json['inserted_at'] != null
          ? DateTime.parse(json['inserted_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T').first,
      'mood': mood,
      'urge_level': urgeLevel,
      'slip': slip,
      'notes': notes,
      'halt': halt,
      'lifestyle': lifestyle,
      'completed_habit_ids': completedHabitIds,
      'inserted_at': insertedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DailyCheckin copyWith({
    int? mood,
    String? urgeLevel,
    bool? slip,
    String? notes,
    Map<String, dynamic>? halt,
    Map<String, dynamic>? lifestyle,
    List<int>? completedHabitIds,
    DateTime? updatedAt,
  }) {
    return DailyCheckin(
      id: id,
      userId: userId,
      date: date,
      mood: mood ?? this.mood,
      urgeLevel: urgeLevel ?? this.urgeLevel,
      slip: slip ?? this.slip,
      notes: notes ?? this.notes,
      halt: halt ?? this.halt,
      lifestyle: lifestyle ?? this.lifestyle,
      completedHabitIds: completedHabitIds ?? this.completedHabitIds,
      insertedAt: insertedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
