import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

// ─── Modèle de données ────────────────────────────────────────────────────────

class _LegalText {
  const _LegalText({
    required this.reference,
    required this.title,
    required this.category,
    required this.date,
    required this.summary,
    required this.keyArticles,
  });
  final String reference, title, category, date, summary;
  final List<String> keyArticles;
}

const _categories = ['Tous', 'Droit pénal', 'Droit civil', 'Droit du travail', 'Droit de la famille', 'Droit foncier', 'Protection VBG'];

const _legalTexts = [
  _LegalText(
    reference: 'Loi n° 2016/007 du 12 juillet 2016',
    title: 'Code pénal camerounais',
    category: 'Droit pénal',
    date: '12 juil. 2016',
    summary: 'Définit les infractions pénales et les peines applicables sur le territoire camerounais. Inclut les dispositions sur les violences physiques, sexuelles et conjugales.',
    keyArticles: [
      'Art. 292 — Coups et blessures volontaires',
      'Art. 297 — Violences conjugales aggravées',
      'Art. 346 — Viol (jusqu\'à 10 ans d\'emprisonnement)',
    ],
  ),
  _LegalText(
    reference: 'Loi n° 2005/007 du 27 juillet 2005',
    title: 'Code de procédure pénale',
    category: 'Droit pénal',
    date: '27 juil. 2005',
    summary: 'Régit le déroulement des poursuites pénales, de l\'enquête au jugement. Définit les droits des victimes et des accusés.',
    keyArticles: [
      'Art. 135 — Droit de porter plainte',
      'Art. 157 — Garde à vue et droits du gardé',
      'Art. 364 — Droit des victimes à indemnisation',
    ],
  ),
  _LegalText(
    reference: 'Loi n° 2005/015 du 29 décembre 2005',
    title: 'Lutte contre la traite et le trafic de personnes',
    category: 'Protection VBG',
    date: '29 déc. 2005',
    summary: 'Incrimine la traite des personnes sous toutes ses formes et prévoit des peines sévères pour les auteurs, notamment en cas de victimes mineures.',
    keyArticles: [
      'Art. 3 — Définition de la traite des personnes',
      'Art. 4 — Peine de 10 à 20 ans pour trafic d\'enfants',
      'Art. 7 — Protection et assistance aux victimes',
    ],
  ),
  _LegalText(
    reference: 'Loi n° 92/007 du 14 août 1992',
    title: 'Code du travail camerounais',
    category: 'Droit du travail',
    date: '14 août 1992',
    summary: 'Régit les relations entre employeurs et travailleurs. Fixe les droits fondamentaux des travailleurs, le SMIG, les congés et les procédures de licenciement.',
    keyArticles: [
      'Art. 28 — Interdiction du travail forcé',
      'Art. 34 — Durée légale du travail (40h/semaine)',
      'Art. 40 — Droit au congé payé annuel',
      'Art. 67 — Conditions de licenciement',
    ],
  ),
  _LegalText(
    reference: 'Ordonnance n° 81-02 du 29 juin 1981',
    title: 'Régime applicable à l\'état civil',
    category: 'Droit de la famille',
    date: '29 juin 1981',
    summary: 'Organise l\'enregistrement des actes de l\'état civil : naissances, mariages, décès. Fixe les conditions de validité du mariage au Cameroun.',
    keyArticles: [
      'Art. 52 — Âge minimum au mariage (15 ans pour les filles)',
      'Art. 60 — Consentement obligatoire des époux',
      'Art. 74 — Prohibition du mariage forcé',
    ],
  ),
  _LegalText(
    reference: 'Loi n° 2019/021 du 24 décembre 2019',
    title: 'Protection de l\'enfant',
    category: 'Droit de la famille',
    date: '24 déc. 2019',
    summary: 'Renforce la protection des enfants contre toutes formes de maltraitance, d\'exploitation et de violation de leurs droits fondamentaux.',
    keyArticles: [
      'Art. 4 — Droit à la vie et à la santé',
      'Art. 12 — Interdiction des châtiments corporels',
      'Art. 28 — Protection contre l\'exploitation sexuelle',
    ],
  ),
  _LegalText(
    reference: 'Ordonnance n° 74-1 du 6 juillet 1974',
    title: 'Régime foncier et domanial',
    category: 'Droit foncier',
    date: '6 juil. 1974',
    summary: 'Définit le régime de propriété des terres au Cameroun. Distingue le domaine public, le domaine privé de l\'État et les terres des particuliers.',
    keyArticles: [
      'Art. 1 — Définition du domaine national',
      'Art. 8 — Procédure d\'immatriculation foncière',
      'Art. 17 — Droits des occupants traditionnels',
    ],
  ),
  _LegalText(
    reference: 'Code civil applicable au Cameroun',
    title: 'Code civil',
    category: 'Droit civil',
    date: '1804 (adapté)',
    summary: 'Régit les relations entre personnes privées : contrats, obligations, successions, régimes matrimoniaux et droits de propriété.',
    keyArticles: [
      'Art. 1101 — Définition du contrat',
      'Art. 1382 — Responsabilité civile délictuelle',
      'Art. 720 — Droits de succession',
    ],
  ),
];

