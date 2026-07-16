import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../domain/entities/dossier_entity.dart';

// Mock data — replace with API calls to GET /api/v1/demandes/ and GET /api/v1/dossiers/
final _mockDemandes = [
  DossierEntity(
    id: 4, numero: 'JF-2026-004',
    titre: 'Pension alimentaire',
    categorie: 'Droit de la famille',
    description: 'Non-paiement de la pension après divorce.',
    statut: DossierStatut.en_attente,
    region: 'Centre',
    dateCreation: DateTime(2026, 6, 8), dateMaj: DateTime(2026, 6, 8),
  ),
  DossierEntity(
    id: 5, numero: 'JF-2026-005',
    titre: 'Harcèlement au travail',
    categorie: 'Droit du travail',
    description: 'Comportement abusif répété de la hiérarchie.',
    statut: DossierStatut.en_attente,
    region: 'Littoral',
    dateCreation: DateTime(2026, 6, 9), dateMaj: DateTime(2026, 6, 9),
  ),
];

final _mockDossiers = [
  DossierEntity(
    id: 1, numero: 'JF-2026-001',
    titre: 'Violence conjugale',
    categorie: 'VBG',
    description: 'Situation de violence répétée au domicile conjugal.',
    statut: DossierStatut.urgent,
    specialisteNom: 'Me. Fotso Jean', specialisteRole: 'Juriste',
    region: 'Centre',
    dateCreation: DateTime(2026, 5, 1), dateMaj: DateTime(2026, 6, 9),
  ),
  DossierEntity(
    id: 2, numero: 'JF-2026-002',
    titre: 'Licenciement abusif',
    categorie: 'Droit du travail',
    description: 'Rupture de contrat sans motif valable.',
    statut: DossierStatut.en_cours,
    specialisteNom: 'Me. Ateba Rose', specialisteRole: 'Juriste',
    region: 'Littoral',
    dateCreation: DateTime(2026, 5, 10), dateMaj: DateTime(2026, 6, 7),
  ),
  DossierEntity(
    id: 3, numero: 'JF-2026-003',
    titre: 'Litige foncier',
    categorie: 'Droit foncier',
    description: 'Conflit de propriété sur un terrain familial.',
    statut: DossierStatut.resolu,
    specialisteNom: 'Me. Ngo Pauline', specialisteRole: 'Juriste',
    region: 'Ouest',
    dateCreation: DateTime(2026, 4, 20), dateMaj: DateTime(2026, 6, 1),
  ),
];


class DossiersScreen extends StatefulWidget {
  const DossiersScreen({super.key});

  @override
  State<DossiersScreen> createState() => _DossiersScreenState();
}

// Filter mode: null = all, true = demandes only, false = dossiers only + optional status
enum _ViewFilter { all, demandes, enCours, urgent, resolu }

class _DossiersScreenState extends State<DossiersScreen> {
  final _searchCtrl = TextEditingController();
  _ViewFilter _filtre = _ViewFilter.all;
  String _query = '';

  bool _matchesFilter(DossierEntity d) {
    return switch (_filtre) {
      _ViewFilter.all      => true,
      _ViewFilter.demandes => d.statut == DossierStatut.en_attente,
      _ViewFilter.enCours  => d.statut == DossierStatut.en_cours,
      _ViewFilter.urgent   => d.statut == DossierStatut.urgent,
      _ViewFilter.resolu   => d.statut == DossierStatut.resolu,
    };
  }

