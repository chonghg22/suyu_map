class SupabaseConstants {
  SupabaseConstants._();

  // Schema
  static const String schema = 'suyumap';

  // Table names
  static const String nursingRoomTable = 'nursing_room';
  static const String usersTable = 'users';
  static const String reviewTable = 'review';
  static const String reviewPhotoTable = 'review_photo';
  static const String favoriteTable = 'favorite';
  static const String reportTable = 'report';

  // View names
  static const String nursingRoomRatingView = 'nursing_room_rating';

  // RPC functions
  static const String getNursingRoomsNearbyRpc = 'get_nursing_rooms_nearby';
}
