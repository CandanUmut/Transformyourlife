class Profile {
  Profile({
    required this.id,
    this.createdAt,
    this.primaryFocus,
    this.paths = const [],
    this.identityStatement,
    this.values,
  });

  final String id;
  final DateTime? createdAt;
  final String? primaryFocus;
  final List<String> paths;
  final String? identityStatement;
  final String? values;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      primaryFocus: json['primary_focus'] as String?,
      paths:
          (json['paths'] as List?)?.map((e) => e as String).toList() ?? const [],
      identityStatement: json['identity_statement'] as String?,
      values: json['values'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'primary_focus': primaryFocus,
      'paths': paths,
      'identity_statement': identityStatement,
      'values': values,
    };
  }

  Profile copyWith({
    String? primaryFocus,
    List<String>? paths,
    String? identityStatement,
    String? values,
  }) {
    return Profile(
      id: id,
      createdAt: createdAt,
      primaryFocus: primaryFocus ?? this.primaryFocus,
      paths: paths ?? this.paths,
      identityStatement: identityStatement ?? this.identityStatement,
      values: values ?? this.values,
    );
  }
}
