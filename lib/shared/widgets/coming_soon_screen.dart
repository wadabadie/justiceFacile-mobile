import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../widgets/app_bottom_nav.dart';

/// Placeholder shown for features not yet implemented.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.navTab,
  });

  final String title;
  final IconData icon;
  final NavTab navTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.bleuNuit,
        foregroundColor: AppColors.blanc,
        title: Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.blanc)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.orLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 48, color: AppColors.or),
            ),
            const SizedBox(height: 28),
            Text('En cours de développement', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            Text(
              'Cette fonctionnalité sera disponible\ntrès prochainement.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: () => context.go('/home'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.bleuNuit, AppColors.bleuMid]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Retour à l\'accueil',
                  style: AppTextStyles.btn.copyWith(color: AppColors.blanc, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(current: navTab),
    );
  }
}
