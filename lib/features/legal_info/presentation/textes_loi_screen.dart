import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';

// ─── Modèle ───────────────────────────────────────────────────────────────────

class _LegalText {
  const _LegalText({
    required this.id,
    required this.titre,
    required this.categorie,
    required this.categorieDisplay,
    required this.contenu,
    required this.dateAjout,
    required this.motsCles,
  });

  final int id;
  final String titre;
  final String categorie;
  final String categorieDisplay;
  final String contenu;
  final String dateAjout;
  final List<String> motsCles;

  factory _LegalText.fromJson(Map<String, dynamic> json) {
    final mots = (json['mots_cles'] as String? ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return _LegalText(
      id:              json['id'] as int,
      titre:           json['titre'] as String? ?? '',
      categorie:       json['categorie'] as String? ?? '',
      categorieDisplay: json['categorie_display'] as String? ?? json['categorie'] as String? ?? '',
      contenu:         json['contenu'] as String? ?? '',
      dateAjout:       _formatDate(json['date_ajout'] as String? ?? ''),
      motsCles:        mots,
    );
  }

  String get resume {
    final stripped = contenu.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (stripped.length <= 220) return stripped;
    return '${stripped.substring(0, 220)}…';
  }

  static String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      const months = ['jan.', 'fév.', 'mar.', 'avr.', 'mai', 'juin',
                      'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.'];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return iso.substring(0, 10);
    }
  }
}

// ─── Couleurs / icônes par catégorie ─────────────────────────────────────────

Color _catColor(String cat) => switch (cat.toLowerCase()) {
  String c when c.contains('pénal') || c.contains('penal') => AppColors.rouge,
  String c when c.contains('vbg') || c.contains('traite') => const Color(0xFF9B2335),
  String c when c.contains('travail')                      => AppColors.emeraude,
  String c when c.contains('famille') || c.contains('civil')=> AppColors.or,
  String c when c.contains('foncier') || c.contains('domanial')=> const Color(0xFF7D5A3C),
  String c when c.contains('constitution')                  => const Color(0xFF5C35C9),
  _                                                         => AppColors.bleuMid,
};

Color _catBg(String cat) => switch (cat.toLowerCase()) {
  String c when c.contains('pénal') || c.contains('penal') => AppColors.rougeLight,
  String c when c.contains('vbg') || c.contains('traite') => const Color(0xFFFDE8EA),
  String c when c.contains('travail')                      => AppColors.emeraudeLight,
  String c when c.contains('famille') || c.contains('civil')=> AppColors.orLight,
  String c when c.contains('foncier') || c.contains('domanial')=> const Color(0xFFF5EDE4),
  String c when c.contains('constitution')                  => const Color(0xFFEDE8FA),
  _                                                         => const Color(0xFFE8F0FE),
};

IconData _catIcon(String cat) => switch (cat.toLowerCase()) {
  String c when c.contains('pénal') || c.contains('penal') => Icons.gavel_rounded,
  String c when c.contains('vbg')                          => Icons.shield_rounded,
  String c when c.contains('travail')                      => Icons.work_rounded,
  String c when c.contains('famille')                      => Icons.family_restroom_rounded,
  String c when c.contains('civil')                        => Icons.balance_rounded,
  String c when c.contains('foncier')                      => Icons.terrain_rounded,
  String c when c.contains('constitution')                  => Icons.account_balance_rounded,
  _                                                         => Icons.menu_book_rounded,
};

// ─── Écran principal ──────────────────────────────────────────────────────────

class TextesLoiScreen extends StatefulWidget {
  const TextesLoiScreen({super.key});

  @override
  State<TextesLoiScreen> createState() => _TextesLoiScreenState();
}

class _TextesLoiScreenState extends State<TextesLoiScreen> {
  List<_LegalText> _textes = [];
  bool _loading = true;
  String? _error;

  String _selectedCategory = 'Tous';
  String _query = '';
  final _searchCtrl = TextEditingController();

  List<String> get _categories {
    final cats = _textes.map((t) => t.categorieDisplay).toSet().toList()..sort();
    return ['Tous', ...cats];
  }

