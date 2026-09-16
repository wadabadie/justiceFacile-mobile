import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';

// ─── Modèles ──────────────────────────────────────────────────────────────────

class _Activite {
  _Activite({
    required this.id,
    required this.titre,
    required this.description,
    required this.lieu,
    required this.type,
    required this.capacite,
    required this.nbInscrits,
    required this.estInscrit,
    required this.dateActivite,
  });

  final int id;
  final String titre;
  final String description;
  final String lieu;
  final String type;
  final int capacite;
  int nbInscrits;
  bool estInscrit;
  final DateTime dateActivite;

  factory _Activite.fromJson(Map<String, dynamic> j) => _Activite(
        id:           j['id'] as int,
        titre:        j['titre'] as String? ?? '',
        description:  j['description'] as String? ?? '',
        lieu:         j['lieu'] as String? ?? '',
        type:         j['type'] as String?
                          ?? j['type_activite'] as String?
                          ?? 'formation',
        capacite:     j['capacite'] as int? ?? 0,
        nbInscrits:   j['nb_inscrits'] as int? ?? 0,
        estInscrit:   j['est_inscrit'] as bool? ?? false,
        dateActivite: DateTime.tryParse(j['date_activite'] as String?
                          ?? j['date'] as String?
                          ?? '')?.toLocal()
                      ?? DateTime.now(),
      );

  bool get complet => capacite > 0 && nbInscrits >= capacite;

  String get dateLabel {
    final d = dateActivite;
    final months = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun',
                    'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]}. ${d.year} · $h:$m';
  }

  IconData get typeIcon => switch (type.toLowerCase()) {
    'formation'    => Icons.school_rounded,
    'sensibilisation' => Icons.campaign_rounded,
    'assistance'   => Icons.handshake_rounded,
    'reunion'      => Icons.groups_rounded,
    _              => Icons.event_rounded,
  };

  Color get typeColor => switch (type.toLowerCase()) {
    'formation'    => AppColors.bleuMid,
    'sensibilisation' => AppColors.or,
    'assistance'   => AppColors.emeraude,
    'reunion'      => AppColors.grisMid,
    _              => AppColors.bleuNuit,
  };
}

class _Inscription {
  _Inscription({
    required this.id,
    required this.activiteTitre,
    required this.statut,
    required this.presenceConfirmee,
    required this.dateInscription,
  });

  final int id;
  final String activiteTitre;
  final String statut;
  final bool presenceConfirmee;
  final DateTime dateInscription;

  factory _Inscription.fromJson(Map<String, dynamic> j) {
    final activite = j['activite'];
    return _Inscription(
      id:                 j['id'] as int,
      activiteTitre:      activite is Map
                              ? (activite['titre'] as String? ?? 'Activité')
                              : (j['activite_titre'] as String? ?? 'Activité'),
      statut:             j['statut'] as String? ?? 'inscrit',
      presenceConfirmee:  j['presence_confirmee'] as bool? ?? false,
      dateInscription:    DateTime.tryParse(j['date_inscription'] as String? ?? '')
                              ?.toLocal() ?? DateTime.now(),
    );
  }
}

class _Participant {
  _Participant({required this.id, required this.nom, required this.presence});
  final int id;
  final String nom;
  bool presence;

  factory _Participant.fromJson(Map<String, dynamic> j) => _Participant(
        id:       j['id'] as int,
        nom:      j['nom'] as String?
                      ?? '${j['first_name'] ?? ''} ${j['last_name'] ?? ''}'.trim(),
        presence: j['presence_confirmee'] as bool? ?? false,
      );
}

// ─── Écran ────────────────────────────────────────────────────────────────────

class ActivitesScreen extends StatefulWidget {
  const ActivitesScreen({super.key});

  @override
  State<ActivitesScreen> createState() => _ActivitesScreenState();
}

