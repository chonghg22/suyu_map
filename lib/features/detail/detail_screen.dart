import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';
import '../../data/repositories/favorite_repository.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _favoriteRepo = FavoriteRepository();
  Map<String, dynamic>? _room;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isFavoriteLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final client = Supabase.instance.client.schema(SupabaseConstants.schema);

      final results = await Future.wait([
        client
            .from(SupabaseConstants.nursingRoomTable)
            .select()
            .eq('id', widget.id)
            .maybeSingle(),
        client
            .from(SupabaseConstants.nursingRoomRatingView)
            .select()
            .eq('nursing_room_id', widget.id)
            .maybeSingle(),
        _favoriteRepo.isFavorite(widget.id),
      ]);

      final room = results[0] as Map<String, dynamic>?;
      final rating = results[1] as Map<String, dynamic>?;
      final isFavorite = results[2] as bool;

      if (room == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        setState(() {
          _room = {
            ...room,
            'avg_total': rating?['avg_total'],
            'avg_cleanliness': rating?['avg_cleanliness'],
            'avg_facility': rating?['avg_facility'],
            'avg_accessibility': rating?['avg_accessibility'],
            'review_count': rating?['review_count'],
          };
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('상세 정보 로드 실패: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavoriteLoading = true);
    try {
      if (_isFavorite) {
        await _favoriteRepo.removeFavorite(widget.id);
      } else {
        await _favoriteRepo.addFavorite(widget.id);
      }
      setState(() => _isFavorite = !_isFavorite);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 제거했습니다.'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('즐겨찾기 오류: $e');
    } finally {
      if (mounted) setState(() => _isFavoriteLoading = false);
    }
  }

  String _sourceLabel(String? source) {
    switch (source) {
      case 'PUBLIC_2022':
        return '공공데이터';
      case 'CULTURE_2023':
        return '문화관광';
      case 'NAVER':
        return '네이버';
      case 'USER':
        return '유저제보';
      default:
        return source ?? '';
    }
  }

  Color _sourceColor(String? source) {
    switch (source) {
      case 'PUBLIC_2022':
        return Colors.blue;
      case 'CULTURE_2023':
        return Colors.green;
      case 'NAVER':
        return Colors.teal;
      case 'USER':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, bool value) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: value ? Colors.pink.shade50 : Colors.grey.shade100,
        border: Border.all(
          color: value ? Colors.pink.shade200 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: value ? Colors.pink : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: value ? Colors.pink.shade700 : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('수유실 상세'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _room == null
              ? const Center(child: Text('정보를 불러올 수 없습니다.'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final room = _room!;
    final name = room['name'] as String? ?? '';
    final floorInfo = room['floor_info'] as String? ?? '';
    final address = room['road_address'] as String? ?? '';
    final operatingHours = room['operating_hours'] as String?;
    final source = room['source'] as String?;
    final avgTotal = (room['avg_total'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = (room['review_count'] as num?)?.toInt() ?? 0;
    final strollerRental = room['stroller_rental'] == true;
    final hasKidsZone = room['has_kids_zone'] == true;
    final hasDisabledToilet = room['has_disabled_toilet'] == true;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 시설명 + 출처 뱃지
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (source != null && source.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _sourceColor(source).withOpacity(0.1),
                          border: Border.all(
                              color: _sourceColor(source).withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _sourceLabel(source),
                          style: TextStyle(
                              fontSize: 11,
                              color: _sourceColor(source),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),

                if (floorInfo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(floorInfo,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade600)),
                ],

                if (reviewCount > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(avgTotal.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('($reviewCount개 리뷰)',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ),
                ],

                const Divider(height: 28),

                if (address.isNotEmpty)
                  _buildInfoRow(
                      Icons.location_on_outlined, '도로명 주소', address),

                _buildInfoRow(
                  Icons.access_time,
                  '운영시간',
                  operatingHours?.isNotEmpty == true
                      ? operatingHours!
                      : '운영시간 정보 없음',
                ),

                const SizedBox(height: 16),
                const Text('편의시설',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                Wrap(
                  children: [
                    _buildBadge('유모차 대여', strollerRental),
                    _buildBadge('키즈존', hasKidsZone),
                    _buildBadge('장애인화장실', hasDisabledToilet),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 하단 버튼
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isFavoriteLoading ? null : _toggleFavorite,
                        icon: _isFavoriteLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite ? Colors.pink : null,
                              ),
                        label:
                            Text(_isFavorite ? '즐겨찾기 제거' : '즐겨찾기 추가'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('리뷰 작성 기능은 준비 중입니다.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('리뷰 작성'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('정보 수정 제안 기능은 준비 중입니다.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('정보 수정 제안',
                        style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
