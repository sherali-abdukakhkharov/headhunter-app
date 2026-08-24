import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/config/app_config.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/l10n/locale_controller.dart';
import 'package:jobbridge_app/src/core/router/app_router.dart';
import 'package:jobbridge_app/src/features/notifications/presentation/push_host.dart';

/// Root widget: wires the router and theme together.
class JobBridgeApp extends ConsumerWidget {
  const JobBridgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(activeLocaleProvider);

    return MaterialApp.router(
      // From the flavor, so the Android task switcher names the build the same
      // way the launcher does. Deliberately not localized - §2.4 forbids
      // translating proper names, and someone reporting a bug should be able to
      // say which build they are on whatever language they read the app in.
      title: AppConfig.flavor.displayName,
      debugShowCheckedModeBanner: false,
      theme: HhTheme.light,
      locale: locale.locale,
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // AppLocale.supportedLocales, *not* AppL10n.supportedLocales: the
      // generated list drops the Uzbek script codes, which would let locale
      // resolution collapse uz-Cyrl onto plain uz - silently serving Latin to
      // a Cyrillic user. See AppLocale for the full explanation.
      supportedLocales: AppLocale.supportedLocales,
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
        // Push (§9.2) sits here rather than around MaterialApp because it needs
        // the active interface variant to name the Android notification
        // channel, and `Localizations` is only above this point. It renders its
        // child unchanged and never rebuilds on a session change.
        return PushHost(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: scaler),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
