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
      // No darkTheme. The design confirms a single light scheme as final for
      // v1, so supplying a dark one would invent decisions the client has not
      // approved. (Every colour is already a semantic token, which is what will
      // make a v2 dark palette cheap.)
      routerConfig: router,
      builder: (context, child) {
        // The design caps effective text scale at 2.0x: beyond that a sticky
        // action bar eats the scroll area on a 320pt device, and clamping is
        // the lesser failure. Controls still grow with the label up to the cap.
        final scaler = MediaQuery.textScalerOf(
          context,
        ).clamp(maxScaleFactor: 2);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
