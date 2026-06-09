import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/api_constants.dart';

// Category definition: (label, icon, accent color, background color)
typedef _Cat = ({String label, IconData icon, Color color, Color bg});

const _categories = <_Cat>[
  (label: 'VBG',               icon: Icons.shield_outlined,          color: AppColors.rouge,   bg: AppColors.rougeLight),
  (label: 'Droit du travail',  icon: Icons.work_outline_rounded,     color: AppColors.bleuMid, bg: Color(0xFFE8F0FE)),
  (label: 'Droit de la famille', icon: Icons.family_restroom_rounded, color: AppColors.emeraude, bg: AppColors.emeraudeLight),
  (label: 'Droit foncier',     icon: Icons.landscape_outlined,       color: AppColors.or,      bg: AppColors.orLight),
  (label: 'Droit civil',       icon: Icons.balance_outlined,         color: AppColors.bleuNuit, bg: Color(0xFFEEF2FF)),
  (label: 'Droit pénal',       icon: Icons.gavel_rounded,            color: Color(0xFF7B1FA2), bg: Color(0xFFF3E5F5)),
  (label: 'Autre',             icon: Icons.help_outline_rounded,     color: AppColors.grisMid, bg: Color(0xFFF0F0F0)),
];

const _regions = <String>[
  'Centre', 'Littoral', 'Ouest', 'Sud-Ouest', 'Nord-Ouest',
  'Nord', 'Adamaoua', 'Est', 'Sud', 'Extrême-Nord',
];

class NewDossierScreen extends StatefulWidget {
  const NewDossierScreen({super.key});

  @override
  State<NewDossierScreen> createState() => _NewDossierScreenState();
}

class _NewDossierScreenState extends State<NewDossierScreen> {
  int _step = 0;

  // Step 1 — category + title
  String? _categorie;
  final _titreCtrl = TextEditingController();

  // Step 2 — description + region
  final _descCtrl = TextEditingController();
  String? _region;

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _step1Valid =>
      _categorie != null && _titreCtrl.text.trim().isNotEmpty;

  bool get _step2Valid =>
      _descCtrl.text.trim().length >= 20;

  bool get _canProceed => switch (_step) {
    0 => _step1Valid,
    1 => _step2Valid,
    _ => true,
  };

  void _next() {
    if (_step < 2) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ));

      await dio.post(ApiConstants.demandes, data: {
        'titre':       _titreCtrl.text.trim(),
        'categorie':   _categorie,
        'description': _descCtrl.text.trim(),
        if (_region != null) 'region': _region,
      });

      if (!mounted) return;
      context.go('/dossiers');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Votre demande a été soumise avec succès.',
            style: TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.emeraude,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['error']
          ?? (e.response?.data as Map?)?['detail']
          ?? 'Une erreur est survenue. Veuillez réessayer.';
      setState(() => _error = msg.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _Header(step: _step, onBack: _back),
          _StepBar(step: _step),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: switch (_step) {
                  0 => _Step1(
                      categorie: _categorie,
                      titreCtrl: _titreCtrl,
                      onCatSelected: (c) => setState(() => _categorie = c),
                      onTitreChanged: (_) => setState(() {}),
                    ),
                  1 => _Step2(
                      descCtrl: _descCtrl,
                      region: _region,
                      onRegionSelected: (r) => setState(() => _region = r),
                      onDescChanged: (_) => setState(() {}),
                    ),
                  _ => _Step3Review(
                      categorie: _categorie!,
                      titre: _titreCtrl.text.trim(),
                      description: _descCtrl.text.trim(),
                      region: _region,
                      error: _error,
                    ),
                },
              ),
            ),
          ),
          _BottomBar(
            step: _step,
            canProceed: _canProceed,
            loading: _loading,
            onNext: _next,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.step, required this.onBack});
  final int step;
  final VoidCallback onBack;

  static const _titles = ['Catégorie & Titre', 'Description', 'Confirmation'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientBleu),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 18, 16),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.blanc, size: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nouvelle demande',
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 12,
                          color: Color(0x80FFFFFF),
                          fontWeight: FontWeight.w500,
                        )),
                    Text(_titles[step],
                        style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blanc,
                        )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${step + 1} / 3',
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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

