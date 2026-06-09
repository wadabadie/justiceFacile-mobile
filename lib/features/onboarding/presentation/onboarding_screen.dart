import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../infrastructure/onboarding_repository_impl.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  void _next(AppStrings s) async {
    if (_page < 2) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await OnboardingRepositoryImpl().markOnboardingDone();
      if (mounted) context.go('/register');
    }
  }

  void _skip() async {
    await OnboardingRepositoryImpl().markOnboardingDone();
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final pages = [
      _OnbPage(
        emoji: '⚖️',
        color: AppColors.or,
        title: s.ob1Title,
        desc: s.ob1Desc,
      ),
      _OnbPage(
        emoji: '👨‍⚖️',
        color: AppColors.emeraude,
        title: s.ob2Title,
        desc: s.ob2Desc,
      ),
      _OnbPage(
        emoji: '🛡️',
        color: AppColors.rouge,
        title: s.ob3Title,
        desc: s.ob3Desc,
      ),
    ];
    final isLast = _page == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(s.btnSkip,
                    style: AppTextStyles.label.copyWith(color: AppColors.grisMid)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: pages.length,
                itemBuilder: (_, i) => pages[i],
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) => _Dot(active: i == _page)),
            ),

            const SizedBox(height: 32),

            // Logo + bouton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  SizedBox(
                    width: 60, height: 60,
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 20),
                  _NextButton(
                    label: isLast ? s.btnStart : s.btnNext,
                    onTap: () => _next(s),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnbPage extends StatelessWidget {
  const _OnbPage({
    required this.emoji,
    required this.color,
    required this.title,
    required this.desc,
  });
  final String emoji;
  final Color color;
  final String title, desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: color.withAlpha(60)),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 52))),
          ),
          const SizedBox(height: 36),
          Text(title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h1.copyWith(fontSize: 24)),
          const SizedBox(height: 16),
          Text(desc,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.grisMid, height: 1.6)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 22 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.or : AppColors.grisLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.label, required this.onTap});
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
