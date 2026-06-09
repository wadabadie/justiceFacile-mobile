import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:showcaseview/showcaseview.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class JusticeFacileApp extends StatelessWidget {
  const JusticeFacileApp({super.key});

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
      locale: const Locale('fr'),
      debugShowCheckedModeBanner: false,
      // ShowCaseWidget must live inside MaterialApp so it has Material localizations
      builder: (context, child) => ShowCaseWidget(
        builder: (ctx) => child ?? const SizedBox.shrink(),
      ),
    );
  }
}
