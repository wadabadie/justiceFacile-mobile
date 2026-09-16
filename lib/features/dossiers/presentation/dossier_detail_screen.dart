import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../domain/entities/dossier_entity.dart';

class DossierDetailScreen extends StatefulWidget {
  const DossierDetailScreen({super.key, required this.dossier});
  final DossierEntity dossier;

  @override
  State<DossierDetailScreen> createState() => _DossierDetailScreenState();
}

class _DossierDetailScreenState extends State<DossierDetailScreen> {
  late DossierEntity _dossier;
  List<Map<String, dynamic>> _comptesRendus = [];
  bool _loadingCr = true;
  String? _errorCr;
  bool _submittingResolution = false;
  bool _submittingProposition = false;

  @override
  void initState() {
    super.initState();
    _dossier = widget.dossier;
    if (!_dossier.isDemande) {
      _refreshDetail();
      _loadComptesRendus();
    } else if (_dossier.statut == DossierStatut.proposition) {
      _refreshDemande();
    }
  }

  Future<void> _refreshDetail() async {
    try {
      final res = await ApiService.instance.get(ApiConstants.dossier(_dossier.id));
      if (!mounted) return;
      setState(() {
        _dossier = DossierEntity.fromDossier(res.data as Map<String, dynamic>);
      });
    } on DioException {
      // Silent — the entity passed in is used as a fallback.
    }
  }

  Future<void> _refreshDemande() async {
    try {
      final res = await ApiService.instance.get('${ApiConstants.demandes}${_dossier.id}/');
      if (!mounted) return;
      setState(() {
        _dossier = DossierEntity.fromDemande(res.data as Map<String, dynamic>);
      });
    } on DioException {
      // Silent — the entity passed in is used as a fallback.
    }
  }