// ─── Couleurs par catégorie ───────────────────────────────────────────────────

Color _catColor(String cat) => switch (cat) {
  'Droit pénal'        => AppColors.rouge,
  'Protection VBG'     => const Color(0xFF9B2335),
  'Droit du travail'   => AppColors.emeraude,
  'Droit de la famille'=> AppColors.or,
  'Droit foncier'      => const Color(0xFF7D5A3C),
  _                    => AppColors.bleuMid,
};

Color _catBg(String cat) => switch (cat) {
  'Droit pénal'        => AppColors.rougeLight,
  'Protection VBG'     => const Color(0xFFFDE8EA),
  'Droit du travail'   => AppColors.emeraudeLight,
  'Droit de la famille'=> AppColors.orLight,
  'Droit foncier'      => const Color(0xFFF5EDE4),
  _                    => const Color(0xFFE8F0FE),
};

IconData _catIcon(String cat) => switch (cat) {
  'Droit pénal'        => Icons.gavel_rounded,
  'Protection VBG'     => Icons.shield_rounded,
  'Droit du travail'   => Icons.work_rounded,
  'Droit de la famille'=> Icons.family_restroom_rounded,
  'Droit foncier'      => Icons.terrain_rounded,
  _                    => Icons.balance_rounded,
};

// ─── Écran principal ──────────────────────────────────────────────────────────

class TextesLoiScreen extends StatefulWidget {
  const TextesLoiScreen({super.key});

  @override
  State<TextesLoiScreen> createState() => _TextesLoiScreenState();
}

class _TextesLoiScreenState extends State<TextesLoiScreen> {
  String _selectedCategory = 'Tous';
  String _query = '';
  final _searchCtrl = TextEditingController();

  List<_LegalText> get _filtered {
    return _legalTexts.where((t) {
      final matchesCat = _selectedCategory == 'Tous' || t.category == _selectedCategory;
      final q = _query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.reference.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
      return matchesCat && matchesQuery;
    }).toList();
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
          _CategoryBar(
            selected: _selectedCategory,
            onSelect: (c) => setState(() => _selectedCategory = c),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? _EmptyState(query: _query)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _LegalTextCard(text: _filtered[i]),
                  ),
          ),
        ],
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
                  width: 38,
                  height: 38,
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: AppColors.blanc, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BIBLIOTHÈQUE JURIDIQUE',
                        style: TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 11, fontWeight: FontWeight.w700,
                          color: Color(0xA0FFFFFF), letterSpacing: 2.5,
                        ),
                      ),
                      Text(
                        'Textes de Loi',
                        style: TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 24, fontWeight: FontWeight.w700,
                          color: AppColors.blanc,
                        ),
                      ),
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
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 16, color: AppColors.blanc,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Rechercher une loi, un droit...',
                          hintStyle: TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 16, color: Color(0x60FFFFFF),
                          ),
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

// ─── Barre de catégories ──────────────────────────────────────────────────────

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.selected, required this.onSelect});
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
          itemCount: _categories.length,
          separatorBuilder: (_, index) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = _categories[i];
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
                child: Text(
                  cat,
                  style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? AppColors.orPale : AppColors.grisMid,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Carte de texte de loi ────────────────────────────────────────────────────

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
    final t = widget.text;
    final color = _catColor(t.category);
    final bg = _catBg(t.category);
    final icon = _catIcon(t.category);

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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t.category,
                            style: TextStyle(
                              fontFamily: 'GoogleSans', fontSize: 11, fontWeight: FontWeight.w700,
                              color: color, letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.reference,
                          style: const TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 12, fontWeight: FontWeight.w500,
                            color: AppColors.grisMid,
                          ),
                        ),
                      ],
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
              Text(t.title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
              const SizedBox(height: 6),
              Text(
                t.summary,
                style: AppTextStyles.bodySm.copyWith(height: 1.5),
                maxLines: _expanded ? null : 2,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _ArticlesSection(articles: t.keyArticles, color: color, bg: bg),
                crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.grisLight),
                      const SizedBox(width: 4),
                      Text(
                        t.date,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 13,
                          color: AppColors.grisLight, fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _expanded ? 'Réduire' : 'Voir les articles',
                    style: TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 14, fontWeight: FontWeight.w700,
                      color: color,
                    ),
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

class _ArticlesSection extends StatelessWidget {
  const _ArticlesSection({required this.articles, required this.color, required this.bg});
  final List<String> articles;
  final Color color, bg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const Divider(color: Color(0x1A000000)),
        const SizedBox(height: 10),
        const Text(
          'Articles clés',
          style: TextStyle(
            fontFamily: 'GoogleSans', fontSize: 14, fontWeight: FontWeight.w700,
            color: AppColors.bleuNuit,
          ),
        ),
        const SizedBox(height: 10),
        ...articles.map((a) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 4, height: 4,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  a,
                  style: TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 14, fontWeight: FontWeight.w500,
                    color: color, height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.fond2, shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 36, color: AppColors.grisLight),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun résultat pour "$query"',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez un autre mot-clé ou sélectionnez une autre catégorie.',
              textAlign: TextAlign.center,
              style: TextStyle(
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
