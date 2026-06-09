import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profil/presentation/profil_screen.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, state) => _fadePage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) => _fadePage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, state) => _slidePage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (_, state) {
          final email = state.extra as String? ?? '';
          return _slidePage(state, VerifyEmailScreen(email: email));
        },
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (_, state) => _fadePage(state, const HomeScreen()),
      ),
      GoRoute(
        path: '/dossiers',
        pageBuilder: (_, state) => _fadePage(state, const ComingSoonScreen(
          title: 'Dossiers', icon: Icons.folder_copy_rounded, navTab: NavTab.dossiers,
        )),
      ),
      GoRoute(
        path: '/ia',
        pageBuilder: (_, state) => _fadePage(state, const ComingSoonScreen(
          title: 'Assistant IA', icon: Icons.auto_awesome_rounded, navTab: NavTab.ia,
        )),
      ),
      GoRoute(
        path: '/messagerie',
        pageBuilder: (_, state) => _fadePage(state, const ComingSoonScreen(
          title: 'Messages', icon: Icons.forum_rounded, navTab: NavTab.messages,
        )),
      ),
      GoRoute(
        path: '/profil',
        pageBuilder: (_, state) => _fadePage(state, const ProfilScreen()),
      ),
      GoRoute(
        path: '/vbg',
        pageBuilder: (_, state) => _fadePage(state, const ComingSoonScreen(
          title: 'Module VBG', icon: Icons.shield_outlined, navTab: NavTab.home,
        )),
      ),
      GoRoute(
        path: '/juristes',
        pageBuilder: (_, state) => _fadePage(state, const ComingSoonScreen(
          title: 'Juristes', icon: Icons.gavel_outlined, navTab: NavTab.home,
        )),
      ),
      GoRoute(
        path: '/lois',
        pageBuilder: (_, state) => _fadePage(state, const ComingSoonScreen(
          title: 'Textes de loi', icon: Icons.menu_book_outlined, navTab: NavTab.home,
        )),
      ),
    ],
  );

  static CustomTransitionPage _fadePage(GoRouterState state, Widget child) =>
      CustomTransitionPage(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, c) =>
            FadeTransition(opacity: animation, child: c),
        transitionDuration: const Duration(milliseconds: 350),
      );

  static CustomTransitionPage _slidePage(GoRouterState state, Widget child) =>
      CustomTransitionPage(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, c) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: c,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );
}