class _ActivitesScreenState extends State<ActivitesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  List<_Activite> _activites = [];
  List<_Inscription> _inscriptions = [];
  bool _loadingActivites = true;
  bool _loadingInscriptions = true;
  String? _errorActivites;
  String? _errorInscriptions;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadActivites();
    _loadInscriptions();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadActivites() async {
    setState(() { _loadingActivites = true; _errorActivites = null; });
    try {
      final res = await ApiService.instance.get(ApiConstants.activites);
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _activites = list
            .map((e) => _Activite.fromJson(e as Map<String, dynamic>))
            .toList();
        _loadingActivites = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorActivites = ApiService.extractError(e.response?.data);
        _loadingActivites = false;
      });
    }
  }

  Future<void> _loadInscriptions() async {
    setState(() { _loadingInscriptions = true; _errorInscriptions = null; });
    try {
      final res = await ApiService.instance.get(ApiConstants.mesInscriptions);
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _inscriptions = list
            .map((e) => _Inscription.fromJson(e as Map<String, dynamic>))
            .toList();
        _loadingInscriptions = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorInscriptions = ApiService.extractError(e.response?.data);
        _loadingInscriptions = false;
      });
    }
  }

  void _openDetail(_Activite a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActiviteSheet(
        activite: a,
        onInscription: () async {
          await _toggleInscription(a);
        },
      ),
    );
  }

  Future<void> _toggleInscription(_Activite a) async {
    try {
      if (a.estInscrit) {
        await ApiService.instance.post(ApiConstants.activiteAnnuler(a.id));
        if (!mounted) return;
        setState(() { a.estInscrit = false; a.nbInscrits--; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).activitesInscriptionAnnulee,
                style: const TextStyle(fontFamily: 'GoogleSans')),
            backgroundColor: AppColors.grisMid,
          ),
        );
      } else {
        await ApiService.instance.post(ApiConstants.activiteInscription(a.id));
        if (!mounted) return;
        setState(() { a.estInscrit = true; a.nbInscrits++; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).activitesInscriptionConfirmee,
                style: const TextStyle(fontFamily: 'GoogleSans')),
            backgroundColor: AppColors.emeraude,
          ),
        );
        _loadInscriptions();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data),
            style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _ActivitesHeader(
            onBack: () => context.go('/home'),
            tabController: _tab,
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _buildActivites(),
                _buildInscriptions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivites() {
    if (_loadingActivites) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }
    if (_errorActivites != null) {
      return _ErrorRetry(error: _errorActivites!, onRetry: _loadActivites);
    }
    if (_activites.isEmpty) {
      return _EmptyState(
        icon: Icons.event_busy_rounded,
        message: AppStrings.of(context).activitesEmpty,
      );
    }
    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _loadActivites,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: _activites.length,
        itemBuilder: (_, i) => _ActiviteCard(
          activite: _activites[i],
          onTap: () => _openDetail(_activites[i]),
        ),
      ),
    );
  }

  Widget _buildInscriptions() {
    if (_loadingInscriptions) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }
    if (_errorInscriptions != null) {
      return _ErrorRetry(
          error: _errorInscriptions!, onRetry: _loadInscriptions);
    }
    if (_inscriptions.isEmpty) {
      return _EmptyState(
        icon: Icons.bookmark_border_rounded,
        message: AppStrings.of(context).activitesNoInscriptions,
      );
    }
    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _loadInscriptions,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: _inscriptions.length,
        itemBuilder: (_, i) => _InscriptionTile(item: _inscriptions[i]),
      ),
    );
  }
}

// ─── Header avec onglets ──────────────────────────────────────────────────────

