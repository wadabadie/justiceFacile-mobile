abstract interface class IOnboardingRepository {
  Future<bool> isFirstLaunch();
  Future<void> markOnboardingDone();
  Future<bool> shouldShowDashboardTips();
  Future<void> markTipsSeen();
}
