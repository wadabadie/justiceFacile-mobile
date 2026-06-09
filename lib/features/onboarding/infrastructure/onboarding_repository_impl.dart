import 'package:shared_preferences/shared_preferences.dart';
import '../domain/repositories/i_onboarding_repository.dart';

// SharedPreferences-backed implementation.
// Keys are private constants — never change them after shipping or existing
// users will lose their onboarding/tips state on next update.
final class OnboardingRepositoryImpl implements IOnboardingRepository {
  static const _kOnboarding = 'onboarding_done';
  static const _kTips       = 'dashboard_tips_seen';

  @override
  Future<bool> isFirstLaunch() async {
    final p = await SharedPreferences.getInstance();
    return !(p.getBool(_kOnboarding) ?? false);
  }

  @override
  Future<void> markOnboardingDone() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOnboarding, true);
  }

  @override
  Future<bool> shouldShowDashboardTips() async {
    final p = await SharedPreferences.getInstance();
    return !(p.getBool(_kTips) ?? false);
  }

  @override
  Future<void> markTipsSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kTips, true);
  }
}
