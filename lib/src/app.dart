import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/router/app_router.dart';

/// Root widget: wires the router and theme together.
class HeadhunterApp extends ConsumerWidget {
  const HeadhunterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Headhunter',
      debugShowCheckedModeBanner: false,
      theme: HhTheme.light,
      // No darkTheme: the design specifies a single light scheme, so supplying
      // a dark one would invent visual decisions the client has not approved.
      routerConfig: router,
    );
  }
}
