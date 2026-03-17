import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'SUPABASE_URL',
    anonKey: 'SUPABASE_ANON_KEY',
  );

  // Initialize Naver Map SDK
  await FlutterNaverMap().init(
    clientId: 'NAVER_MAP_CLIENT_ID',
    onAuthFailed: (ex) => debugPrint('네이버 지도 인증 실패: ${ex.message}'),
  );

  runApp(const ProviderScope(child: SuyuMapApp()));
}

class SuyuMapApp extends StatelessWidget {
  const SuyuMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '수유맵',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
