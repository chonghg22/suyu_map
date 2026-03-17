import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';
import '../../core/services/device_id_service.dart';

class FavoriteRepository {
  final _client = Supabase.instance.client.schema(SupabaseConstants.schema);

  Future<bool> isFavorite(String nursingRoomId) async {
    final deviceId = await DeviceIdService.getDeviceId();
    final result = await _client
        .from(SupabaseConstants.favoriteTable)
        .select('id')
        .eq('device_id', deviceId)
        .eq('nursing_room_id', nursingRoomId)
        .maybeSingle();
    return result != null;
  }

  Future<void> addFavorite(String nursingRoomId) async {
    final deviceId = await DeviceIdService.getDeviceId();
    await _client.from(SupabaseConstants.favoriteTable).insert({
      'device_id': deviceId,
      'nursing_room_id': nursingRoomId,
    });
  }

  Future<void> removeFavorite(String nursingRoomId) async {
    final deviceId = await DeviceIdService.getDeviceId();
    await _client
        .from(SupabaseConstants.favoriteTable)
        .delete()
        .eq('device_id', deviceId)
        .eq('nursing_room_id', nursingRoomId);
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final deviceId = await DeviceIdService.getDeviceId();
    final result = await _client
        .from(SupabaseConstants.favoriteTable)
        .select('nursing_room_id, nursing_room(id, name, road_address, floor_info)')
        .eq('device_id', deviceId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(result);
  }
}
