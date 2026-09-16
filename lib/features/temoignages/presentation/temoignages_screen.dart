import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';

// ─── Modèle ───────────────────────────────────────────────────────────────────

class _Temoignage {
  _Temoignage({
    required this.id,
    required this.contenu,
    required this.pseudo,
    required this.dateCreation,
    required this.nbSoutiens,
    required this.userASoutenu,
  });

  final int id;
  final String contenu;
  final String pseudo;
  final DateTime dateCreation;
  int nbSoutiens;
  bool userASoutenu;

  factory _Temoignage.fromJson(Map<String, dynamic> j) => _Temoignage(
        id:           j['id'] as int,
        contenu:      j['contenu'] as String? ?? '',
        pseudo:       j['pseudo'] as String?
                          ?? j['auteur_pseudo'] as String?
                          ?? 'Anonyme',
        dateCreation: DateTime.tryParse(j['date_creation'] as String? ?? '')
                          ?.toLocal() ??
                      DateTime.now(),
        nbSoutiens:   j['nb_soutiens'] as int? ?? 0,
        userASoutenu: j['user_a_soutenu'] as bool? ?? false,
      );

  String dateLabel(BuildContext context) {
    final s = AppStrings.of(context);
    final diff = DateTime.now().difference(dateCreation);
    if (diff.inDays == 0) return s.temoignagesAujourdhui;
    if (diff.inDays == 1) return s.temoignagesHier;
    if (diff.inDays < 7) return s.temoignagesJours(diff.inDays);
    return '${dateCreation.day}/${dateCreation.month}/${dateCreation.year}';
  }
}

// ─── Écran ────────────────────────────────────────────────────────────────────

class TemoignagesScreen extends StatefulWidget {
  const TemoignagesScreen({super.key});

  @override
  State<TemoignagesScreen> createState() => _TemoignagesScreenState();
}

class _TemoignagesScreenState extends State<TemoignagesScreen> {
  List<_Temoignage> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.instance.get(ApiConstants.temoignages);
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _items = list
            .map((e) => _Temoignage.fromJson(e as Map<String, dynamic>))
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

  Future<void> _soutenir(int index) async {
    final t = _items[index];
    // Optimistic update
    setState(() {
      if (t.userASoutenu) {
        t.nbSoutiens--;
      } else {
        t.nbSoutiens++;
      }
      t.userASoutenu = !t.userASoutenu;
    });

    try {
      await ApiService.instance.post(ApiConstants.temoignageSoutenir(t.id));
    } on DioException {
      // Revert on failure
      if (!mounted) return;
      setState(() {
        if (t.userASoutenu) {
          t.nbSoutiens--;
        } else {
          t.nbSoutiens++;
        }
        t.userASoutenu = !t.userASoutenu;
      });
    }
  }

  void _showSoumettre() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SoumettreSheet(
        onSubmit: (contenu, estAnonyme) async {
          await _soumettre(contenu, estAnonyme);
        },
      ),
    );
  }

  Future<void> _soumettre(String contenu, bool estAnonyme) async {
    try {
      await ApiService.instance.post(
        ApiConstants.temoignages,
        data: {'contenu': contenu, 'est_anonyme': estAnonyme},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.of(context).temoignagesModeration,
            style: const TextStyle(fontFamily: 'GoogleSans'),
          ),
          backgroundColor: AppColors.emeraude,
          duration: const Duration(seconds: 3),
        ),
      );
      _load();
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
          _TemoignagesHeader(onBack: () => context.go('/home')),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSoumettre,
        backgroundColor: AppColors.emeraude,
        foregroundColor: AppColors.blanc,
        icon: const Icon(Icons.edit_rounded),
        label: Text(AppStrings.of(context).temoignagesBtnTemoigner,
            style: const TextStyle(
                fontFamily: 'GoogleSans', fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.grisLight),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 15,
                    color: AppColors.grisMid)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
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

    if (_items.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        itemCount: _items.length,
        itemBuilder: (_, i) => _TemoignageCard(
          item: _items[i],
          onSoutenir: () => _soutenir(i),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _TemoignagesHeader extends StatelessWidget {
  const _TemoignagesHeader({required this.onBack});
  final VoidCallback onBack;

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38,
                  height: 38,
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
                      Text(s.temoignagesTitle,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blanc)),
                      Text(s.temoignagesSubtitle,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 13,
                              color: Color(0x99FFFFFF))),
                    ],
                  );
                }),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite_border_rounded,
                    color: AppColors.orPale, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Carte témoignage ─────────────────────────────────────────────────────────

