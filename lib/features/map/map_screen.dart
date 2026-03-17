import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  NaverMapController? _mapController;
  bool _isInitialLoading = true;
  bool _isMarkersLoading = false;
  NLatLng? _currentPosition;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final position = await _fetchCurrentPosition();
    if (!mounted) return;
    setState(() {
      _currentPosition = position != null
          ? NLatLng(position.latitude, position.longitude)
          : const NLatLng(37.5665, 126.9780);
      _isInitialLoading = false;
    });
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
    await _loadNearbyNursingRooms(latlng.latitude, latlng.longitude);
  }

  void _onCameraIdle() async {
    if (_mapController == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final cameraPosition = await _mapController?.getCameraPosition();
      if (cameraPosition == null) return;
      final target = cameraPosition.target;
      await _loadNearbyNursingRooms(target.latitude, target.longitude);
    });
  }

  Future<void> _loadNearbyNursingRooms(double lat, double lng) async {
    if (_mapController == null) return;
    setState(() => _isMarkersLoading = true);
    try {
      final response = await Supabase.instance.client
          .schema(SupabaseConstants.schema)
          .rpc(SupabaseConstants.getNursingRoomsNearbyRpc, params: {
        'user_lat': lat,
        'user_lng': lng,
        'radius_m': 2000,
      });

      if (_mapController == null || !mounted) return;
      await _mapController!.clearOverlays();

      final rooms = response as List<dynamic>;
      for (final room in rooms) {
        final roomLat = (room['lat'] as num?)?.toDouble() ?? 0.0;
        final roomLng = (room['lng'] as num?)?.toDouble() ?? 0.0;
        if (roomLat == 0.0 && roomLng == 0.0) continue;

        final name = room['name'] as String? ?? '';
        final address = room['road_address'] as String? ?? '';
        final floorInfo = room['floor_info'] as String? ?? '';
        final distanceM = (room['distance_m'] as num?)?.toDouble() ?? 0.0;
        final avgTotal = (room['avg_total'] as num?)?.toDouble() ?? 0.0;
        final reviewCount = (room['review_count'] as num?)?.toInt() ?? 0;

        final roomId = room['id'].toString();
        final marker = NMarker(
          id: roomId,
          position: NLatLng(roomLat, roomLng),
        );

        marker.setOnTapListener((_) {
          _showBottomSheet(
            id: roomId,
            name: name,
            address: address,
            floorInfo: floorInfo,
            distanceM: distanceM,
            avgTotal: avgTotal,
            reviewCount: reviewCount,
          );
        });

        await _mapController!.addOverlay(marker);
      }
    } catch (e) {
      debugPrint('수유실 로드 실패: $e');
    } finally {
      if (mounted) setState(() => _isMarkersLoading = false);
    }
  }

  void _showBottomSheet({
    required String id,
    required String name,
    required String address,
    required String floorInfo,
    required double distanceM,
    required double avgTotal,
    required int reviewCount,
  }) {
    final distanceText = distanceM >= 1000
        ? '${(distanceM / 1000).toStringAsFixed(1)}km'
        : '${distanceM.toInt()}m';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
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
            if (address.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      floorInfo.isNotEmpty ? '$address $floorInfo' : address,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            if (distanceM > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.directions_walk, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    distanceText,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (reviewCount > 0) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${avgTotal.toStringAsFixed(1)} ($reviewCount)',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/detail/$id');
                },
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('상세보기'),
              ),
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
          if (!_isInitialLoading)
            NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: _currentPosition!,
                  zoom: 15,
                ),
                locationButtonEnable: false,
              ),
              onMapReady: (controller) async {
                _mapController = controller;
                await _loadNearbyNursingRooms(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                );
              },
              onCameraIdle: _onCameraIdle,
            ),
          if (_isInitialLoading)
            const Center(child: CircularProgressIndicator()),
          if (_isMarkersLoading)
            const Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