class _ActivitesHeader extends StatelessWidget {
  const _ActivitesHeader(
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
          colors: [AppColors.bleuNuit, AppColors.emeraude],
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
                          Text(s.activitesTitle,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blanc)),
                          Text(s.activitesSubtitle,
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
                    child: const Icon(Icons.handshake_rounded,
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
              unselectedLabelStyle:
                  const TextStyle(fontFamily: 'GoogleSans', fontSize: 14),
              labelColor: AppColors.blanc,
              unselectedLabelColor: const Color(0x80FFFFFF),
              tabs: [
                Tab(text: AppStrings.of(context).activitesTab1),
                Tab(text: AppStrings.of(context).activitesTab2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Carte activité ───────────────────────────────────────────────────────────

class _ActiviteCard extends StatelessWidget {
  const _ActiviteCard({required this.activite, required this.onTap});
  final _Activite activite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = activite;
    final placesLeft = a.capacite > 0 ? a.capacite - a.nbInscrits : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 10,
                offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: a.typeColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: a.typeColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(a.typeIcon, color: a.typeColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.titre,
                                style: const TextStyle(
                                    fontFamily: 'GoogleSans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.bleuNuit),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(a.type.toUpperCase(),
                                style: TextStyle(
                                    fontFamily: 'GoogleSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: a.typeColor,
                                    letterSpacing: 1)),
                          ],
                        ),
                      ),
                      if (a.estInscrit)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emeraudeLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 12, color: AppColors.emeraude),
                              const SizedBox(width: 4),
                              Text(AppStrings.of(context).activitesInscrit,
                                  style: const TextStyle(
                                      fontFamily: 'GoogleSans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.emeraude)),
                            ],
                          ),
                        )
                      else if (a.complet)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.rougeLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(AppStrings.of(context).activitesComplet,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.rouge)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 14, color: AppColors.grisMid),
                      const SizedBox(width: 5),
                      Text(a.dateLabel,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 13,
                              color: AppColors.gris)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppColors.grisMid),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(a.lieu,
                            style: const TextStyle(
                                fontFamily: 'GoogleSans',
                                fontSize: 13,
                                color: AppColors.gris),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (placesLeft != null)
                        Text(
                          AppStrings.of(context).activitesPlacesRestantes(placesLeft),
                          style: TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 12,
                              color: placesLeft <= 3
                                  ? AppColors.rouge
                                  : AppColors.grisMid,
                              fontWeight: placesLeft <= 3
                                  ? FontWeight.w600
                                  : FontWeight.w400),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tuile inscription ────────────────────────────────────────────────────────

class _InscriptionTile extends StatelessWidget {
  const _InscriptionTile({required this.item});
  final _Inscription item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.emeraudeLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_available_rounded,
                color: AppColors.emeraude, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.activiteTitre,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bleuNuit),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(item.statut,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 12,
                        color: AppColors.grisMid)),
              ],
            ),
          ),
          if (item.presenceConfirmee)
            const Icon(Icons.verified_rounded,
                color: AppColors.emeraude, size: 20)
          else
            const Icon(Icons.pending_rounded,
                color: AppColors.or, size: 20),
        ],
      ),
    );
  }
}

// ─── Bottom sheet — détail activité ──────────────────────────────────────────

class _ActiviteSheet extends StatefulWidget {
  const _ActiviteSheet(
      {required this.activite, required this.onInscription});
  final _Activite activite;
  final Future<void> Function() onInscription;

  @override
  State<_ActiviteSheet> createState() => _ActiviteSheetState();
}

class _ActiviteSheetState extends State<_ActiviteSheet> {
  List<_Participant> _participants = [];
  bool _loadingParticipants = false;
  bool _actionLoading = false;
  bool _rapportLoading = false;
  bool _showParticipants = false;