  Future<void> _confirmerProposition(bool accepte) async {
    final s = AppStrings.of(context);

    if (!accepte) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.propositionConfirmRefuseTitle),
          content: Text(s.propositionConfirmRefuseMsg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.btnCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.rouge),
              child: Text(s.detailBtnRefuse),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    setState(() => _submittingProposition = true);
    try {
      await ApiService.instance.post(
        ApiConstants.demandeConfirmer(_dossier.id),
        data: {'accepte': accepte},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(accepte ? s.propositionAccepted : s.propositionRefused),
        backgroundColor: accepte ? AppColors.emeraude : AppColors.grisMid,
      ));
      if (accepte) {
        // A Dossier has just been created — go back to the list to see it.
        context.go('/dossiers');
      } else {
        await _refreshDemande();
      }
    } on DioException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.propositionError),
        backgroundColor: AppColors.rouge,
      ));
    } finally {
      if (mounted) setState(() => _submittingProposition = false);
    }
  }

  Future<void> _loadComptesRendus() async {
    setState(() { _loadingCr = true; _errorCr = null; });
    try {
      final res = await ApiService.instance.get(
        ApiConstants.dossierCompteRendu(_dossier.id),
      );
      if (!mounted) return;
      setState(() {
        _comptesRendus = (res.data as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _loadingCr = false;
      });
    } on DioException {
      if (!mounted) return;
      setState(() { _loadingCr = false; _errorCr = AppStrings.of(context).detailCrLoadError; });
    }
  }

  Future<void> _confirmerResolution(bool accepte) async {
    final s = AppStrings.of(context);

    if (!accepte) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.detailConfirmRefuseTitle),
          content: Text(s.detailConfirmRefuseMsg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.btnCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.rouge),
              child: Text(s.detailBtnRefuse),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    setState(() => _submittingResolution = true);
    try {
      await ApiService.instance.post(
        ApiConstants.dossierConfirmerResolution(_dossier.id),
        data: {'accepte': accepte},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(accepte ? s.detailResolutionAccepted : s.detailResolutionRefused),
        backgroundColor: accepte ? AppColors.emeraude : AppColors.grisMid,
      ));
      await _refreshDetail();
    } on DioException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.detailResolutionError),
        backgroundColor: AppColors.rouge,
      ));
    } finally {
      if (mounted) setState(() => _submittingResolution = false);
    }
  }

  void _openChat(String canal, String contactName) {
    context.go('/chat', extra: {
      'dossierId':   _dossier.id,
      'canal':       canal,
      'contactName': contactName,
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = _dossier;
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _DetailHeader(dossier: d),
          Expanded(
            child: d.isDemande ? _buildDemandeBody(d) : _buildDossierBody(d),
          ),
        ],
      ),
    );
  }

  Widget _buildDemandeBody(DossierEntity d) {
    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _refreshDemande,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (d.statut == DossierStatut.proposition) ...[
              _PropositionBanner(
                nomSpecialiste: d.nomSpecialisteProposee,
                roleSpecialiste: d.roleSpecialisteProposee,
                submitting: _submittingProposition,
                onAccept: () => _confirmerProposition(true),
                onRefuse: () => _confirmerProposition(false),
              ),
              const SizedBox(height: 16),
            ],
            _InfoCard(dossier: d),
            const SizedBox(height: 16),
            _DescriptionCard(description: d.description),
            const SizedBox(height: 16),
            if (d.statut != DossierStatut.proposition)
              _PendingBanner(statut: d.statut),
          ],
        ),
      ),
    );
  }

  Widget _buildDossierBody(DossierEntity d) {
    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: () async {
        await _refreshDetail();
        await _loadComptesRendus();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (d.aResolutionProposee) ...[
              _ResolutionBanner(
                proposeur: d.nomResolutionProposeur,
                submitting: _submittingResolution,
                onAccept: () => _confirmerResolution(true),
                onRefuse: () => _confirmerResolution(false),
              ),
              const SizedBox(height: 16),
            ],
            _InfoCard(dossier: d),
            const SizedBox(height: 16),
            _DescriptionCard(description: d.description),
            const SizedBox(height: 16),
            if (d.specialisteNom != null) ...[
              _SpecialistCard(
                nom: d.specialisteNom!,
                role: d.specialisteRole ?? 'Spécialiste',
                onChat: () => _openChat(
                  _canalFromRole(d.specialisteRole),
                  d.specialisteNom!,
                ),
                onBookRdv: () => context.push('/rdv/book', extra: {
                  'dossierId':      d.id,
                  'canal':          _canalFromRole(d.specialisteRole),
                  'specialisteNom': d.specialisteNom!,
                }),
              ),
              const SizedBox(height: 16),
            ],
            _ComptesRendusSection(
              items: _comptesRendus,
              loading: _loadingCr,
              error: _errorCr,
              onRetry: _loadComptesRendus,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _canalFromRole(String? role) => switch (role?.toLowerCase()) {
    'juriste'      => 'juriste',
    'psychologue'  => 'psychologue',
    'ong'          => 'ong',
    _              => 'juriste',
  };
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.dossier});
  final DossierEntity dossier;

  Color get _statusColor => switch (dossier.statut) {
    DossierStatut.urgent      => AppColors.rouge,
    DossierStatut.resolu      => AppColors.emeraude,
    DossierStatut.rejete      => AppColors.rouge,
    DossierStatut.en_cours    => AppColors.or,
    DossierStatut.approuve    => AppColors.emeraude,
    DossierStatut.proposition => AppColors.orDark,
    DossierStatut.en_attente  => AppColors.grisMid,
  };

  String _statusLabel(BuildContext context) {
    final s = AppStrings.of(context);
    return switch (dossier.statut) {
      DossierStatut.urgent      => s.statusUrgent,
      DossierStatut.resolu      => s.statusResolved,
      DossierStatut.rejete      => s.statusRejected,
      DossierStatut.en_cours    => s.statusInProgress,
      DossierStatut.approuve    => s.statusApproved,
      DossierStatut.proposition => s.statusProposition,
      DossierStatut.en_attente  => s.statusPending,
    };
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(6, 4, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/dossiers'),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.blanc),
                  ),
                  Expanded(
                    child: Text(
                      dossier.isDemande
                          ? AppStrings.of(context).detailMaDemande
                          : AppStrings.of(context).detailMonDossier,
                      style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blanc,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor.withAlpha(40),
                      border: Border.all(color: _statusColor.withAlpha(120)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel(context),
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        )),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 0, 0),
                child: Text(
                  dossier.titre,
                  style: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.orPale,
                    height: 1.3,
                  ),
                ),
              ),
              if (dossier.numero.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 0, 0),
                  child: Text(
                    dossier.numero,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      color: Color(0x80FFFFFF),
                      letterSpacing: 0.5,
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

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.dossier});
  final DossierEntity dossier;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.info_outline_rounded, label: AppStrings.of(context).detailInfoTitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _Chip(label: dossier.categorie, color: AppColors.bleuMid, bg: const Color(0xFFE8F0FE)),
              if (dossier.region != null)
                _Chip(label: dossier.region!, color: AppColors.grisMid, bg: const Color(0xFFF0F0F0)),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.calendar_today_rounded,
              label: AppStrings.of(context).detailCreeLe, value: _fmt(dossier.dateCreation)),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.update_rounded,
              label: AppStrings.of(context).detailMisAJour, value: _fmt(dossier.dateMaj)),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grisMid),
        const SizedBox(width: 8),
        Text('$label : ',
            style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 13, color: AppColors.grisMid)),
        Text(value,
            style: const TextStyle(
              fontFamily: 'GoogleSans', fontSize: 13,
              fontWeight: FontWeight.w600, color: AppColors.gris,
            )),
      ],
    );
  }
}

