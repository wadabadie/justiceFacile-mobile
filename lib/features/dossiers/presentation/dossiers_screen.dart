import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../domain/entities/dossier_entity.dart';

// Mock data — replace with API call to GET /api/v1/dossiers/ when backend is ready
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

class DossiersScreen extends StatefulWidget {
  const DossiersScreen({super.key});

  @override
  State<DossiersScreen> createState() => _DossiersScreenState();
}

class _DossiersScreenState extends State<DossiersScreen> {
  final _searchCtrl = TextEditingController();
  DossierStatut? _filtre; // null = Tous
  String _query = '';

  List<DossierEntity> get _filtered {
    return _mockDossiers.where((d) {
      final matchFilter = _filtre == null || d.statut == _filtre;
      final matchQuery  = _query.isEmpty ||
          d.titre.toLowerCase().contains(_query.toLowerCase()) ||
          d.numero.toLowerCase().contains(_query.toLowerCase()) ||
          d.categorie.toLowerCase().contains(_query.toLowerCase());
      return matchFilter && matchQuery;
    }).toList();
  }

  List<DossierEntity> get _demandes =>
      _filtered.where((d) => d.statut == DossierStatut.en_attente).toList();

  List<DossierEntity> get _dossiers =>
      _filtered.where((d) => d.statut != DossierStatut.en_attente).toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total   = _mockDossiers.length;
    final urgents = _mockDossiers.where((d) => d.statut == DossierStatut.urgent).length;

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _DossiersHeader(
            total: total,
            urgents: urgents,
            onNew: () => context.go('/new-dossier'),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: _SearchBar(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ),

                // Filter chips
                SliverToBoxAdapter(
                  child: _FilterChips(
                    selected: _filtre,
                    onSelected: (f) => setState(() => _filtre = f),
                  ),
                ),

                // Demandes section
                if (_demandes.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Mes demandes',
                    count: _demandes.length,
                    color: AppColors.grisMid,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _DossierCard(dossier: _demandes[i]),
                        childCount: _demandes.length,
                      ),
                    ),
                  ),
                ],

                // Dossiers section
                if (_dossiers.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Mes dossiers',
                    count: _dossiers.length,
                    color: AppColors.bleuNuit,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _DossierCard(dossier: _dossiers[i]),
                        childCount: _dossiers.length,
                      ),
                    ),
                  ),
                ],

                // Empty state
                if (_demandes.isEmpty && _dossiers.isEmpty)
                  const SliverFillRemaining(child: _EmptyState()),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/new-dossier'),
        backgroundColor: AppColors.bleuNuit,
        icon: const Icon(Icons.add_rounded, color: AppColors.orPale),
        label: const Text('Nouveau',
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

// ── Header ────────────────────────────────────────────────────────────────────

class _DossiersHeader extends StatelessWidget {
  const _DossiersHeader({
    required this.total,
    required this.urgents,
    required this.onNew,
  });
  final int total, urgents;
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
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mes Dossiers', style: AppTextStyles.h2.copyWith(color: AppColors.blanc)),
                    const SizedBox(height: 3),
                    Text(
                      '$total dossiers · $urgents urgent${urgents > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 14,
                        color: Color(0x80FFFFFF),
                      ),
                    ),
                  ],
                ),
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
                      Text('Nouveau',
                          style: TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blanc,
                          )),
                    ],
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

// ── Search bar ────────────────────────────────────────────────────────────────

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
          hintText: 'Rechercher un dossier...',
          hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.grisLight),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grisLight, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});
  final DossierStatut? selected;
  final ValueChanged<DossierStatut?> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = <(String, DossierStatut?, Color)>[
      ('Tous',       null,                      AppColors.bleuNuit),
      ('Urgent',     DossierStatut.urgent,       AppColors.rouge),
      ('En cours',   DossierStatut.en_cours,     AppColors.or),
      ('Résolu',     DossierStatut.resolu,       AppColors.emeraude),
      ('En attente', DossierStatut.en_attente,   AppColors.grisMid),
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: filters.length,
        separatorBuilder: (context, idx) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, statut, color) = filters[i];
          final isActive = selected == statut;
          return GestureDetector(
            onTap: () => onSelected(statut),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? color : AppColors.blanc,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? color : const Color(0x1A000000),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.blanc : AppColors.grisMid,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Row(
          children: [
            Text(label,
                style: AppTextStyles.h3.copyWith(color: color, fontSize: 18)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dossier card ──────────────────────────────────────────────────────────────

class _DossierCard extends StatelessWidget {
  const _DossierCard({required this.dossier});
  final DossierEntity dossier;

  Color get _borderColor {
    switch (dossier.statut) {
      case DossierStatut.urgent:     return AppColors.rouge;
      case DossierStatut.resolu:     return AppColors.emeraude;
      case DossierStatut.en_attente: return AppColors.grisLight;
      default:                       return AppColors.or;
    }
  }

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
                Text(_formatDate(dossier.dateCreation),
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      color: AppColors.grisMid,
                    )),
              ],
            ),
            const SizedBox(height: 6),

            // Title
            Text(dossier.titre,
                style: AppTextStyles.h3.copyWith(fontSize: 18)),
            const SizedBox(height: 8),

            // Tags row: category + region + status
            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                _Tag(label: dossier.categorie, color: AppColors.bleuMid, bg: const Color(0xFFE8F0FE)),
                if (dossier.region != null)
                  _Tag(label: dossier.region!, color: AppColors.grisMid, bg: const Color(0xFFF0F0F0)),
                _StatusTag(statut: dossier.statut),
              ],
            ),

            // Specialist row
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.grisMid),
                const SizedBox(width: 6),
                Text(
                  dossier.specialisteNom ?? 'En attente d\'assignation',
                  style: AppTextStyles.bodySm.copyWith(
                    fontSize: 14,
                    color: dossier.isAssigned ? AppColors.gris : AppColors.grisLight,
                    fontStyle: dossier.isAssigned ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            // Action button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _borderColor.withAlpha(100)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Status tag ────────────────────────────────────────────────────────────────

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

// ── Generic tag ───────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, required this.bg, this.bold = false});
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

// ── Empty state ───────────────────────────────────────────────────────────────

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
            child: const Icon(Icons.folder_open_rounded, size: 46, color: AppColors.or),
          ),
          const SizedBox(height: 24),
          Text('Aucun dossier trouvé',
              style: AppTextStyles.h3.copyWith(fontSize: 20)),
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