  Future<void> _loadParticipants() async {
    setState(() => _loadingParticipants = true);
    try {
      final res = await ApiService.instance
          .get(ApiConstants.activiteParticipants(widget.activite.id));
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _participants = list
            .map((e) => _Participant.fromJson(e as Map<String, dynamic>))
            .toList();
        _loadingParticipants = false;
        _showParticipants = true;
      });
    } on DioException {
      if (!mounted) return;
      setState(() => _loadingParticipants = false);
    }
  }

  Future<void> _marquerPresence(_Participant p) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ApiService.instance
          .post(ApiConstants.inscriptionPresence(p.id));
      if (!mounted) return;
      setState(() => p.presence = true);
    } on DioException catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data),
            style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  Future<void> _rapport() async {
    if (_rapportLoading) return;
    setState(() => _rapportLoading = true);
    try {
      await ApiService.instance
          .get(ApiConstants.activiteRapport(widget.activite.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).activitesRapportGenere,
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
      if (mounted) setState(() => _rapportLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activite;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Poignée
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0x20000000),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Type + titre
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: a.typeColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(a.typeIcon, color: a.typeColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.titre,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bleuNuit)),
                      Text(a.type.toUpperCase(),
                          style: TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: a.typeColor,
                              letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Infos
            _SheetRow(icon: Icons.schedule_rounded, text: a.dateLabel),
            const SizedBox(height: 8),
            _SheetRow(icon: Icons.location_on_rounded, text: a.lieu),
            const SizedBox(height: 8),
            _SheetRow(
              icon: Icons.people_rounded,
              text: a.capacite > 0
                  ? '${a.nbInscrits} / ${a.capacite} inscrits'
                  : '${a.nbInscrits} inscrits',
            ),
            const SizedBox(height: 16),
            // Description
            Text(a.description,
                style: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 14,
                    color: AppColors.grisMid,
                    height: 1.5)),
            const SizedBox(height: 20),
            // Bouton inscription
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (a.complet && !a.estInscrit) || _actionLoading
                    ? null
                    : () async {
                        final nav = Navigator.of(context);
                        setState(() => _actionLoading = true);
                        await widget.onInscription();
                        if (mounted) {
                          setState(() => _actionLoading = false);
                          nav.pop();
                        }
                      },
                icon: _actionLoading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.blanc))
                    : Icon(a.estInscrit
                        ? Icons.cancel_rounded
                        : Icons.how_to_reg_rounded),
                label: Builder(builder: (ctx) {
                  final s = AppStrings.of(ctx);
                  return Text(
                    a.estInscrit
                        ? s.activitesAnnulerInscription
                        : a.complet
                            ? s.activitesInscriptionComplete
                            : s.activitesSInscrire,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  );
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      a.estInscrit ? AppColors.rouge : AppColors.emeraude,
                  foregroundColor: AppColors.blanc,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Actions ONG
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loadingParticipants ? null : _loadParticipants,
                    icon: _loadingParticipants
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.bleuMid))
                        : const Icon(Icons.groups_rounded, size: 18),
                    label: Text(AppStrings.of(context).activitesParticipants,
                        style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.bleuMid,
                      side: const BorderSide(color: AppColors.bleuMid),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _rapportLoading ? null : _rapport,
                    icon: _rapportLoading
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.or))
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text(AppStrings.of(context).activitesRapport,
                        style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.or,
                      side: BorderSide(color: AppColors.or.withAlpha(180)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            // Liste participants
            if (_showParticipants) ...[
              const SizedBox(height: 16),
              Text(AppStrings.of(context).activitesParticipants,
                  style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bleuNuit)),
              const SizedBox(height: 8),
              ..._participants.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.fond,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_rounded,
                            size: 18, color: AppColors.grisMid),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(p.nom,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 14,
                                  color: AppColors.gris)),
                        ),
                        GestureDetector(
                          onTap: p.presence ? null : () => _marquerPresence(p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: p.presence
                                  ? AppColors.emeraudeLight
                                  : AppColors.fond2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p.presence
                                  ? AppStrings.of(context).activitesPresent
                                  : AppStrings.of(context).activitesMarquer,
                              style: TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: p.presence
                                      ? AppColors.emeraude
                                      : AppColors.grisMid),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grisMid),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 14,
                  color: AppColors.gris)),
        ),
      ],
    );
  }
}

// ─── États vide / erreur ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(
                color: AppColors.fond2, shape: BoxShape.circle),
            child: Icon(icon, size: 36, color: AppColors.grisLight),
          ),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bleuNuit)),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.error, required this.onRetry});
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
