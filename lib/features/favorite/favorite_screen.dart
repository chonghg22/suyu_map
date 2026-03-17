import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/favorite_repository.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final _repo = FavoriteRepository();
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final result = await _repo.getFavorites();
      if (mounted) setState(() => _favorites = result);
    } catch (e) {
      debugPrint('즐겨찾기 로드 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _remove(String nursingRoomId) async {
    await _repo.removeFavorite(nursingRoomId);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('즐겨찾기에서 제거했습니다.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('즐겨찾기')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('즐겨찾기한 수유실이 없습니다.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _favorites.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = _favorites[i];
                      final nursingRoomId =
                          item['nursing_room_id'] as String? ?? '';
                      final room = item['nursing_room'] as Map<String, dynamic>?;
                      final name = room?['name'] as String? ?? '이름 없음';
                      final address =
                          room?['road_address'] as String? ?? '';
                      final floorInfo =
                          room?['floor_info'] as String? ?? '';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFCE4EC),
                          child: Icon(Icons.baby_changing_station,
                              color: Colors.pink, size: 20),
                        ),
                        title: Text(name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        subtitle: address.isNotEmpty
                            ? Text(
                                floorInfo.isNotEmpty
                                    ? '$address $floorInfo'
                                    : address,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite,
                              color: Colors.pink, size: 22),
                          onPressed: () => _remove(nursingRoomId),
                          tooltip: '즐겨찾기 제거',
                        ),
                        onTap: () => context.push('/detail/$nursingRoomId'),
                      );
                    },
                  ),
                ),
    );
  }
}