// ── Description card ──────────────────────────────────────────────────────────

class _DescriptionCard extends StatefulWidget {
  const _DescriptionCard({required this.description});
  final String description;

  @override
  State<_DescriptionCard> createState() => _DescriptionCardState();
}

class _DescriptionCardState extends State<_DescriptionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.description.length > 200;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.description_outlined, label: AppStrings.of(context).detailDescription),
          const SizedBox(height: 10),
          Text(
            _expanded || !isLong
                ? widget.description
                : '${widget.description.substring(0, 200)}…',
            style: const TextStyle(
              fontFamily: 'GoogleSans', fontSize: 15,
              color: AppColors.gris, height: 1.6,
            ),
          ),
          if (isLong) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded
                    ? AppStrings.of(context).detailVoirMoins
                    : AppStrings.of(context).detailVoirPlus,
                style: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 13,
                  fontWeight: FontWeight.w700, color: AppColors.bleuMid,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Pending banner ────────────────────────────────────────────────────────────

class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.statut});
  final DossierStatut statut;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isApproved = statut == DossierStatut.approuve;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isApproved ? AppColors.emeraudeLight : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isApproved ? AppColors.emeraude.withAlpha(80) : AppColors.or.withAlpha(80),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isApproved ? AppColors.emeraude.withAlpha(30) : AppColors.orLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isApproved ? Icons.check_circle_outline_rounded : Icons.hourglass_top_rounded,
              color: isApproved ? AppColors.emeraude : AppColors.orDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isApproved ? s.detailApprovedTitle : s.detailPendingTitle,
                  style: TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isApproved ? AppColors.emeraude : AppColors.orDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isApproved ? s.detailApprovedDesc : s.detailPendingDesc,
                  style: const TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 13,
                    color: AppColors.grisMid, height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Specialist proposal banner (PROPOSITION) ─────────────────────────────────