// ── Step progress bar ──────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bleuMid,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Row(
        children: List.generate(3, (i) {
          final done    = i < step;
          final current = i == step;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done || current
                          ? AppColors.or
                          : Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Step 1 — Category + Title ──────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  const _Step1({
    required this.categorie,
    required this.titreCtrl,
    required this.onCatSelected,
    required this.onTitreChanged,
  });
  final String? categorie;
  final TextEditingController titreCtrl;
  final ValueChanged<String> onCatSelected;
  final ValueChanged<String> onTitreChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sélectionnez une catégorie', style: AppTextStyles.h3.copyWith(fontSize: 17)),
          const SizedBox(height: 4),
          Text('Choisissez le domaine juridique qui correspond à votre situation.',
              style: AppTextStyles.bodySm.copyWith(fontSize: 14, height: 1.4)),
          const SizedBox(height: 16),

          // Category grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.4,
            ),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final selected = categorie == cat.label;
              return GestureDetector(
                onTap: () => onCatSelected(cat.label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? cat.color : AppColors.blanc,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? cat.color : const Color(0x1A000000),
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(color: cat.color.withAlpha(60), blurRadius: 10, offset: const Offset(0, 4))]
                        : const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: selected ? Colors.white.withAlpha(40) : cat.bg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(cat.icon,
                            color: selected ? AppColors.blanc : cat.color,
                            size: 17),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(cat.label,
                            style: TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected ? AppColors.blanc : AppColors.gris,
                            )),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),
          Text('Titre de votre demande', style: AppTextStyles.h3.copyWith(fontSize: 17)),
          const SizedBox(height: 4),
          Text('Résumez votre situation en quelques mots.',
              style: AppTextStyles.bodySm.copyWith(fontSize: 14)),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppColors.blanc,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1A000000)),
              boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: TextField(
              controller: titreCtrl,
              onChanged: onTitreChanged,
              maxLength: 100,
              style: AppTextStyles.body.copyWith(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Ex : Licenciement sans motif valable',
                hintStyle: AppTextStyles.bodySm.copyWith(
                    color: AppColors.grisLight, fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
                counterStyle: const TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 12, color: AppColors.grisLight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2 — Description + Region ─────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  const _Step2({
    required this.descCtrl,
    required this.region,
    required this.onRegionSelected,
    required this.onDescChanged,
  });
  final TextEditingController descCtrl;
  final String? region;
  final ValueChanged<String> onRegionSelected;
  final ValueChanged<String> onDescChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Décrivez votre situation', style: AppTextStyles.h3.copyWith(fontSize: 17)),
          const SizedBox(height: 4),
          Text('Soyez précis(e) pour que le spécialiste comprenne bien votre cas. Minimum 20 caractères.',
              style: AppTextStyles.bodySm.copyWith(fontSize: 14, height: 1.4)),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppColors.blanc,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1A000000)),
              boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: TextField(
              controller: descCtrl,
              onChanged: onDescChanged,
              maxLines: 6,
              maxLength: 1000,
              style: AppTextStyles.body.copyWith(fontSize: 15, height: 1.5),
              decoration: InputDecoration(
                hintText: 'Décrivez les faits, les dates importantes, les personnes impliquées...',
                hintStyle: AppTextStyles.bodySm.copyWith(
                    color: AppColors.grisLight, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
                counterStyle: const TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 12, color: AppColors.grisLight),
              ),
            ),
          ),

          // Character count hint
          if (descCtrl.text.isNotEmpty && descCtrl.text.trim().length < 20)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Encore ${20 - descCtrl.text.trim().length} caractères minimum',
                style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 13,
                  color: AppColors.rouge,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const SizedBox(height: 28),
          Text('Votre région', style: AppTextStyles.h3.copyWith(fontSize: 17)),
          const SizedBox(height: 4),
          Text('Optionnel — permet d\'orienter votre dossier vers un spécialiste local.',
              style: AppTextStyles.bodySm.copyWith(fontSize: 14, height: 1.4)),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _regions.map((r) {
              final selected = region == r;
              return GestureDetector(
                onTap: () => onRegionSelected(r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.bleuNuit : AppColors.blanc,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.bleuNuit : const Color(0x1A000000),
                    ),
                  ),
                  child: Text(r,
                      style: TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? AppColors.blanc : AppColors.grisMid,
                      )),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Step 3 — Review / Confirmation ────────────────────────────────────────────

class _Step3Review extends StatelessWidget {
  const _Step3Review({
    required this.categorie,
    required this.titre,
    required this.description,
    required this.region,
    required this.error,
  });
  final String categorie, titre, description;
  final String? region, error;

  _Cat get _cat =>
      _categories.firstWhere((c) => c.label == categorie, orElse: () => _categories.last);

  @override
  Widget build(BuildContext context) {
    final cat = _cat;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confirmation banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.bleuNuit, AppColors.bleuMid],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fact_check_outlined,
                      color: AppColors.orPale, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vérifiez votre demande',
                          style: TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blanc,
                          )),
                      const SizedBox(height: 2),
                      Text('Une fois soumise, votre demande sera examinée par un administrateur.',
                          style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 12,
                            color: Color(0x99FFFFFF),
                            height: 1.4,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text('Récapitulatif', style: AppTextStyles.h3.copyWith(fontSize: 17)),
          const SizedBox(height: 14),

          // Review card
          Container(
            decoration: BoxDecoration(
              color: AppColors.blanc,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x0F000000)),
              boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3))],
            ),
            child: Column(
              children: [
                _ReviewRow(
                  icon: cat.icon,
                  iconColor: cat.color,
                  iconBg: cat.bg,
                  label: 'Catégorie',
                  value: categorie,
                ),
                _Divider(),
                _ReviewRow(
                  icon: Icons.title_rounded,
                  iconColor: AppColors.bleuMid,
                  iconBg: const Color(0xFFE8F0FE),
                  label: 'Titre',
                  value: titre,
                ),
                _Divider(),
                _ReviewRow(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.gris,
                  iconBg: const Color(0xFFF0F0F0),
                  label: 'Description',
                  value: description,
                  multiline: true,
                ),
                if (region != null) ...[
                  _Divider(),
                  _ReviewRow(
                    icon: Icons.location_on_outlined,
                    iconColor: AppColors.emeraude,
                    iconBg: AppColors.emeraudeLight,
                    label: 'Région',
                    value: region!,
                  ),
                ],
              ],
            ),
          ),

          // Error message
          if (error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.rougeLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.rouge.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.rouge, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(error!,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 14,
                          color: AppColors.rouge,
                        )),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          // Privacy notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.orLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.or.withAlpha(60)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline_rounded,
                    color: AppColors.orDark, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vos informations sont confidentielles et ne seront partagées qu\'avec le spécialiste assigné à votre dossier.',
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      color: AppColors.orDark,
                      height: 1.4,
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
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.multiline = false,
  });
  final IconData icon;
  final Color iconColor, iconBg;
  final String label, value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 12,
                      color: AppColors.grisLight,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gris,
                      height: 1.4,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: Color(0x0A000000), indent: 60);
}

