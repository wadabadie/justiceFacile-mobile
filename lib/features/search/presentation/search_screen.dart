import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchItem {
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final String route;

  const _SearchItem({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.route,
  });
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;

  List<_SearchItem> _results = [];
  bool _loading  = false;
  bool _searched = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    final q = _ctrl.text.trim();
    if (q == _lastQuery) return;
    _lastQuery = q;
    _debounce?.cancel();
    if (q.isEmpty) {
      setState(() { _results = []; _loading = false; _searched = false; });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 450), () => _doSearch(q));
  }

  Future<void> _doSearch(String query) async {
    final lois      = <_SearchItem>[];
    final faqs      = <_SearchItem>[];
    final juristes  = <_SearchItem>[];

    await Future.wait([
      ApiService.instance.get(ApiConstants.textesLoi, params: {'search': query}).then((res) {
        final list = res.data is List ? res.data as List : [];
        for (final item in list.take(5)) {
          lois.add(_SearchItem(
            title:    item['titre']     as String? ?? '',
            subtitle: item['categorie'] as String? ?? 'Texte de loi',
            tag:      'Loi',
            tagColor: AppColors.bleuNuit,
            route:    '/lois',
          ));
        }
      }).catchError((_) {}),

      ApiService.instance.get(ApiConstants.faq, params: {'search': query}).then((res) {
        final list = res.data is List ? res.data as List : [];
        for (final item in list.take(4)) {
          faqs.add(_SearchItem(
            title:    item['question'] as String? ?? '',
            subtitle: item['reponse']  as String? ?? '',
            tag:      'FAQ',
            tagColor: AppColors.emeraude,
            route:    '/lois',
          ));
        }
      }).catchError((_) {}),

      ApiService.instance.get(ApiConstants.specialistes, params: {'search': query}).then((res) {
        final list = res.data is List ? res.data as List : [];
        for (final item in list.take(3)) {
          final name = item['nom_complet'] as String?
              ?? '${item['first_name'] ?? ''} ${item['last_name'] ?? ''}'.trim();
          juristes.add(_SearchItem(
            title:    name,
            subtitle: item['specialite'] as String? ?? 'Spécialiste',
            tag:      'Juriste',
            tagColor: AppColors.orDark,
            route:    '/juristes',
          ));
        }
      }).catchError((_) {}),
    ]);

    if (!mounted || _lastQuery != query) return;
    setState(() {
      _results  = [...lois, ...faqs, ...juristes];
      _loading  = false;
      _searched = true;
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _SearchHeader(ctrl: _ctrl, focus: _focus),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.bleuNuit, strokeWidth: 2.5))
                : _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_ctrl.text.trim().isEmpty) return _QuickCategories();
    if (_searched && _results.isEmpty) return _NoResults(query: _ctrl.text.trim());
    if (_results.isEmpty) return const SizedBox.shrink();
    return _ResultsList(items: _results);
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.ctrl, required this.focus});
  final TextEditingController ctrl;
  final FocusNode focus;

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
          padding: const EdgeInsets.fromLTRB(4, 8, 14, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.blanc),
                onPressed: () => context.go('/home'),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.grisMid, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          focusNode: focus,
                          cursorColor: AppColors.bleuNuit,
                          style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 16,
                            color: AppColors.gris,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: s.searchHint,
                            hintStyle: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 16,
                              color: AppColors.grisMid,
                            ),
                          ),
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: ctrl,
                        builder: (context, value, child) => ctrl.text.isNotEmpty
                            ? GestureDetector(
                                onTap: ctrl.clear,
                                child: const Icon(Icons.close, color: AppColors.grisMid, size: 18),
                              )
                            : const SizedBox.shrink(),
                      ),
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

class _QuickCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cats = [
      (Icons.menu_book_outlined,       AppColors.bleuNuit, s.searchLaws,    '/lois'),
      (Icons.question_answer_outlined, AppColors.emeraude, s.searchFaq,     '/lois'),
      (Icons.gavel_outlined,           AppColors.orDark,   s.searchLawyers, '/juristes'),
      (Icons.smart_toy_outlined,       AppColors.bleuMid,  s.searchAi,      '/ia'),
      (Icons.folder_outlined,          AppColors.or,       s.searchFiles,   '/dossiers'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      children: [
        Text(s.searchQuickAccess,
            style: const TextStyle(
              fontFamily: 'GoogleSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.grisMid,
              letterSpacing: 0.8,
            )),
        const SizedBox(height: 14),
        ...cats.map((c) => _QuickTile(
          icon: c.$1,
          color: c.$2,
          label: c.$3,
          route: c.$4,
        )),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.icon, required this.color, required this.label, required this.route});
  final IconData icon;
  final Color color;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: color.withAlpha(28),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
            fontFamily: 'GoogleSans',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.gris,
          )),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grisMid),
      onTap: () => context.go(route),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.items});
  final List<_SearchItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 72, endIndent: 16),
      itemBuilder: (context, i) {
        final item = items[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: item.tagColor.withAlpha(28),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                item.tag,
                style: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: item.tagColor,
                ),
              ),
            ),
          ),
          title: Text(item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gris,
              )),
          subtitle: Text(item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 14,
                color: AppColors.grisMid,
              )),
          trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.grisMid),
          onTap: () => context.go(item.route),
        );
      },
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.grisMid),
            const SizedBox(height: 16),
            Text(s.searchNoResults(query),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gris,
                )),
            const SizedBox(height: 8),
            Text(s.searchNoResultsHint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 15,
                  color: AppColors.grisMid,
                )),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.go('/ia'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(s.searchAskAi,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blanc,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
