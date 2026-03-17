import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  NaverMapController? _mapController;
  bool _isLoading = true;
  NLatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final position = await _fetchCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _currentPosition = NLatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<Position?> _fetchCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _moveToCurrentLocation() async {
    final position = await _fetchCurrentPosition();
    if (position == null || _mapController == null) return;

    final latlng = NLatLng(position.latitude, position.longitude);
    setState(() => _currentPosition = latlng);

    await _mapController!.updateCamera(
      NCameraUpdate.scrollAndZoomTo(target: latlng, zoom: 15),
    );
    await _loadNearbyNursingRooms(position.latitude, position.longitude);
  }

  Future<void> _loadNearbyNursingRooms(double lat, double lng) async {
    try {
      final response = await Supabase.instance.client
          .schema(SupabaseConstants.schema)
          .rpc(SupabaseConstants.getNursingRoomsNearbyRpc, params: {
        'user_lat': lat,
        'user_lng': lng,
        'radius_m': 2000,
      });

      if (_mapController == null) return;

      await _mapController!.clearOverlays();

      final List<dynamic> rooms = response as List<dynamic>;
      for (final room in rooms) {
        final roomLat = (room['latitude'] as num?)?.toDouble() ?? 0.0;
        final roomLng = (room['longitude'] as num?)?.toDouble() ?? 0.0;
        final name = room['name'] as String? ?? '';
        final address = room['address'] as String? ?? '';

        // null일 수 있는 추가 필드 안전 처리
        // ignore: unused_local_variable
        final avgTotal = (room['avg_total'] as num?)?.toDouble() ?? 0.0;
        // ignore: unused_local_variable
        final reviewCount = (room['review_count'] as num?)?.toInt() ?? 0;
        // ignore: unused_local_variable
        final distanceM = (room['distance_m'] as num?)?.toDouble() ?? 0.0;

        if (roomLat == 0.0 && roomLng == 0.0) continue;

        final marker = NMarker(
          id: room['id'].toString(),
          position: NLatLng(roomLat, roomLng),
        );

        marker.setOnTapListener((_) {
          _showBottomSheet(name, address);
        });

        await _mapController!.addOverlay(marker);
      }
    } catch (e) {
      debugPrint('수유실 로드 실패: $e');
    }
  }

  void _showBottomSheet(String name, String address) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('수유맵')),
      body: Stack(
        children: [
          if (!_isLoading)
            NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: _currentPosition ?? const NLatLng(37.5665, 126.9780),
                  zoom: 15,
                ),
                locationButtonEnable: false,
              ),
              onMapReady: (controller) async {
                _mapController = controller;
                if (_currentPosition != null) {
                  await _loadNearbyNursingRooms(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  );
                }
              },
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