  bool _matchesQuery(DossierEntity d) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return d.titre.toLowerCase().contains(q) ||
        d.numero.toLowerCase().contains(q) ||
        d.categorie.toLowerCase().contains(q);
  }

  List<DossierEntity> get _filteredDemandes => _mockDemandes
      .where((d) => _matchesFilter(d) && _matchesQuery(d))
      .toList();

  List<DossierEntity> get _filteredDossiers => _mockDossiers
      .where((d) => _matchesFilter(d) && _matchesQuery(d))
      .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urgents = _mockDossiers.where((d) => d.statut == DossierStatut.urgent).length;

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _DossiersHeader(
            demandesCount: _mockDemandes.length,
            dossiersCount: _mockDossiers.length,
            urgentsCount: urgents,
            onNew: () => context.go('/new-dossier'),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: _SearchBar(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: _FilterChips(
                    selected: _filtre,
                    onSelected: (f) => setState(() => _filtre = f),
                  ),
                ),

                // ── Demandes section ──────────────────────────────────────
                if (_filtre == _ViewFilter.all || _filtre == _ViewFilter.demandes) ...[
                  if (_filteredDemandes.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.pending_actions_rounded,
                      label: 'Mes demandes',
                      subtitle: 'En attente d\'assignation',
                      count: _filteredDemandes.length,
                      accentColor: AppColors.grisMid,
                      bgColor: const Color(0xFFF4F4F4),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _DemandeCard(demande: _filteredDemandes[i]),
                          childCount: _filteredDemandes.length,
                        ),
                      ),
                    ),
                    // Lifecycle arrow between sections
                    if (_filteredDossiers.isNotEmpty)
                      const SliverToBoxAdapter(child: _LifecycleArrow()),
                  ],
                ],

                // ── Dossiers section ──────────────────────────────────────
                if (_filtre != _ViewFilter.demandes) ...[
                  if (_filteredDossiers.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.folder_copy_rounded,
                      label: 'Mes dossiers',
                      subtitle: 'Pris en charge par un spécialiste',
                      count: _filteredDossiers.length,
                      accentColor: AppColors.bleuNuit,
                      bgColor: const Color(0xFFEEF2FF),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _DossierCard(dossier: _filteredDossiers[i]),
                          childCount: _filteredDossiers.length,
                        ),
                      ),
                    ),
                  ],
                ],

                // Empty state
                if (_filteredDemandes.isEmpty && _filteredDossiers.isEmpty)
                  const SliverFillRemaining(child: _EmptyState()),

                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/new-dossier'),
        backgroundColor: AppColors.bleuNuit,
        icon: const Icon(Icons.add_rounded, color: AppColors.orPale),
        label: const Text('Nouvelle demande',
            style: TextStyle(
              fontFamily: 'GoogleSans',
              fontWeight: FontWeight.w700,
              color: AppColors.orPale,
              fontSize: 16,
            )),
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.dossiers),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _DossiersHeader extends StatelessWidget {
  const _DossiersHeader({
    required this.demandesCount,
    required this.dossiersCount,
    required this.urgentsCount,
    required this.onNew,
  });
  final int demandesCount, dossiersCount, urgentsCount;
  final VoidCallback onNew;

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
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Mes Dossiers',
                        style: AppTextStyles.h2.copyWith(color: AppColors.blanc)),
                  ),
                  GestureDetector(
                    onTap: onNew,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [AppColors.ombreOr],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: AppColors.blanc, size: 16),
                          SizedBox(width: 4),
                          Text('Nouvelle demande',
                              style: TextStyle(
                                fontFamily: 'GoogleSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blanc,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Stats row: demandes | dossiers | urgents
              Row(
                children: [
                  _HeaderStat(
                    value: '$demandesCount',
                    label: 'En attente',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFFFE082),
                  ),
                  _HeaderDivider(),
                  _HeaderStat(
                    value: '$dossiersCount',
                    label: 'Dossiers actifs',
                    icon: Icons.folder_copy_rounded,
                    color: const Color(0xFF90CAF9),
                  ),
                  _HeaderDivider(),
                  _HeaderStat(
                    value: '$urgentsCount',
                    label: 'Urgents',
                    icon: Icons.priority_high_rounded,
                    color: const Color(0xFFEF9A9A),
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

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value, label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  )),
              Text(label,
                  style: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 11,
                    color: Color(0x99FFFFFF),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 32,
      color: const Color(0x33FFFFFF),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodySm.copyWith(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Rechercher par titre, numéro, catégorie...',
          hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.grisLight),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grisLight, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ── Filter chips ───────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});
  final _ViewFilter selected;
  final ValueChanged<_ViewFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = <(String, _ViewFilter, Color, IconData)>[
      ('Tous',       _ViewFilter.all,      AppColors.bleuNuit, Icons.apps_rounded),
      ('Demandes',   _ViewFilter.demandes, AppColors.grisMid,  Icons.pending_actions_rounded),
      ('En cours',   _ViewFilter.enCours,  AppColors.or,       Icons.play_circle_outline_rounded),
      ('Urgents',    _ViewFilter.urgent,   AppColors.rouge,    Icons.priority_high_rounded),
      ('Résolus',    _ViewFilter.resolu,   AppColors.emeraude, Icons.check_circle_outline_rounded),
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: filters.length,
        separatorBuilder: (context, idx) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, filter, color, icon) = filters[i];
          final isActive = selected == filter;
          return GestureDetector(
            onTap: () => onSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? color : AppColors.blanc,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? color : const Color(0x1A000000)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14,
                      color: isActive ? AppColors.blanc : AppColors.grisMid),
                  const SizedBox(width: 5),
                  Text(label,
                      style: TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? AppColors.blanc : AppColors.grisMid,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.count,
    required this.accentColor,
    required this.bgColor,
  });
  final IconData icon;
  final String label, subtitle;
  final int count;
  final Color accentColor, bgColor;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTextStyles.h3.copyWith(
                          color: accentColor, fontSize: 16)),
                    Text(subtitle,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 12,
                          color: AppColors.grisMid,
                        )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$count',
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.blanc,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Lifecycle arrow (between demandes and dossiers) ────────────────────────────

class _LifecycleArrow extends StatelessWidget {
  const _LifecycleArrow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 1, height: 16, color: AppColors.grisLight),
        ],
      ),
    );
  }
}

