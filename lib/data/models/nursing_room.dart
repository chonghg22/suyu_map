class NursingRoom {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? description;
  final bool isPublic;
  final DateTime createdAt;

  const NursingRoom({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    required this.isPublic,
    required this.createdAt,
  });

  factory NursingRoom.fromJson(Map<String, dynamic> json) => NursingRoom(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        description: json['description'] as String?,
        isPublic: json['is_public'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'is_public': isPublic,
        'created_at': createdAt.toIso8601String(),
      };
}