  List<_LegalText> get _filtered => _textes.where((t) {
    final matchesCat = _selectedCategory == 'Tous' ||
        t.categorieDisplay == _selectedCategory;
    final q = _query.toLowerCase();
    final matchesQuery = q.isEmpty ||
        t.titre.toLowerCase().contains(q) ||
        t.categorieDisplay.toLowerCase().contains(q) ||
        t.motsCles.any((m) => m.toLowerCase().contains(q));
    return matchesCat && matchesQuery;
  }).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.instance.get(ApiConstants.textesLoi);
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _textes = list
            .map((e) => _LegalText.fromJson(e as Map<String, dynamic>))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _LoisHeader(
            searchCtrl: _searchCtrl,
            onSearch: (v) => setState(() => _query = v),
            onBack: () => context.go('/home'),
          ),
          if (!_loading && _error == null)
            _CategoryBar(
              categories: _categories,
              selected: _selectedCategory,
              onSelect: (c) => setState(() => _selectedCategory = c),
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

    if (_filtered.isEmpty) return _EmptyState(query: _query);

    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _LegalTextCard(text: _filtered[i]),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _LoisHeader extends StatelessWidget {
  const _LoisHeader({
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
                    child: const Icon(Icons.menu_book_rounded, color: AppColors.blanc, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.loisSubtitle,
                          style: const TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 11, fontWeight: FontWeight.w700,
                            color: Color(0xA0FFFFFF), letterSpacing: 2.5,
                          )),
                      Text(s.loisTitle,
                          style: const TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 24, fontWeight: FontWeight.w700,
                            color: AppColors.blanc,
                          )),
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
                          fontFamily: 'GoogleSans', fontSize: 16, color: AppColors.gris,
                        ),
                        decoration: InputDecoration(
                          hintText: s.loisSearch,
                          hintStyle: const TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 16, color: AppColors.grisMid,
                          ),
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

// ─── Barre de catégories ──────────────────────────────────────────────────────

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blanc,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: categories.length,
          separatorBuilder: (_, index) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = categories[i];
            final isActive = cat == selected;
            return GestureDetector(
              onTap: () => onSelect(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.bleuNuit : AppColors.fond2,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(cat,
                    style: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.orPale : AppColors.grisMid,
                    )),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Carte ────────────────────────────────────────────────────────────────────

class _LegalTextCard extends StatefulWidget {
  const _LegalTextCard({required this.text});
  final _LegalText text;

  @override
  State<_LegalTextCard> createState() => _LegalTextCardState();
}

class _LegalTextCardState extends State<_LegalTextCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s     = AppStrings.of(context);
    final t     = widget.text;
    final color = _catColor(t.categorieDisplay);
    final bg    = _catBg(t.categorieDisplay);
    final icon  = _catIcon(t.categorieDisplay);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(18),
          border: Border(left: BorderSide(color: color, width: 4)),
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
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                      child: Text(t.categorieDisplay,
                          style: TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 11, fontWeight: FontWeight.w700,
                            color: color, letterSpacing: 0.5,
                          )),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 26),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(t.titre, style: AppTextStyles.h3.copyWith(fontSize: 18)),
              const SizedBox(height: 6),
              Text(
                t.resume,
                style: AppTextStyles.bodySm.copyWith(height: 1.5),
                maxLines: _expanded ? null : 2,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _DetailSection(text: t, color: color, bg: bg),
                crossFadeState:
                    _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (t.dateAjout.isNotEmpty)
                    Row(children: [
                      Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.grisLight),
                      const SizedBox(width: 4),
                      Text(t.dateAjout,
                          style: const TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 13,
                            color: AppColors.grisLight, fontWeight: FontWeight.w500,
                          )),
                    ]),
                  Text(_expanded ? s.loisReduce : s.loisReadMore,
                      style: TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 14,
                        fontWeight: FontWeight.w700, color: color,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.text, required this.color, required this.bg});
  final _LegalText text;
  final Color color, bg;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const Divider(color: Color(0x1A000000)),
        const SizedBox(height: 10),

        if (text.motsCles.isNotEmpty) ...[
          Text(s.loisKeywords,
              style: const TextStyle(
                fontFamily: 'GoogleSans', fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.bleuNuit,
              )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: text.motsCles.map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
              child: Text(m,
                  style: TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 13,
                    fontWeight: FontWeight.w600, color: color,
                  )),
            )).toList(),
          ),
          const SizedBox(height: 14),
        ],

        Text(s.loisExcerpt,
            style: const TextStyle(
              fontFamily: 'GoogleSans', fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.bleuNuit,
            )),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg.withAlpha(120),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(30)),
          ),
          child: Text(
            text.contenu.length > 600
                ? '${text.contenu.substring(0, 600)}…'
                : text.contenu,
            style: TextStyle(
              fontFamily: 'GoogleSans', fontSize: 13,
              color: AppColors.gris, height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── État vide ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(color: AppColors.fond2, shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded, size: 36, color: AppColors.grisLight),
            ),
            const SizedBox(height: 20),
            Text(
              query.isEmpty ? s.loisEmpty : s.loisEmptyQuery(query),
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              s.loisEmptyHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'GoogleSans', fontSize: 15,
                color: AppColors.grisMid, height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
