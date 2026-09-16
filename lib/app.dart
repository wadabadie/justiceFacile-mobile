import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:showcaseview/showcaseview.dart';
import 'core/router/app_router.dart';
import 'core/services/locale_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

class JusticeFacileApp extends StatefulWidget {
  const JusticeFacileApp({super.key});

  @override
  State<JusticeFacileApp> createState() => _JusticeFacileAppState();
}

class _JusticeFacileAppState extends State<JusticeFacileApp> {
  @override
  void initState() {
    super.initState();
    LocaleService.instance.addListener(_onLocaleChanged);
    NotificationService.instance.setNavigate((route, {extra}) {
      if (extra != null) {
        AppRouter.router.push(route, extra: extra);
      } else {
        AppRouter.router.go(route);
      }
    });
  }

  void _onLocaleChanged() => setState(() {});

  @override
  void dispose() {
    LocaleService.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Justice Facile',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr'), Locale('en')],
      locale: LocaleService.instance.locale,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ShowCaseWidget(
        builder: (ctx) => child ?? const SizedBox.shrink(),
      ),
    );
  }
}
