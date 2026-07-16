import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

// ─── Modèle ───────────────────────────────────────────────────────────────────

enum _Role { juriste, psychologue, ong }

class _Specialist {
  const _Specialist({
    required this.nom,
    required this.role,
    required this.specialite,
    required this.region,
    required this.disponible,
    this.experience,
    this.dossiers = 0,
  });
  final String nom, specialite, region;
  final _Role role;
  final bool disponible;
  final String? experience;
  final int dossiers;
}

const _specialists = [
  _Specialist(
    nom: 'Me. Jean-Baptiste Fotso',
    role: _Role.juriste,
    specialite: 'Droit du travail',
    region: 'Yaoundé',
    disponible: true,
    experience: '12 ans',
    dossiers: 48,
  ),
  _Specialist(
    nom: 'Me. Rose Ateba',
    role: _Role.juriste,
    specialite: 'Droit de la famille',
    region: 'Douala',
    disponible: false,
    experience: '8 ans',
    dossiers: 31,
  ),
  _Specialist(
    nom: 'Dr. Pauline Ngo',
    role: _Role.psychologue,
    specialite: 'Accompagnement VBG',
    region: 'Bafoussam',
    disponible: true,
    experience: '10 ans',
    dossiers: 62,
  ),
  _Specialist(
    nom: 'Me. André Mbarga',
    role: _Role.juriste,
    specialite: 'Droit pénal',
    region: 'Yaoundé',
    disponible: true,
    experience: '15 ans',
    dossiers: 89,
  ),
  _Specialist(
    nom: 'CIPCRE Cameroun',
    role: _Role.ong,
    specialite: 'Protection VBG',
    region: 'Bafoussam',
    disponible: true,
    dossiers: 204,
  ),
  _Specialist(
    nom: 'Me. Clarisse Owona',
    role: _Role.juriste,
    specialite: 'Droit civil',
    region: 'Douala',
    disponible: false,
    experience: '6 ans',
    dossiers: 27,
  ),
  _Specialist(
    nom: 'Dr. Simon Tchuente',
    role: _Role.psychologue,
    specialite: 'Trauma & Résilience',
    region: 'Yaoundé',
    disponible: true,
    experience: '9 ans',
    dossiers: 43,
  ),
  _Specialist(
    nom: 'Association ALVF',
    role: _Role.ong,
    specialite: 'Lutte contre les VBG',
    region: 'Douala',
    disponible: true,
    dossiers: 156,
  ),
];

// ─── Couleurs par rôle ────────────────────────────────────────────────────────

Color _roleColor(_Role r) => switch (r) {
  _Role.juriste     => AppColors.bleuMid,
  _Role.psychologue => AppColors.emeraude,
  _Role.ong         => AppColors.or,
};

Color _roleBg(_Role r) => switch (r) {
  _Role.juriste     => const Color(0xFFE8F0FE),
  _Role.psychologue => AppColors.emeraudeLight,
  _Role.ong         => AppColors.orLight,
};

String _roleLabel(_Role r) => switch (r) {
  _Role.juriste     => 'Juriste',
  _Role.psychologue => 'Psychologue',
  _Role.ong         => 'ONG',
};

IconData _roleIcon(_Role r) => switch (r) {
  _Role.juriste     => Icons.gavel_rounded,
  _Role.psychologue => Icons.psychology_rounded,
  _Role.ong         => Icons.people_rounded,
};

// ─── Écran ────────────────────────────────────────────────────────────────────

class JuristesScreen extends StatefulWidget {
  const JuristesScreen({super.key});

  @override
  State<JuristesScreen> createState() => _JuristesScreenState();
}

class _JuristesScreenState extends State<JuristesScreen> {
  String _query = '';
  _Role? _roleFilter;
  bool _dispOnlyFilter = false;
  final _searchCtrl = TextEditingController();

