import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/infrastructure/auth_repository_impl.dart';

/// Dashboard specific to NGOs. Similar to specialist dashboard but the
/// second stat card is Activites organisees (not Mes dossiers), and the
/// primary shortcut is to the activities screen rather than the planning.
class HomeOngScreen extends StatefulWidget {
  const HomeOngScreen({super.key});

  @override
  State<HomeOngScreen> createState() => _HomeOngScreenState();
}

class _HomeOngScreenState extends State<HomeOngScreen> {
  UserEntity? _user;
  String _certifStatut = 'NON_SOUMIS';
  int _casDispoCount = 0;
  int _mesActivitesCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final user = await AuthRepositoryImpl().restoreSession();
    if (mounted) setState(() => _user = user);

    try {
      final profile = await AuthRepositoryImpl().fetchMyProfileRaw();
      _certifStatut = (profile['certification_statut'] as String? ?? 'NON_SOUMIS').toUpperCase();
    } catch (_) {}

    if (_certifStatut == 'VALIDE') {
      try {
        final res = await ApiService.instance.get(ApiConstants.demandesDisponibles);
        _casDispoCount = (res.data as List).length;
      } on DioException catch (_) {}
      try {
        final res = await ApiService.instance.get(ApiConstants.mesActivites);
        _mesActivitesCount = (res.data as List).length;
      } on DioException catch (_) {}
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _Header(user: _user, s: s),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.bleuNuit,
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_certifStatut != 'VALIDE') _CertifBanner(statut: _certifStatut, s: s),
                    if (_certifStatut != 'VALIDE') const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _StatCard(
                          icon: Icons.inbox_rounded,
                          value: _loading ? '…' : '$_casDispoCount',
                          label: s.homeSpecCasDispoLabel,
                          color: AppColors.orDark,
                          bg: AppColors.orLight,
                          onTap: _certifStatut == 'VALIDE'
                              ? () => context.go('/cas-disponibles') : null,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(
                          icon: Icons.event_available_rounded,
                          value: _loading ? '…' : '$_mesActivitesCount',
                          label: s.homeOngActivitesLabel,
                          color: AppColors.emeraude,
                          bg: AppColors.emeraudeLight,
                          onTap: () => context.go('/activites'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(s.homeSpecActionsTitle,
                        style: AppTextStyles.h3.copyWith(color: AppColors.bleuNuit)),
                    const SizedBox(height: 12),
                    _ActionRow(
                      icon: Icons.event_available_rounded,
                      label: s.homeOngActivitesActionLabel,
                      desc: s.homeOngActivitesActionDesc,
                      color: AppColors.emeraude,
                      onTap: () => context.go('/activites'),
                    ),
                    _ActionRow(
                      icon: Icons.folder_copy_rounded,
                      label: s.homeSpecMesDossiersLabel,
                      desc: s.homeOngDossiersActionDesc,
                      color: AppColors.bleuMid,
                      onTap: () => context.go('/dossiers'),
                    ),
                    _ActionRow(
                      icon: Icons.verified_outlined,
                      label: s.certMenuLabel,
                      desc: _certifDesc(s),
                      color: AppColors.orDark,
                      onTap: () => context.go('/certification'),
                    ),
                    _ActionRow(
                      icon: Icons.person_rounded,
                      label: s.homeSpecProfileLabel,
                      desc: s.homeSpecProfileDesc,
                      color: AppColors.grisMid,
                      onTap: () => context.go('/profil'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.home),
    );
  }

  String _certifDesc(AppStrings s) => switch (_certifStatut) {
    'VALIDE'     => s.certStatutValideTitle,
    'EN_ATTENTE' => s.certStatutEnAttenteTitle,
    'REJETE'     => s.certStatutRejeteTitle,
    _            => s.certStatutNonSoumisTitle,
  };
}

// ── Widgets partagés (copies locales pour éviter d'exposer les widgets privés) ─

class _Header extends StatelessWidget {
  const _Header({required this.user, required this.s});
  final UserEntity? user;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final u = user;
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.orDark.withAlpha(60),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(u?.initials ?? '?',
                      style: const TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 18,
                        fontWeight: FontWeight.w700, color: AppColors.orPale,
                      )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u != null ? '${s.homeGreeting}, ${u.firstName}' : s.homeGreeting,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 15,
                          color: Color(0xB3FFFFFF),
                        )),
                    Text(s.roleOng,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 18,
                          fontWeight: FontWeight.w700, color: AppColors.orPale,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CertifBanner extends StatelessWidget {
  const _CertifBanner({required this.statut, required this.s});
  final String statut;
  final AppStrings s;

  ({Color bg, Color fg, IconData icon, String title, String desc, String cta}) _cfg() {
    return switch (statut) {
      'EN_ATTENTE' => (
        bg: const Color(0xFFFFF8E1), fg: AppColors.orDark,
        icon: Icons.hourglass_top_rounded,
        title: s.certStatutEnAttenteTitle, desc: s.certStatutEnAttenteDesc,
        cta: s.btnConsult,
      ),
      'REJETE' => (
        bg: AppColors.rougeLight, fg: AppColors.rouge,
        icon: Icons.cancel_outlined,
        title: s.certStatutRejeteTitle, desc: s.certStatutRejeteDesc,
        cta: s.homeSpecCertifCta,
      ),
      _ => (
        bg: AppColors.orLight, fg: AppColors.orDark,
        icon: Icons.workspace_premium_outlined,
        title: s.certStatutNonSoumisTitle, desc: s.certStatutNonSoumisDesc,
        cta: s.homeSpecCertifCta,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = _cfg();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.fg.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(c.icon, color: c.fg, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(c.title,
                    style: TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 16,
                      fontWeight: FontWeight.w700, color: c.fg,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(c.desc,
              style: const TextStyle(
                fontFamily: 'GoogleSans', fontSize: 13,
                color: AppColors.gris, height: 1.4,
              )),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.go('/certification'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: c.fg, borderRadius: BorderRadius.circular(10),
                ),
                child: Text(c.cta,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 13,
                      fontWeight: FontWeight.w700, color: AppColors.blanc,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon, required this.value, required this.label,
    required this.color, required this.bg, this.onTap,
  });
  final IconData icon;
  final String value, label;
  final Color color, bg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 28,
                  fontWeight: FontWeight.w800, color: color,
                )),
            Text(label,
                style: TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 12,
                  color: color.withAlpha(180),
                )),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon, required this.label, required this.desc,
    required this.color, required this.onTap,
  });
  final IconData icon;
  final String label, desc;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.blanc, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x14000000)),
            boxShadow: const [
              BoxShadow(color: Color(0x07000000), blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 15,
                          fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
                        )),
                    Text(desc,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 12,
                          color: AppColors.grisMid,
                        )),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.grisLight),
            ],
          ),
        ),
      ),
    );
  }
}
