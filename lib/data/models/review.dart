class Review {
  final String id;
  final String nursingRoomId;
  final String userId;
  final int rating;
  final String? content;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.nursingRoomId,
    required this.userId,
    required this.rating,
    this.content,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        nursingRoomId: json['nursing_room_id'] as String,
        userId: json['user_id'] as String,
        rating: json['rating'] as int,
        content: json['content'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nursing_room_id': nursingRoomId,
        'user_id': userId,
        'rating': rating,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };
}
