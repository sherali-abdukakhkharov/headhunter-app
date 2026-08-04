import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/src/core/router/app_router.dart';
import 'package:headhunter_app/src/core/theme/app_theme.dart';

/// Root widget: wires the router and themes together.
class HeadhunterApp extends ConsumerWidget {
  const HeadhunterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Headhunter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
