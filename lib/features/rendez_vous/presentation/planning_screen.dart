import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';

// ─── Modèle ───────────────────────────────────────────────────────────────────

enum _Statut { enAttente, confirme, annule, termine, inconnu }

class _Rdv {
  _Rdv({
    required this.id,
    required this.dossierTitre,
    required this.specialisteNom,
    required this.canal,
    required this.dateRdv,
    required this.statut,
  });

  final int id;
  final String dossierTitre;
  final String specialisteNom;
  final String canal;
  final DateTime dateRdv;
  final _Statut statut;

  factory _Rdv.fromJson(Map<String, dynamic> j) {
    final rawStatut = (j['statut'] as String? ?? '').toLowerCase();
    final statut = switch (rawStatut) {
      'en_attente' || 'attente' => _Statut.enAttente,
      'confirme' || 'confirmé'  => _Statut.confirme,
      'annule' || 'annulé'      => _Statut.annule,
      'termine' || 'terminé'    => _Statut.termine,
      _                         => _Statut.inconnu,
    };

    // dossier may be an object or just a string
    final dossier = j['dossier'];
    final dossierTitre = dossier is Map
        ? (dossier['titre'] as String? ?? 'Dossier')
        : (j['dossier_titre'] as String? ?? 'Dossier');

    return _Rdv(
      id:              j['id'] as int,
      dossierTitre:    dossierTitre,
      specialisteNom:  j['specialiste_nom'] as String?
                           ?? j['nom_specialiste'] as String?
                           ?? 'Spécialiste',
      canal:           j['canal'] as String? ?? 'visio',
      dateRdv:         DateTime.tryParse(j['date_rdv'] as String? ?? '')?.toLocal()
                           ?? DateTime.now(),
      statut:          statut,
    );
  }

  bool get isUpcoming => dateRdv.isAfter(DateTime.now());

  String get canalLabel => switch (canal) {
    'visio'       => 'Visioconférence',
    'chat'        => 'Chat',
    'presentiel'  => 'Présentiel',
    _             => canal,
  };

  String get dateLabel {
    final d = dateRdv;
    final months = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun',
                    'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]}. ${d.year} · $h:$m';
  }
}

// ─── Écran ────────────────────────────────────────────────────────────────────

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  List<_Rdv> _rdvs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.instance.get(ApiConstants.monPlanning);
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _rdvs = list
            .map((e) => _Rdv.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.dateRdv.compareTo(b.dateRdv));
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

  Future<void> _rejoindreVisio(int rdvId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.bleuNuit),
      ),
    );
    try {
      final res = await ApiService.instance.get(ApiConstants.tokenVisio(rdvId));
      if (!mounted) return;
      Navigator.of(context).pop(); // close spinner
      final data = res.data as Map<String, dynamic>;
      _showVisioDialog(data);
    } on DioException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data),
            style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  void _showVisioDialog(Map<String, dynamic> data) {
    final token   = data['token']   as String? ?? '';
    final channel = data['channel'] as String? ?? data['canal'] as String? ?? '';
    final uid     = data['uid']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Builder(builder: (bCtx) {
          final s = AppStrings.of(bCtx);
          return Row(
            children: [
              const Icon(Icons.videocam_rounded,
                  color: AppColors.bleuMid, size: 22),
              const SizedBox(width: 10),
              Text(s.planningSessionPrete,
                  style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bleuNuit)),
            ],
          );
        }),
        content: Builder(builder: (bCtx) {
          final s = AppStrings.of(bCtx);
          return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.planningSessionInfo,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 13,
                  color: AppColors.grisMid,
                  height: 1.4),
            ),
            const SizedBox(height: 14),
            _InfoRow(label: s.planningCanal, value: channel),
            const SizedBox(height: 8),
            _InfoRow(label: 'UID', value: uid),
            const SizedBox(height: 8),
            _InfoRow(label: 'Token', value: token, mono: true, truncate: true),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token));
                  ScaffoldMessenger.of(bCtx).showSnackBar(
                    SnackBar(
                      content: Text(s.planningTokenCopie,
                          style: const TextStyle(fontFamily: 'GoogleSans')),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: Text(s.planningCopierToken,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans', fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.bleuMid,
                  side: const BorderSide(color: AppColors.bleuMid),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        );
        }),
        actions: [
          Builder(builder: (bCtx) {
            final s = AppStrings.of(bCtx);
            return TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.planningFermer,
                style: const TextStyle(
                    fontFamily: 'GoogleSans', color: AppColors.grisMid)),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _rdvs.where((r) => r.isUpcoming).toList();
    final past     = _rdvs.where((r) => !r.isUpcoming).toList();

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _PlanningHeader(
            onBack: () => context.go('/home'),
            tabController: _tab,
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.bleuNuit))
                : _error != null
                    ? _ErrorView(error: _error!, onRetry: _load)
                    : TabBarView(
                        controller: _tab,
                        children: [
                          _RdvList(
                            rdvs: upcoming,
                            emptyMessage: AppStrings.of(context).planningAucunAvenir,
                            emptyIcon: Icons.event_available_rounded,
                            onRefresh: _load,
                            onRejoindre: _rejoindreVisio,
                          ),
                          _RdvList(
                            rdvs: past,
                            emptyMessage: AppStrings.of(context).planningAucunPasse,
                            emptyIcon: Icons.history_rounded,
                            onRefresh: _load,
                            onRejoindre: null,
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Header avec onglets ──────────────────────────────────────────────────────

class _PlanningHeader extends StatelessWidget {
  const _PlanningHeader(
      {required this.onBack, required this.tabController});
  final VoidCallback onBack;
  final TabController tabController;

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.blanc, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Builder(builder: (ctx) {
                      final s = AppStrings.of(ctx);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.planningTitle,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blanc)),
                          Text(s.planningSubtitle,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 13,
                                  color: Color(0x99FFFFFF))),
                        ],
                      );
                    }),
                  ),
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_month_rounded,
                        color: AppColors.orPale, size: 20),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: tabController,
              indicatorColor: AppColors.orPale,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 14),
              labelColor: AppColors.blanc,
              unselectedLabelColor: const Color(0x80FFFFFF),
              tabs: [
                Tab(text: AppStrings.of(context).planningTabAvenir),
                Tab(text: AppStrings.of(context).planningTabPasses),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Liste de RDVs ────────────────────────────────────────────────────────────

class _RdvList extends StatelessWidget {
  const _RdvList({
    required this.rdvs,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onRefresh,
    required this.onRejoindre,
  });
  final List<_Rdv> rdvs;
  final String emptyMessage;
  final IconData emptyIcon;
  final Future<void> Function() onRefresh;
  final Future<void> Function(int rdvId)? onRejoindre;

  @override
  Widget build(BuildContext context) {
    if (rdvs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                  color: AppColors.fond2, shape: BoxShape.circle),
              child: Icon(emptyIcon, size: 36, color: AppColors.grisLight),
            ),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bleuNuit)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: rdvs.length,
        itemBuilder: (_, i) => _RdvCard(
          rdv: rdvs[i],
          onRejoindre: onRejoindre != null
              ? () => onRejoindre!(rdvs[i].id)
              : null,
        ),
      ),
    );
  }
}

