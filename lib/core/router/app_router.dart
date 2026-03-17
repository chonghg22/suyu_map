import 'package:go_router/go_router.dart';
import 'package:mammazone/features/detail/detail_screen.dart';
import 'package:mammazone/features/favorite/favorite_screen.dart';
import 'package:mammazone/features/map/map_screen.dart';
import 'package:mammazone/features/mypage/mypage_screen.dart';
import 'package:mammazone/shared/widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // 탭바가 있는 ShellRoute
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/favorites',
          name: 'favorites',
          builder: (context, state) => const FavoriteScreen(),
        ),
        GoRoute(
          path: '/mypage',
          name: 'mypage',
          builder: (context, state) => const MypageScreen(),
        ),
      ],
    ),
    // 탭바 없는 독립 화면
    GoRoute(
      path: '/detail/:id',
      name: 'detail',
      builder: (context, state) => DetailScreen(
        id: state.pathParameters['id']!,
      ),
    ),
  ],
);
