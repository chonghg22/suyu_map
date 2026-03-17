import 'package:go_router/go_router.dart';
import 'package:suyu_map/features/map/map_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'map',
      builder: (context, state) => const MapScreen(),
    ),
    // TODO: Add routes for detail, review, search, favorite, report, mypage
  ],
);
