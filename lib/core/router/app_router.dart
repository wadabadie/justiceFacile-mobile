import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/dossiers/presentation/dossiers_screen.dart';
import '../../features/dossiers/presentation/new_dossier_screen.dart';
import '../../features/profil/presentation/profil_screen.dart';
import '../../features/vbg/presentation/vbg_screen.dart';
import '../../features/legal_info/presentation/textes_loi_screen.dart';
import '../../features/ai_agent/presentation/ai_agent_screen.dart';
import '../../features/juristes/presentation/juristes_screen.dart';
import '../../features/messagerie/presentation/messagerie_screen.dart';
import '../../features/messagerie/presentation/chat_screen.dart';

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
        pageBuilder: (_, state) => _fadePage(state, const DossiersScreen()),
      ),
      GoRoute(
        path: '/new-dossier',
        pageBuilder: (_, state) => _slidePage(state, const NewDossierScreen()),
      ),
      GoRoute(
        path: '/ia',
        pageBuilder: (_, state) => _fadePage(state, const AIAgentScreen()),
      ),
      GoRoute(
        path: '/messagerie',
        pageBuilder: (_, state) => _fadePage(state, const MessagerieScreen()),
      ),
      GoRoute(
        path: '/chat',
        pageBuilder: (_, state) => _slidePage(state, ChatScreen(
          contactName: state.extra as String?,
        )),
      ),
      GoRoute(
        path: '/profil',
        pageBuilder: (_, state) => _fadePage(state, const ProfilScreen()),
      ),
      GoRoute(
        path: '/vbg',
        pageBuilder: (_, state) => _fadePage(state, const VBGScreen()),
      ),
      GoRoute(
        path: '/juristes',
        pageBuilder: (_, state) => _fadePage(state, const JuristesScreen()),
      ),
      GoRoute(
        path: '/lois',
        pageBuilder: (_, state) => _fadePage(state, const TextesLoiScreen()),
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