class _TemoignageCard extends StatefulWidget {
  const _TemoignageCard({required this.item, required this.onSoutenir});
  final _Temoignage item;
  final VoidCallback onSoutenir;

  @override
  State<_TemoignageCard> createState() => _TemoignageCardState();
}

class _TemoignageCardState extends State<_TemoignageCard> {
  bool _expanded = false;
  static const _maxChars = 200;

  @override
  Widget build(BuildContext context) {
    final text = widget.item.contenu;
    final needsExpand = text.length > _maxChars;
    final displayText =
        (!_expanded && needsExpand) ? '${text.substring(0, _maxChars)}…' : text;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bandeau supérieur coloré
          Container(
            height: 5,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.emeraude, AppColors.bleuMid],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Auteur + date
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.fond2,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.grisMid, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.item.pseudo,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.bleuNuit)),
                          Text(widget.item.dateLabel(context),
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 12,
                                  color: AppColors.grisLight)),
                        ],
                      ),
                    ),
                    // Badge solidarité
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.emeraudeLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded,
                              size: 12, color: AppColors.emeraude),
                          const SizedBox(width: 4),
                          Text(AppStrings.of(context).temoignagesValide,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.emeraude)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Guillemets décoratifs
                const Text('"',
                    style: TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 36,
                        height: 0.6,
                        color: AppColors.emeraude,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(displayText,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 15,
                        color: AppColors.gris,
                        height: 1.55)),
                if (needsExpand) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded
                          ? AppStrings.of(context).temoignagesVoirMoins
                          : AppStrings.of(context).temoignagesLireSuite,
                      style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emeraude),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0x14000000)),
                const SizedBox(height: 10),
                // Bouton soutenir
                GestureDetector(
                  onTap: widget.onSoutenir,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          widget.item.userASoutenu
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(widget.item.userASoutenu),
                          color: widget.item.userASoutenu
                              ? AppColors.rouge
                              : AppColors.grisMid,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.of(context).temoignagesSoutiens(widget.item.nbSoutiens),
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: widget.item.userASoutenu
                              ? AppColors.rouge
                              : AppColors.grisMid,
                        ),
                      ),
                    ],
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

// ─── Bottom sheet — soumettre un témoignage ───────────────────────────────────

class _SoumettreSheet extends StatefulWidget {
  const _SoumettreSheet({required this.onSubmit});
  final Future<void> Function(String contenu, bool estAnonyme) onSubmit;

  @override
  State<_SoumettreSheet> createState() => _SoumettreSheetState();
}

class _SoumettreSheetState extends State<_SoumettreSheet> {
  final _ctrl = TextEditingController();
  bool _estAnonyme = true;
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    await widget.onSubmit(text, _estAnonyme);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poignée
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: const Color(0x20000000),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(AppStrings.of(context).temoignagesPartagerTitle,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bleuNuit)),
          const SizedBox(height: 6),
          Text(
            AppStrings.of(context).temoignagesPartagerDesc,
            style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 13,
                color: AppColors.grisMid,
                height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.fond,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x18000000)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextField(
              controller: _ctrl,
              maxLines: 5,
              minLines: 4,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 15,
                  color: AppColors.gris,
                  height: 1.5),
              decoration: InputDecoration(
                hintText: AppStrings.of(context).temoignagesHint,
                hintStyle: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 15,
                    color: AppColors.grisLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Toggle anonyme
          GestureDetector(
            onTap: () => setState(() => _estAnonyme = !_estAnonyme),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _estAnonyme ? AppColors.emeraude : AppColors.fond2,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _estAnonyme
                          ? AppColors.emeraude
                          : const Color(0x30000000),
                    ),
                  ),
                  child: _estAnonyme
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.blanc, size: 15)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.of(context).temoignagesAnonyme,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 14,
                        color: AppColors.gris,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sending ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraude,
                foregroundColor: AppColors.blanc,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.blanc),
                    )
                  : Text(AppStrings.of(context).temoignagesSoumettre,
                      style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
            ),
          ),
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
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
                color: AppColors.fond2, shape: BoxShape.circle),
            child: const Icon(Icons.favorite_border_rounded,
                size: 40, color: AppColors.grisLight),
          ),
          const SizedBox(height: 20),
          Text(AppStrings.of(context).temoignagesEmpty,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bleuNuit)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              AppStrings.of(context).temoignagesEmptyDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 14,
                  color: AppColors.grisMid,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
