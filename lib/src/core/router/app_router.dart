import 'package:go_router/go_router.dart';
import 'package:headhunter_app/src/features/design_gallery/presentation/design_gallery_screen.dart';
import 'package:headhunter_app/src/features/health/presentation/health_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Named route paths, kept in one place so navigation calls never hardcode
/// string literals.
abstract final class Routes {
  static const health = '/';

  /// Design-system catalogue. A development surface, not a product route — it
  /// carries unlocalized sample copy and must not be linked from the app shell.
  static const designGallery = '/_design';
}

/// The app's router.
///
/// When auth lands this gains the role-aware shell described in
/// ARCHITECTURE.md: a `StatefulShellRoute` per role plus a `redirect` chain for
/// unauthenticated / no-role-chosen / blocked / ungranted-role.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) => GoRouter(
  initialLocation: Routes.health,
  routes: [
    GoRoute(
      path: Routes.health,
      name: 'health',
      builder: (context, state) => const HealthScreen(),
    ),
    GoRoute(
      path: Routes.designGallery,
      name: 'designGallery',
      builder: (context, state) => const DesignGalleryScreen(),
    ),
  ],
);
