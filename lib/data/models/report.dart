class Report {
  final String id;
  final String userId;
  final String nursingRoomId;
  final String reason;
  final String? detail;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.userId,
    required this.nursingRoomId,
    required this.reason,
    this.detail,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        nursingRoomId: json['nursing_room_id'] as String,
        reason: json['reason'] as String,
        detail: json['detail'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'nursing_room_id': nursingRoomId,
        'reason': reason,
        'detail': detail,
        'created_at': createdAt.toIso8601String(),
      };
}