// ── Demande card (pending — no specialist yet) ─────────────────────────────────

class _DemandeCard extends StatelessWidget {
  const _DemandeCard({required this.demande});
  final DossierEntity demande;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x1A000000)),
        boxShadow: const [
          BoxShadow(color: Color(0x07000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Pending banner at the top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_top_rounded,
                    size: 14, color: AppColors.grisMid),
                const SizedBox(width: 6),
                const Text('En attente d\'assignation',
                    style: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grisMid,
                    )),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number + date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(demande.numero,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grisMid,
                          letterSpacing: 0.5,
                        )),
                    Text('Déposée le ${_fmt(demande.dateCreation)}',
                        style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 12,
                          color: AppColors.grisLight,
                        )),
                  ],
                ),
                const SizedBox(height: 6),

                Text(demande.titre,
                    style: AppTextStyles.h3.copyWith(fontSize: 18)),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: [
                    _Tag(label: demande.categorie,
                        color: AppColors.bleuMid, bg: const Color(0xFFE8F0FE)),
                    if (demande.region != null)
                      _Tag(label: demande.region!,
                          color: AppColors.grisMid, bg: const Color(0xFFF0F0F0)),
                  ],
                ),

                const SizedBox(height: 14),

                // Info text
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x0A000000)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.grisLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Un spécialiste vous sera assigné prochainement.',
                          style: AppTextStyles.bodySm.copyWith(
                            fontSize: 13,
                            color: AppColors.grisMid,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Suivre ma demande'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grisMid,
                      side: const BorderSide(color: Color(0x33000000)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Dossier card (assigned — has specialist) ───────────────────────────────────

class _DossierCard extends StatelessWidget {
  const _DossierCard({required this.dossier});
  final DossierEntity dossier;

  Color get _borderColor => switch (dossier.statut) {
    DossierStatut.urgent     => AppColors.rouge,
    DossierStatut.resolu     => AppColors.emeraude,
    DossierStatut.rejete     => AppColors.rouge,
    _                        => AppColors.or,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: _borderColor, width: 4)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: number + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dossier.numero,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orDark,
                      letterSpacing: 0.5,
                    )),
                Text(_fmt(dossier.dateCreation),
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      color: AppColors.grisMid,
                    )),
              ],
            ),
            const SizedBox(height: 6),

            Text(dossier.titre, style: AppTextStyles.h3.copyWith(fontSize: 18)),
            const SizedBox(height: 8),

            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                _Tag(label: dossier.categorie,
                    color: AppColors.bleuMid, bg: const Color(0xFFE8F0FE)),
                if (dossier.region != null)
                  _Tag(label: dossier.region!,
                      color: AppColors.grisMid, bg: const Color(0xFFF0F0F0)),
                _StatusTag(statut: dossier.statut),
              ],
            ),

            // Specialist info
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bleuNuit.withAlpha(8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.bleuNuit.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        size: 18, color: AppColors.bleuNuit),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dossier.specialisteNom ?? '',
                            style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bleuNuit,
                            )),
                        if (dossier.specialisteRole != null)
                          Text(dossier.specialisteRole!,
                              style: const TextStyle(
                                fontFamily: 'GoogleSans',
                                fontSize: 12,
                                color: AppColors.grisMid,
                              )),
                      ],
                    ),
                  ),
                  Text('Spécialiste assigné',
                      style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 11,
                        color: AppColors.emeraude,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _borderColor.withAlpha(120)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text('Voir le dossier',
                    style: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _borderColor,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Status tag ─────────────────────────────────────────────────────────────────

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.statut});
  final DossierStatut statut;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (statut) {
      DossierStatut.urgent     => ('Urgent',     AppColors.rouge,    AppColors.rougeLight),
      DossierStatut.en_cours   => ('En cours',   AppColors.orDark,   AppColors.orLight),
      DossierStatut.resolu     => ('Résolu',     AppColors.emeraude, AppColors.emeraudeLight),
      DossierStatut.en_attente => ('En attente', AppColors.grisMid,  const Color(0xFFF0F0F0)),
      DossierStatut.rejete     => ('Rejeté',     AppColors.rouge,    AppColors.rougeLight),
    };
    return _Tag(label: label, color: color, bg: bg, bold: true);
  }
}

// ── Generic tag ────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.bg,
    this.bold = false,
  });
  final String label;
  final Color color, bg;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
            fontFamily: 'GoogleSans',
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color,
          )),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppColors.orLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.folder_open_rounded,
                size: 46, color: AppColors.or),
          ),
          const SizedBox(height: 24),
          Text('Aucun résultat', style: AppTextStyles.h3.copyWith(fontSize: 20)),
          const SizedBox(height: 10),
          Text(
            'Soumettez votre première demande\nd\'assistance juridique.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}