// ── Bottom action bar ──────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step,
    required this.canProceed,
    required this.loading,
    required this.onNext,
    required this.onSubmit,
  });
  final int step;
  final bool canProceed, loading;
  final VoidCallback onNext, onSubmit;

  @override
  Widget build(BuildContext context) {
    final isLast = step == 2;
    return Container(
      padding: EdgeInsets.fromLTRB(18, 14, 18, MediaQuery.of(context).padding.bottom + 14),
      decoration: const BoxDecoration(
        color: AppColors.blanc,
        boxShadow: [BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, -3))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: canProceed
                ? (isLast
                    ? const LinearGradient(colors: [AppColors.emeraude, Color(0xFF0A5E57)])
                    : const LinearGradient(colors: [AppColors.bleuNuit, AppColors.bleuMid]))
                : const LinearGradient(colors: [Color(0xFFCCCCCC), Color(0xFFBBBBBB)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: canProceed
                ? [BoxShadow(
                    color: (isLast ? AppColors.emeraude : AppColors.bleuNuit).withAlpha(80),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canProceed && !loading ? (isLast ? onSubmit : onNext) : null,
              borderRadius: BorderRadius.circular(14),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.blanc,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLast ? 'Soumettre ma demande' : 'Suivant',
                            style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blanc,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLast
                                ? Icons.check_circle_outline_rounded
                                : Icons.arrow_forward_rounded,
                            color: AppColors.blanc,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