// ─── Carte RDV ────────────────────────────────────────────────────────────────

class _RdvCard extends StatelessWidget {
  const _RdvCard({required this.rdv, required this.onRejoindre});
  final _Rdv rdv;
  final VoidCallback? onRejoindre;

  Color get _statutColor => switch (rdv.statut) {
    _Statut.confirme  => AppColors.emeraude,
    _Statut.enAttente => AppColors.or,
    _Statut.annule    => AppColors.rouge,
    _Statut.termine   => AppColors.grisMid,
    _Statut.inconnu   => AppColors.grisMid,
  };

  String _statutLabel(BuildContext context) {
    final s = AppStrings.of(context);
    return switch (rdv.statut) {
      _Statut.confirme  => s.statutConfirme,
      _Statut.enAttente => s.statutEnAttente,
      _Statut.annule    => s.statutAnnule,
      _Statut.termine   => s.statutTermine,
      _Statut.inconnu   => s.statutInconnu,
    };
  }

  IconData get _canalIcon => switch (rdv.canal) {
    'visio'      => Icons.videocam_rounded,
    'chat'       => Icons.chat_rounded,
    'presentiel' => Icons.location_on_rounded,
    _            => Icons.event_rounded,
  };

  bool get _canJoin =>
      rdv.statut == _Statut.confirme &&
      rdv.canal == 'visio' &&
      rdv.isUpcoming &&
      onRejoindre != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // Bandeau coloré statut
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: _statutColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête : spécialiste + statut
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.bleuNuit.withAlpha(15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.bleuNuit, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rdv.specialisteNom,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.bleuNuit)),
                          Text(rdv.dossierTitre,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 12,
                                  color: AppColors.grisMid),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statutColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_statutLabel(context),
                          style: TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _statutColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Date + canal
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 16, color: AppColors.grisMid),
                    const SizedBox(width: 6),
                    Text(rdv.dateLabel,
                        style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 14,
                            color: AppColors.gris,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 14),
                    Icon(_canalIcon,
                        size: 16, color: AppColors.bleuMid),
                    const SizedBox(width: 6),
                    Text(() {
                          final s = AppStrings.of(context);
                          return switch (rdv.canal) {
                            'visio'      => s.canalVisio,
                            'chat'       => s.canalChat,
                            'presentiel' => s.canalPresentiel,
                            _            => rdv.canal,
                          };
                        }(),
                        style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 14,
                            color: AppColors.bleuMid,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                // Bouton "Rejoindre" (visio confirmée uniquement)
                if (_canJoin) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onRejoindre,
                      icon: const Icon(Icons.videocam_rounded, size: 18),
                      label: Text(AppStrings.of(context).planningRejoindreVisio,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bleuMid,
                        foregroundColor: AppColors.blanc,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ligne info dans la dialog visio ─────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.mono = false,
    this.truncate = false,
  });
  final String label;
  final String value;
  final bool mono;
  final bool truncate;

  @override
  Widget build(BuildContext context) {
    final display = (truncate && value.length > 32)
        ? '${value.substring(0, 16)}…${value.substring(value.length - 8)}'
        : value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Text('$label :',
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grisMid)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(display,
              style: TextStyle(
                  fontFamily: mono ? 'monospace' : 'GoogleSans',
                  fontSize: 13,
                  color: AppColors.gris)),
        ),
      ],
    );
  }
}

// ─── Vue erreur ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppColors.grisLight),
          const SizedBox(height: 16),
          Text(error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 15,
                  color: AppColors.grisMid)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(AppStrings.of(context).btnRetry),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bleuNuit,
                foregroundColor: AppColors.blanc),
          ),
        ],
      ),
    );
  }
}
