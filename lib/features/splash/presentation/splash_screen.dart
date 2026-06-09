import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../features/auth/infrastructure/auth_repository_impl.dart';
import '../../../features/onboarding/infrastructure/onboarding_repository_impl.dart';

// Entry point of the app.
// Shows animated branding, then either auto-redirects (token exists)
// or waits for user to choose login / register.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _contentCtrl;
  late final AnimationController _btnCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _btnFade;

  bool _autoRedirecting = false;

  @override
  void initState() {
    super.initState();

    _logoCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _btnCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _logoScale = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.4)));
    _contentFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));
    _btnFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut));

    _runAnimations();
    _checkAutoRedirect();
  }

  Future<void> _runAnimations() async {
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _contentCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    await _btnCtrl.forward();
  }

  // If a valid token exists, skip the welcome screen and go straight to home
  Future<void> _checkAutoRedirect() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final token = await AuthRepositoryImpl().getAccessToken();
    // Only treat real JWT tokens as valid — reject leftover stub values
    final isRealToken = token != null && token.startsWith('eyJ');
    if (isRealToken && mounted) {
      setState(() => _autoRedirecting = true);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) context.go('/home');
    }
  }

  void _goLogin() => context.go('/login');

  Future<void> _goRegister() async {
    // First-time users see onboarding before registration form
    final isFirst = await OnboardingRepositoryImpl().isFirstLaunch();
    if (!mounted) return;
    context.go(isFirst ? '/onboarding' : '/register');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _contentCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.bleuNuit,
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradientSplash),
          child: Stack(
          children: [
            // Decorative gold orb — top right
            Positioned(
              top: -60, right: -60,
              child: Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.or.withAlpha(51), Colors.transparent,
                  ]),
                ),
              ),
            ),
            // Decorative emerald orb — bottom left
            Positioned(
              bottom: -40, left: -40,
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.emeraude.withAlpha(38), Colors.transparent,
                  ]),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Animated logo
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: _LogoWidget(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App name, tagline and feature pills
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(children: [
                                TextSpan(text: 'Justice ', style: AppTextStyles.splash),
                                TextSpan(text: 'Facile', style: AppTextStyles.splashAccent),
                              ]),
                            ),
                            const SizedBox(height: 10),
                            Text(s.splashTagline, style: AppTextStyles.tagline),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [s.splashPill1, s.splashPill2, s.splashPill3]
                                  .map((p) => _Pill(label: p))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // CTA buttons — hidden while auto-redirecting
                    FadeTransition(
                      opacity: _btnFade,
                      child: _autoRedirecting
                          ? const CircularProgressIndicator(color: AppColors.or)
                          : Column(children: [
                              _GoldButton(label: s.btnLogin,    onTap: _goLogin),
                              const SizedBox(height: 12),
                              _OutlineButton(label: s.btnRegister, onTap: _goRegister),
                            ]),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110, height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.or, AppColors.orDark],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x66C9920A), blurRadius: 40, offset: Offset(0, 12)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        border: Border.all(color: Colors.white.withAlpha(30)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
            fontFamily: 'GoogleSans', fontSize: 12, fontWeight: FontWeight.w500,
            color: Color(0xB3FFFFFF), letterSpacing: 0.3,
          )),
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [AppColors.ombreOr],
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: AppTextStyles.btn.copyWith(color: AppColors.blanc)),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.white.withAlpha(179), width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: AppTextStyles.btn.copyWith(color: AppColors.blanc)),
      ),
    );
  }
}