  List<_Specialist> get _filtered => _specialists.where((s) {
    final q = _query.toLowerCase();
    final matchesQ = q.isEmpty ||
        s.nom.toLowerCase().contains(q) ||
        s.specialite.toLowerCase().contains(q) ||
        s.region.toLowerCase().contains(q);
    final matchesRole = _roleFilter == null || s.role == _roleFilter;
    final matchesDisp = !_dispOnlyFilter || s.disponible;
    return matchesQ && matchesRole && matchesDisp;
  }).toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _JuristesHeader(
            searchCtrl: _searchCtrl,
            onSearch: (v) => setState(() => _query = v),
            onBack: () => context.go('/home'),
          ),
          _FiltersBar(
            roleFilter: _roleFilter,
            dispOnly: _dispOnlyFilter,
            onRole: (r) => setState(() => _roleFilter = _roleFilter == r ? null : r),
            onDisp: () => setState(() => _dispOnlyFilter = !_dispOnlyFilter),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _SpecialistCard(
                      specialist: _filtered[i],
                      onContact: () => context.go('/messagerie'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _JuristesHeader extends StatelessWidget {
  const _JuristesHeader({
    required this.searchCtrl,
    required this.onSearch,
    required this.onBack,
  });
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final VoidCallback onBack;

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
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.blanc, size: 18),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.gavel_rounded, color: AppColors.blanc, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RÉSEAU DE SPÉCIALISTES',
                          style: TextStyle(fontFamily: 'GoogleSans', fontSize: 11,
                              fontWeight: FontWeight.w700, color: Color(0xA0FFFFFF), letterSpacing: 2.5)),
                      Text('Juristes & Experts',
                          style: TextStyle(fontFamily: 'GoogleSans', fontSize: 24,
                              fontWeight: FontWeight.w700, color: AppColors.blanc)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(22),
                  border: Border.all(color: Colors.white.withAlpha(40)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0x80FFFFFF), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: onSearch,
                        style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 16, color: AppColors.blanc),
                        decoration: const InputDecoration(
                          hintText: 'Nom, spécialité, ville...',
                          hintStyle: TextStyle(fontFamily: 'GoogleSans', fontSize: 16, color: Color(0x60FFFFFF)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
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

// ─── Filtres ──────────────────────────────────────────────────────────────────

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.roleFilter,
    required this.dispOnly,
    required this.onRole,
    required this.onDisp,
  });
  final _Role? roleFilter;
  final bool dispOnly;
  final ValueChanged<_Role> onRole;
  final VoidCallback onDisp;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blanc,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            ..._Role.values.map((r) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: _roleLabel(r),
                icon: _roleIcon(r),
                active: roleFilter == r,
                activeColor: _roleColor(r),
                onTap: () => onRole(r),
              ),
            )),
            _FilterChip(
              label: 'Disponible',
              icon: Icons.circle,
              active: dispOnly,
              activeColor: AppColors.emeraude,
              onTap: onDisp,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? activeColor : AppColors.fond2,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? AppColors.blanc : AppColors.grisMid),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppColors.blanc : AppColors.grisMid,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Carte spécialiste ────────────────────────────────────────────────────────

class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard({required this.specialist, required this.onContact});
  final _Specialist specialist;
  final VoidCallback onContact;

  String get _initials {
    final parts = specialist.nom.replaceAll(RegExp(r'^(Me\.|Dr\.)'), '').trim().split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final s = specialist;
    final color = _roleColor(s.role);
    final bg = _roleBg(s.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withAlpha(200), color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(_initials,
                            style: const TextStyle(
                              fontFamily: 'GoogleSans', fontSize: 20,
                              fontWeight: FontWeight.w700, color: AppColors.blanc,
                            )),
                      ),
                    ),
                    Positioned(
                      bottom: 2, right: 2,
                      child: Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          color: s.disponible ? AppColors.emeraude : AppColors.grisMid,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.blanc, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.nom, style: AppTextStyles.h3.copyWith(fontSize: 17)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_roleIcon(s.role), size: 12, color: color),
                                const SizedBox(width: 4),
                                Text(_roleLabel(s.role),
                                    style: TextStyle(fontFamily: 'GoogleSans', fontSize: 12,
                                        fontWeight: FontWeight.w700, color: color)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.disponible ? '● Disponible' : '● Occupé',
                            style: TextStyle(
                              fontFamily: 'GoogleSans', fontSize: 12, fontWeight: FontWeight.w600,
                              color: s.disponible ? AppColors.emeraude : AppColors.grisMid,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0x0F000000), height: 1),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                _InfoChip(icon: Icons.auto_awesome_rounded, label: s.specialite, color: color, bg: bg),
                _InfoChip(icon: Icons.location_on_rounded, label: s.region,
                    color: AppColors.grisMid, bg: const Color(0xFFF0F0F0)),
                if (s.experience != null)
                  _InfoChip(icon: Icons.workspace_premium_rounded, label: s.experience!,
                      color: AppColors.or, bg: AppColors.orLight),
                _InfoChip(icon: Icons.folder_copy_rounded, label: '${s.dossiers} dossiers',
                    color: AppColors.bleuNuit, bg: const Color(0xFFEEF2FF)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: s.disponible ? onContact : null,
                icon: const Icon(Icons.forum_rounded, size: 18),
                label: Text(s.disponible ? 'Contacter' : 'Indisponible'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: s.disponible ? color : const Color(0xFFEEEEEE),
                  foregroundColor: s.disponible ? AppColors.blanc : AppColors.grisLight,
                  disabledBackgroundColor: const Color(0xFFEEEEEE),
                  disabledForegroundColor: AppColors.grisLight,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.color, required this.bg});
  final IconData icon;
  final String label;
  final Color color, bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontFamily: 'GoogleSans', fontSize: 13,
              fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}

// ─── État vide ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(color: AppColors.fond2, shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded, size: 36, color: AppColors.grisLight),
          ),
          const SizedBox(height: 20),
          Text('Aucun spécialiste trouvé', style: AppTextStyles.h3.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Modifiez vos filtres de recherche.',
              style: TextStyle(fontFamily: 'GoogleSans', fontSize: 15, color: AppColors.grisMid)),
        ],
      ),
    );
  }
}