class _PropositionBanner extends StatelessWidget {
  const _PropositionBanner({
    required this.nomSpecialiste,
    required this.roleSpecialiste,
    required this.submitting,
    required this.onAccept,
    required this.onRefuse,
  });
  final String? nomSpecialiste;
  final String? roleSpecialiste;
  final bool submitting;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  String _localizedRole(BuildContext context) {
    switch ((roleSpecialiste ?? '').toUpperCase()) {
      case 'JURISTE':     return 'Juriste';
      case 'PSYCHOLOGUE': return 'Psychologue';
      case 'ONG':         return 'ONG';
      default:            return 'Spécialiste';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.orLight, AppColors.orPale.withAlpha(80)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.or.withAlpha(140)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.orDark.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_search_rounded, color: AppColors.orDark, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.propositionTitle,
                      style: const TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 16,
                        fontWeight: FontWeight.w700, color: AppColors.orDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.propositionSubtitle,
                      style: const TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 12,
                        color: AppColors.grisMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (nomSpecialiste != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blanc,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x14000000)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.bleuMid,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        nomSpecialiste!.trim().split(' ').take(2)
                            .map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 15,
                          fontWeight: FontWeight.w700, color: AppColors.blanc,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nomSpecialiste!,
                            style: const TextStyle(
                              fontFamily: 'GoogleSans', fontSize: 15,
                              fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
                            )),
                        Text(_localizedRole(context),
                            style: const TextStyle(
                              fontFamily: 'GoogleSans', fontSize: 12,
                              color: AppColors.grisMid,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: submitting ? null : onRefuse,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(s.detailBtnRefuse),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rouge,
                    side: BorderSide(color: AppColors.rouge.withAlpha(120)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 14, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: submitting ? null : onAccept,
                  icon: submitting
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.blanc,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(s.propositionBtnAccept),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orDark,
                    foregroundColor: AppColors.blanc,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 14, fontWeight: FontWeight.w700,
                    ),
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

// ── Resolution proposal banner ────────────────────────────────────────────────

class _ResolutionBanner extends StatelessWidget {
  const _ResolutionBanner({
    required this.proposeur,
    required this.submitting,
    required this.onAccept,
    required this.onRefuse,
  });
  final String? proposeur;
  final bool submitting;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emeraude.withAlpha(100)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.emeraude.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.task_alt_rounded, color: AppColors.emeraude, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.detailResolutionTitle,
                  style: const TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 16,
                    fontWeight: FontWeight.w700, color: AppColors.emeraude,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            s.detailResolutionDesc,
            style: const TextStyle(
              fontFamily: 'GoogleSans', fontSize: 13,
              color: AppColors.gris, height: 1.4,
            ),
          ),
          if (proposeur != null) ...[
            const SizedBox(height: 6),
            Text(
              '— $proposeur',
              style: const TextStyle(
                fontFamily: 'GoogleSans', fontSize: 12,
                fontStyle: FontStyle.italic, color: AppColors.grisMid,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: submitting ? null : onRefuse,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(s.detailBtnRefuse),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rouge,
                    side: BorderSide(color: AppColors.rouge.withAlpha(120)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 14, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: submitting ? null : onAccept,
                  icon: submitting
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.blanc,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(s.detailBtnAccept),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraude,
                    foregroundColor: AppColors.blanc,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 14, fontWeight: FontWeight.w700,
                    ),
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

// ── Specialist card ───────────────────────────────────────────────────────────

class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard({
    required this.nom,
    required this.role,
    required this.onChat,
    required this.onBookRdv,
  });
  final String nom, role;
  final VoidCallback onChat;
  final VoidCallback onBookRdv;

  Color get _roleColor => switch (role.toLowerCase()) {
    'juriste'     => AppColors.bleuMid,
    'psychologue' => AppColors.emeraude,
    'ong'         => AppColors.or,
    _             => AppColors.grisMid,
  };

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.person_rounded, label: AppStrings.of(context).detailSpecialisteAssigne),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_roleColor.withAlpha(200), _roleColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    nom.trim().split(' ').take(2)
                        .map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 18,
                      fontWeight: FontWeight.w700, color: AppColors.blanc,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nom,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 16,
                          fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
                        )),
                    Text(role,
                        style: TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 13,
                          color: _roleColor, fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: Text(AppStrings.of(context).detailContacter(role)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _roleColor,
                    foregroundColor: AppColors.blanc,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 13, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBookRdv,
                  icon: const Icon(Icons.calendar_month_rounded, size: 16),
                  label: Text(AppStrings.of(context).rdvBookBtn),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _roleColor,
                    side: BorderSide(color: _roleColor.withAlpha(140)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 13, fontWeight: FontWeight.w700,
                    ),
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


// ── Comptes-rendus ────────────────────────────────────────────────────────────

class _ComptesRendusSection extends StatelessWidget {
  const _ComptesRendusSection({
    required this.items,
    required this.loading,
    required this.error,
    required this.onRetry,
  });
  final List<Map<String, dynamic>> items;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.assignment_outlined, label: AppStrings.of(context).detailComptesRendus),
          const SizedBox(height: 12),
          if (loading)
            const Center(child: CircularProgressIndicator(color: AppColors.bleuNuit))
          else if (error != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(AppStrings.of(context).btnRetry),
            )
          else if (items.isEmpty)
            Text(AppStrings.of(context).detailNoCr,
                style: TextStyle(fontFamily: 'GoogleSans', fontSize: 13, color: AppColors.grisMid))
          else
            ...items.map((cr) => _CrTile(cr: cr)),
        ],
      ),
    );
  }
}

class _CrTile extends StatelessWidget {
  const _CrTile({required this.cr});
  final Map<String, dynamic> cr;

  @override
  Widget build(BuildContext context) {
    final titre = cr['titre'] as String? ?? cr['objet'] as String? ?? 'Compte-rendu';
    final date  = cr['date_creation'] as String? ?? cr['date'] as String? ?? '';
    final contenu = cr['contenu'] as String? ?? cr['resume'] as String? ?? '';

    String fmtDate = '';
    if (date.isNotEmpty) {
      try {
        final d = DateTime.parse(date).toLocal();
        fmtDate = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x0F000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(titre,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 14,
                      fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
                    )),
              ),
              if (fmtDate.isNotEmpty)
                Text(fmtDate,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 12, color: AppColors.grisLight,
                    )),
            ],
          ),
          if (contenu.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(contenu,
                style: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 13,
                  color: AppColors.grisMid, height: 1.4,
                )),
          ],
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: AppColors.bleuNuit.withAlpha(12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.bleuNuit, size: 18),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
              fontFamily: 'GoogleSans', fontSize: 16,
              fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
            )),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, required this.bg});
  final String label;
  final Color color, bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
            fontFamily: 'GoogleSans', fontSize: 13,
            fontWeight: FontWeight.w600, color: color,
          )),
    );
  }
}
