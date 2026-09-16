import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

// ─── Modèle stats ─────────────────────────────────────────────────────────────

class _Stats {
  _Stats({
    required this.totalUsers,
    required this.totalDossiers,
    required this.dossiersEnCours,
    required this.totalVbg,
    required this.specialistesEnAttente,
    required this.temoignagesEnAttente,
    required this.totalSpecialistes,
    required this.dossiersResolus,
  });

  final int totalUsers;
  final int totalDossiers;
  final int dossiersEnCours;
  final int totalVbg;
  final int specialistesEnAttente;
  final int temoignagesEnAttente;
  final int totalSpecialistes;
  final int dossiersResolus;

  factory _Stats.fromJson(Map<String, dynamic> j) => _Stats(
        totalUsers:              _i(j, ['total_users', 'utilisateurs']),
        totalDossiers:           _i(j, ['total_dossiers', 'dossiers']),
        dossiersEnCours:         _i(j, ['dossiers_en_cours', 'en_cours']),
        totalVbg:                _i(j, ['total_vbg', 'signalements_vbg']),
        specialistesEnAttente:   _i(j, ['specialistes_en_attente']),
        temoignagesEnAttente:    _i(j, ['temoignages_en_attente']),
        totalSpecialistes:       _i(j, ['total_specialistes', 'specialistes']),
        dossiersResolus:         _i(j, ['dossiers_resolus', 'resolus']),
      );

  static int _i(Map<String, dynamic> j, List<String> keys) {
    for (final k in keys) {
      if (j[k] is int) return j[k] as int;
    }
    return 0;
  }
}

// ─── Écran ────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  _Stats? _stats;
  bool _loading = true;
  String? _error;
  bool _escalading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.instance.get(ApiConstants.adminDashboardStats);
      if (!mounted) return;
      setState(() {
        _stats = _Stats.fromJson(res.data as Map<String, dynamic>);
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ApiService.extractError(e.response?.data);
        _loading = false;
      });
    }
  }

  Future<void> _escalade() async {
    if (_escalading) return;
    setState(() => _escalading = true);
    try {
      await ApiService.instance.post(ApiConstants.adminEscalade);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).adminEscalateSuccess,
              style: const TextStyle(fontFamily: 'GoogleSans')),
          backgroundColor: AppColors.emeraude,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data),
            style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.rouge,
      ));
    } finally {
      if (mounted) setState(() => _escalading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          const _AdminHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.adminDash),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.grisLight),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15, color: AppColors.grisMid)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppStrings.of(context).btnRetry),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleuNuit, foregroundColor: AppColors.blanc),
            ),
          ],
        ),
      );
    }

    final s = _stats!;
    final str = AppStrings.of(context);
    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alertes en attente
            if (s.specialistesEnAttente > 0 || s.temoignagesEnAttente > 0)
              _AlerteBanner(stats: s),
            if (s.specialistesEnAttente > 0 || s.temoignagesEnAttente > 0)
              const SizedBox(height: 20),

            // Statistiques principales
            _SectionTitle(text: str.adminOverview),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _StatCard(
                  label: str.adminUsers,
                  value: s.totalUsers,
                  icon: Icons.people_rounded,
                  color: AppColors.bleuMid,
                  bg: const Color(0xFFE8F0FE),
                ),
                _StatCard(
                  label: str.adminFiles,
                  value: s.totalDossiers,
                  icon: Icons.folder_rounded,
                  color: AppColors.emeraude,
                  bg: AppColors.emeraudeLight,
                ),
                _StatCard(
                  label: str.adminInProgress,
                  value: s.dossiersEnCours,
                  icon: Icons.pending_rounded,
                  color: AppColors.or,
                  bg: AppColors.orLight,
                ),
                _StatCard(
                  label: str.adminResolved,
                  value: s.dossiersResolus,
                  icon: Icons.check_circle_rounded,
                  color: AppColors.emeraude,
                  bg: AppColors.emeraudeLight,
                ),
                _StatCard(
                  label: str.adminVbgReports,
                  value: s.totalVbg,
                  icon: Icons.shield_rounded,
                  color: AppColors.rouge,
                  bg: AppColors.rougeLight,
                ),
                _StatCard(
                  label: str.adminSpecialists,
                  value: s.totalSpecialistes,
                  icon: Icons.gavel_rounded,
                  color: AppColors.bleuNuit,
                  bg: const Color(0xFFE8EEF7),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Actions rapides
            _SectionTitle(text: str.adminActions),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.verified_user_rounded,
              color: AppColors.bleuMid,
              bg: const Color(0xFFE8F0FE),
              label: str.adminCertify,
              badge: s.specialistesEnAttente,
              onTap: () => context.go('/admin/specialistes'),
            ),
            _ActionTile(
              icon: Icons.rate_review_rounded,
              color: AppColors.or,
              bg: AppColors.orLight,
              label: str.adminModerate,
              badge: s.temoignagesEnAttente,
              onTap: () => context.go('/admin/temoignages'),
            ),
            _ActionTile(
              icon: Icons.bar_chart_rounded,
              color: AppColors.emeraude,
              bg: AppColors.emeraudeLight,
              label: str.adminReports,
              badge: 0,
              onTap: () => context.go('/rapports'),
            ),
            _ActionTile(
              icon: Icons.bolt_rounded,
              color: AppColors.rouge,
              bg: AppColors.rougeLight,
              label: _escalading ? str.adminEscalating : str.adminEscalate,
              badge: 0,
              onTap: _escalade,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bannière alertes ─────────────────────────────────────────────────────────

class _AlerteBanner extends StatelessWidget {
  const _AlerteBanner({required this.stats});
  final _Stats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.or.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.or, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.of(context).adminAlertsRequired,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orDark)),
                if (stats.specialistesEnAttente > 0)
                  Text(
                    '${stats.specialistesEnAttente} spécialiste${stats.specialistesEnAttente > 1 ? 's' : ''} en attente de certification',
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 13,
                        color: AppColors.orDark),
                  ),
                if (stats.temoignagesEnAttente > 0)
                  Text(
                    '${stats.temoignagesEnAttente} témoignage${stats.temoignagesEnAttente > 1 ? 's' : ''} en attente de modération',
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 13,
                        color: AppColors.orDark),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B2A), AppColors.bleuNuit],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.or, AppColors.orDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dashboard_rounded,
                    color: AppColors.blanc, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.of(context).adminTitle,
                        style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blanc)),
                    const Text('Tableau de bord',
                        style: TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 13,
                            color: Color(0x80FFFFFF))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.rouge.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.rouge.withAlpha(80)),
                ),
                child: Text(AppStrings.of(context).adminBadge,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.rouge,
                        letterSpacing: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Carte statistique ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color color, bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value',
                  style: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1)),
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 12,
                      color: AppColors.grisMid,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Tuile action ─────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
    required this.badge,
    required this.onTap,
  });
  final IconData icon;
  final Color color, bg;
  final String label;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gris)),
            ),
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.rouge,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$badge',
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blanc)),
              )
            else
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.grisLight),
          ],
        ),
      ),
    );
  }
}

// ─── Titre de section ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
              color: AppColors.or, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(text,
            style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.bleuNuit)),
      ],
    );
  }
}
