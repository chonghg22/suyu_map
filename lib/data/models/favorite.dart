class Favorite {
  final String id;
  final String userId;
  final String nursingRoomId;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.nursingRoomId,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        nursingRoomId: json['nursing_room_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'nursing_room_id': nursingRoomId,
        'created_at': createdAt.toIso8601String(),
      };
}
