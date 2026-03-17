import 'package:go_router/go_router.dart';
import 'package:suyu_map/features/detail/detail_screen.dart';
import 'package:suyu_map/features/map/map_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/detail/:id',
      name: 'detail',
      builder: (context, state) => DetailScreen(
        id: state.pathParameters['id']!,
      ),
    ),
  ],
);
