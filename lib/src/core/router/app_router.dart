import 'package:go_router/go_router.dart';
import 'package:headhunter_app/src/features/health/presentation/health_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Named route paths, kept in one place so navigation calls never hardcode
/// string literals.
abstract final class Routes {
  static const health = '/';
}

/// The app's router.
///
/// When auth lands, add a `redirect` here that watches the auth provider and
/// bounces unauthenticated users to the login route.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) => GoRouter(
  initialLocation: Routes.health,
  routes: [
    GoRoute(
      path: Routes.health,
      name: 'health',
      builder: (context, state) => const HealthScreen(),
    ),
  ],
);
