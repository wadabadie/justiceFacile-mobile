import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';

// ─── Modèle ───────────────────────────────────────────────────────────────────

enum _Role { juriste, psychologue, ong, autre }

class _Specialist {
  const _Specialist({
    required this.id,
    required this.nom,
    required this.role,
    required this.roleDisplay,
    this.telephone,
  });

  final int id;
  final String nom;
  final _Role role;
  final String roleDisplay;
  final String? telephone;

  factory _Specialist.fromJson(Map<String, dynamic> json) {
    final roleRaw = (json['role_display'] as String? ?? '').toLowerCase();
    _Role role;
    if (roleRaw.contains('juriste')) {
      role = _Role.juriste;
    } else if (roleRaw.contains('psycho')) {
      role = _Role.psychologue;
    } else if (roleRaw.contains('ong')) {
      role = _Role.ong;
    } else {
      role = _Role.autre;
    }

    final firstName  = json['first_name'] as String? ?? '';
    final lastName   = json['last_name']  as String? ?? '';
    final nomStruct  = json['nom_structure'] as String?;

    String nom;
    if (role == _Role.ong && nomStruct != null && nomStruct.isNotEmpty) {
      nom = nomStruct;
    } else if (role == _Role.psychologue) {
      nom = 'Dr. $firstName $lastName'.trim();
    } else {
      nom = 'Me. $firstName $lastName'.trim();
    }

    return _Specialist(
      id:          json['id'] as int,
      nom:         nom,
      role:        role,
      roleDisplay: json['role_display'] as String? ?? '',
      telephone:   json['telephone'] as String?,
    );
  }
}

// ─── Couleurs par rôle ────────────────────────────────────────────────────────

Color _roleColor(_Role r) => switch (r) {
  _Role.juriste     => AppColors.bleuMid,
  _Role.psychologue => AppColors.emeraude,
  _Role.ong         => AppColors.or,
  _Role.autre       => AppColors.grisMid,
};

Color _roleBg(_Role r) => switch (r) {
  _Role.juriste     => const Color(0xFFE8F0FE),
  _Role.psychologue => AppColors.emeraudeLight,
  _Role.ong         => AppColors.orLight,
  _Role.autre       => const Color(0xFFF0F0F0),
};

IconData _roleIcon(_Role r) => switch (r) {
  _Role.juriste     => Icons.gavel_rounded,
  _Role.psychologue => Icons.psychology_rounded,
  _Role.ong         => Icons.people_rounded,
  _Role.autre       => Icons.person_rounded,
};

String _roleLabel(_Role r) => switch (r) {
  _Role.juriste     => 'Juriste',
  _Role.psychologue => 'Psychologue',
  _Role.ong         => 'ONG',
  _Role.autre       => 'Expert',
};

// ─── Écran ────────────────────────────────────────────────────────────────────

class JuristesScreen extends StatefulWidget {
  const JuristesScreen({super.key});

  @override
  State<JuristesScreen> createState() => _JuristesScreenState();
}

class _JuristesScreenState extends State<JuristesScreen> {
  List<_Specialist> _specialists = [];
  bool _loading = true;
  String? _error;

  String _query = '';
  _Role? _roleFilter;
  final _searchCtrl = TextEditingController();

  // Id du spécialiste en cours de chargement (pour afficher le spinner sur sa carte).
  int? _contactingId;

  List<_Specialist> get _filtered => _specialists.where((s) {
    final q = _query.toLowerCase();
    final matchesQ = q.isEmpty ||
        s.nom.toLowerCase().contains(q) ||
        s.roleDisplay.toLowerCase().contains(q) ||
        (s.telephone?.contains(q) ?? false);
    final matchesRole = _roleFilter == null || s.role == _roleFilter;
    return matchesQ && matchesRole;
  }).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.instance.get(ApiConstants.specialistes);
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _specialists = list
            .map((e) => _Specialist.fromJson(e as Map<String, dynamic>))
            .toList();
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Cherche un dossier actif avec ce spécialiste, et ouvre le chat si trouvé.
  Future<void> _onContact(_Specialist specialist) async {
    setState(() => _contactingId = specialist.id);
    try {
      final res = await ApiService.instance.get(ApiConstants.dossiers);
      final dossiers = res.data as List<dynamic>;

      for (final d in dossiers) {
        final canal = _matchCanal(d as Map<String, dynamic>, specialist);
        if (canal != null) {
          if (!mounted) return;
          context.go('/chat', extra: {
            'dossierId':   d['id'] as int,
            'canal':       canal,
            'contactName': specialist.nom,
          });
          return;
        }
      }

      // Aucun dossier avec ce spécialiste.
      if (!mounted) return;
      _showNoDossierSheet(specialist);
    } catch (_) {
      if (!mounted) return;
      // En cas d'erreur réseau, redirige vers la messagerie.
      context.go('/messagerie');
    } finally {
      if (mounted) setState(() => _contactingId = null);
    }
  }

