import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/infrastructure/auth_repository_impl.dart';
import '../../onboarding/infrastructure/onboarding_repository_impl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tipSearch   = GlobalKey();
  final _tipActions  = GlobalKey();
  final _tipVbg      = GlobalKey();
  final _tipMessages = GlobalKey();

  UserEntity? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _maybeShowTips();
  }

  Future<void> _loadUser() async {
    final user = await AuthRepositoryImpl().restoreSession();
    if (mounted) setState(() => _user = user);
  }

  Future<void> _maybeShowTips() async {
    final repo = OnboardingRepositoryImpl();
    final show = await repo.shouldShowDashboardTips();
    if (show && mounted) {
      await repo.markTipsSeen();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase(
          [_tipSearch, _tipActions, _tipVbg, _tipMessages],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _HomeHeader(s: s, tipSearch: _tipSearch, user: _user),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 36, 18, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.homeQuickActions, style: AppTextStyles.h2),
                  const SizedBox(height: 14),
                  Showcase(
                    key: _tipActions,
                    description: s.tipActions,
                    child: _QuickActions(s: s),
                  ),
                  const SizedBox(height: 22),
                  Showcase(
                    key: _tipVbg,
                    description: s.tipVbg,
                    child: _VbgCard(s: s),
                  ),
                  const SizedBox(height: 22),
                  Text(s.homeRecentDossiers, style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  ..._mockDossiers(),
                  const SizedBox(height: 22),
                  _StatsRow(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: NavTab.home,
        messagesTipKey: _tipMessages,
      ),
    );
  }

  List<Widget> _mockDossiers() {
    return [
      _DossierCard(id: 'JF-2026-001', title: 'Licenciement abusif', category: 'Droit du travail', date: '05 juin 2026', status: 'En cours'),
      _DossierCard(id: 'JF-2026-002', title: 'Conflit foncier', category: 'Droit civil', date: '02 juin 2026', status: 'En attente'),
    ];
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.s, required this.tipSearch, required this.user});
  final AppStrings s;
  final GlobalKey tipSearch;
  final UserEntity? user;

  String _roleLabel(String role, AppStrings s) => switch (role) {
    'juriste'      => s.roleJuriste,
    'psychologue'  => s.rolePsychologue,
    'ong'          => s.roleOng,
    _              => s.roleCitoyen,
  };

  @override
  Widget build(BuildContext context) {
    final displayName = user != null
        ? (user!.firstName.isNotEmpty ? user!.firstName : user!.fullName)
        : '...';
    final roleLabel = user != null ? _roleLabel(user!.role, s) : '';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bleuNuit, AppColors.bleuMid],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 36),
          child: Column(
            children: [
              Row(
                children: [
                  // Logo
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: const TextSpan(children: [
                      TextSpan(
                        text: 'Justice ',
                        style: TextStyle(fontFamily: 'GoogleSans', fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.blanc),
                      ),
                      TextSpan(
                        text: 'Facile',
                        style: TextStyle(fontFamily: 'GoogleSans', fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.orPale),
                      ),
                    ]),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_outlined, color: AppColors.blanc, size: 20),
                      ),
                      Positioned(
                        top: 4, right: 4,
                        child: Container(
                          width: 9, height: 9,
                          decoration: BoxDecoration(
                            color: AppColors.rouge,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.bleuNuit, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(s.homeGreeting,
                          style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 17,
                            color: Color(0x99FFFFFF),
                            fontWeight: FontWeight.w500,
                          )),
                      if (roleLabel.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.or.withAlpha(40),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.or.withAlpha(80)),
                          ),
                          child: Text(roleLabel,
                              style: const TextStyle(
                                fontFamily: 'GoogleSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.orPale,
                              )),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(displayName,
                      style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blanc,
                      )),
                  const SizedBox(height: 14),
                  Showcase(
                    key: tipSearch,
                    description: s.tipSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        border: Border.all(color: Colors.white.withAlpha(46)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0x80FFFFFF), size: 20),
                          const SizedBox(width: 10),
                          Text(s.homeSearch,
                              style: const TextStyle(
                                fontFamily: 'GoogleSans',
                                fontSize: 18,
                                color: Color(0x80FFFFFF),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.folder_outlined,     AppColors.or,       AppColors.orLight,       s.homeQaDossier,  '/dossiers'),
      (Icons.smart_toy_outlined,  AppColors.bleuMid,  const Color(0xFFE8F0FE), s.homeQaIa,       '/ia'),
      (Icons.gavel_outlined,      AppColors.emeraude, AppColors.emeraudeLight,  s.homeQaJuriste,  '/juristes'),
      (Icons.menu_book_outlined,  AppColors.rouge,    AppColors.rougeLight,    s.homeQaLois,     '/lois'),
    ];
    return Row(
      children: items.map((item) => Expanded(
        child: GestureDetector(
          onTap: () => context.go(item.$5),
          child: Column(
            children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  color: item.$3,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Icon(item.$1, color: item.$2, size: 26),
              ),
              const SizedBox(height: 6),
              Text(item.$4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gris)),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _VbgCard extends StatelessWidget {
  const _VbgCard({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bleuNuit, Color(0xFF1E3A5F)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppColors.ombre],
      ),
      child: Stack(
        children: [
          // Orb décoratif
          Positioned(
            top: -20, right: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.or.withAlpha(64), Colors.transparent]),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.rouge.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppColors.rouge, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(s.homeVbgLabel,
                      style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.orPale, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 12),
              Text(s.homeVbgTitle,
                  style: AppTextStyles.h2.copyWith(color: AppColors.blanc, fontSize: 22)),
              const SizedBox(height: 6),
              Text(s.homeVbgDesc, style: AppTextStyles.bodyWhite.copyWith(fontSize: 17)),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => context.go('/vbg'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [AppColors.ombreOr],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.homeVbgBtn,
                          style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.blanc)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, color: AppColors.blanc, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DossierCard extends StatelessWidget {
  const _DossierCard({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.status,
  });
  final String id, title, category, date, status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.or, width: 3)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id, style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.orDark, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(category, style: AppTextStyles.bodySm),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date, style: AppTextStyles.bodySm.copyWith(fontSize: 15)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'En cours' ? AppColors.orLight : AppColors.emeraudeLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 15, fontWeight: FontWeight.w700,
                      color: status == 'En cours' ? AppColors.orDark : AppColors.emeraude,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _StatCard(number: '3', label: 'Dossiers actifs', trend: '+1 ce mois')),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(number: '2', label: 'Messages non lus', trend: 'Voir maintenant')),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.number, required this.label, required this.trend});
  final String number, label, trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 33, fontWeight: FontWeight.w700, color: AppColors.bleuNuit, height: 1)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySm.copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text(trend, style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.emeraude)),
        ],
      ),
    );
  }
}

