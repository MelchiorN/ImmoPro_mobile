class NotificationModel {
  final String id;
  final String type;
  final String titre;
  final String message;
  final Map<String, dynamic>? data;
  final bool lu;
  final DateTime? luAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.titre,
    required this.message,
    this.data,
    required this.lu,
    this.luAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:        json['id'] as String,
      type:      json['type'] as String,
      titre:     json['titre'] as String,
      message:   json['message'] as String,
      data:      json['data'] as Map<String, dynamic>?,
      lu:        json['lu'] as bool? ?? false,
      luAt:      json['lu_at'] != null ? DateTime.tryParse(json['lu_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  NotificationModel copyWith({bool? lu, DateTime? luAt}) {
    return NotificationModel(
      id:        id,
      type:      type,
      titre:     titre,
      message:   message,
      data:      data,
      lu:        lu ?? this.lu,
      luAt:      luAt ?? this.luAt,
      createdAt: createdAt,
    );
  }
}