  // Retourne le canal si ce dossier est assigné à ce spécialiste, sinon null.
  String? _matchCanal(Map<String, dynamic> dossier, _Specialist specialist) {
    final nomJuriste = dossier['nom_juriste']     as String? ?? '';
    final nomPsy     = dossier['nom_psychologue'] as String? ?? '';
    final nomOng     = dossier['nom_ong']         as String? ?? '';

    if (specialist.role == _Role.juriste     && nomJuriste == specialist.nom) return 'juriste';
    if (specialist.role == _Role.psychologue && nomPsy     == specialist.nom) return 'psychologue';
    if (specialist.role == _Role.ong         && nomOng     == specialist.nom) return 'ong';
    return null;
  }

  void _showNoDossierSheet(_Specialist specialist) {
    final s = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.grisLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: 62, height: 62,
              decoration: BoxDecoration(
                color: AppColors.bleuNuit.withAlpha(18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum_outlined, size: 30, color: AppColors.bleuNuit),
            ),
            const SizedBox(height: 14),
            Text('${s.juristesContact} ${specialist.nom}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 18,
                    fontWeight: FontWeight.w700, color: AppColors.bleuNuit)),
            const SizedBox(height: 10),
            Text(
              s.juristesNoDossierMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 14,
                  color: AppColors.grisMid, height: 1.6),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () { Navigator.pop(ctx); context.go('/new-dossier'); },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(s.juristesNoDossierCreate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleuNuit,
                  foregroundColor: AppColors.blanc,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () { Navigator.pop(ctx); context.go('/dossiers'); },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.bleuNuit,
                  side: const BorderSide(color: AppColors.bleuNuit),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 15, fontWeight: FontWeight.w700),
                ),
                child: Text(s.juristesNoDossierView),
              ),
            ),
          ],
        ),
      ),
    );
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
          if (!_loading && _error == null)
            _FiltersBar(
              roleFilter: _roleFilter,
              onRole: (r) => setState(() => _roleFilter = _roleFilter == r ? null : r),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final s = AppStrings.of(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.grisLight),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.grisMid)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(s.btnRetry),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleuNuit, foregroundColor: AppColors.blanc),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) return const _EmptyState();

    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _SpecialistCard(
          specialist:   _filtered[i],
          isContacting: _contactingId == _filtered[i].id,
          onContact:    () => _onContact(_filtered[i]),
        ),
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
    final s = AppStrings.of(context);
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
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.blanc, size: 18),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.juristesSubtitle,
                          style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 11,
                              fontWeight: FontWeight.w700, color: Color(0xA0FFFFFF),
                              letterSpacing: 2.5)),
                      Text(s.juristesTitle,
                          style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 24,
                              fontWeight: FontWeight.w700, color: AppColors.blanc)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.grisMid, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: onSearch,
                        cursorColor: AppColors.bleuNuit,
                        style: const TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 16, color: AppColors.gris),
                        decoration: InputDecoration(
                          hintText: s.juristesSearch,
                          hintStyle: const TextStyle(fontFamily: 'GoogleSans', fontSize: 16,
                              color: AppColors.grisMid),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 13),
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
  const _FiltersBar({required this.roleFilter, required this.onRole});
  final _Role? roleFilter;
  final ValueChanged<_Role> onRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blanc,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [_Role.juriste, _Role.psychologue, _Role.ong].map((r) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: _roleLabel(r),
              icon: _roleIcon(r),
              active: roleFilter == r,
              activeColor: _roleColor(r),
              onTap: () => onRole(r),
            ),
          )).toList(),
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
  const _SpecialistCard({
    required this.specialist,
    required this.onContact,
    required this.isContacting,
  });
  final _Specialist specialist;
  final VoidCallback onContact;
  final bool isContacting;

  String get _initials {
    final parts = specialist.nom
        .replaceAll(RegExp(r'^(Me\.|Dr\.)'), '')
        .trim()
        .split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final str   = AppStrings.of(context);
    final s     = specialist;
    final color = _roleColor(s.role);
    final bg    = _roleBg(s.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.nom, style: AppTextStyles.h3.copyWith(fontSize: 17)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_roleIcon(s.role), size: 12, color: color),
                            const SizedBox(width: 4),
                            Text(s.roleDisplay,
                                style: TextStyle(fontFamily: 'GoogleSans', fontSize: 12,
                                    fontWeight: FontWeight.w700, color: color)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emeraudeLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 12, color: AppColors.emeraude),
                      const SizedBox(width: 4),
                      Text(str.juristesCertified,
                          style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 11,
                              fontWeight: FontWeight.w700, color: AppColors.emeraude)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0x0F000000), height: 1),
            const SizedBox(height: 12),
            if (s.telephone != null && s.telephone!.isNotEmpty)
              _InfoChip(
                icon: Icons.phone_rounded,
                label: s.telephone!,
                color: AppColors.grisMid,
                bg: const Color(0xFFF0F0F0),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isContacting ? null : onContact,
                icon: isContacting
                    ? SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: AppColors.blanc, strokeWidth: 2),
                      )
                    : const Icon(Icons.forum_rounded, size: 18),
                label: Text(str.juristesContact),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: AppColors.blanc,
                  disabledBackgroundColor: color.withAlpha(140),
                  disabledForegroundColor: AppColors.blanc,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 15, fontWeight: FontWeight.w700),
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
    final s = AppStrings.of(context);
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
          Text(s.juristesEmpty, style: AppTextStyles.h3.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text(s.juristesEmptyDesc,
              style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15, color: AppColors.grisMid)),
        ],
      ),
    );
  }
}
