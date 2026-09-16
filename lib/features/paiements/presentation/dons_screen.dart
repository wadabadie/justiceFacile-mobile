import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';

// ─── Montants prédéfinis (FCFA) ───────────────────────────────────────────────

const _presets = [500, 1000, 2000, 5000];

// ─── Écran ────────────────────────────────────────────────────────────────────

class DonsScreen extends StatefulWidget {
  const DonsScreen({super.key});

  @override
  State<DonsScreen> createState() => _DonsScreenState();
}

class _DonsScreenState extends State<DonsScreen> {
  final _phoneCtrl   = TextEditingController();
  final _nomCtrl     = TextEditingController();
  final _msgCtrl     = TextEditingController();
  final _customCtrl  = TextEditingController();
  final _formKey     = GlobalKey<FormState>();

  int? _selectedPreset;
  bool _customMode = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nomCtrl.dispose();
    _msgCtrl.dispose();
    _customCtrl.dispose();
    super.dispose();
  }

  int? get _montant {
    if (_customMode) {
      return int.tryParse(_customCtrl.text.trim());
    }
    return _selectedPreset;
  }

  Future<void> _initierDon() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final montant = _montant;
    if (montant == null || montant < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).donsMinVal,
              style: const TextStyle(fontFamily: 'GoogleSans')),
          backgroundColor: AppColors.rouge,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ApiService.instance.post(
        ApiConstants.paiementInitierDon,
        data: {
          'montant':       montant,
          'telephone':     _phoneCtrl.text.trim(),
          if (_nomCtrl.text.trim().isNotEmpty)
            'nom_donateur': _nomCtrl.text.trim(),
          if (_msgCtrl.text.trim().isNotEmpty)
            'message':      _msgCtrl.text.trim(),
        },
      );
      if (!mounted) return;
      setState(() => _loading = false);

      final data = res.data as Map<String, dynamic>;
      final payUrl = data['payment_url'] as String?
          ?? data['url'] as String?
          ?? data['checkout_url'] as String?;
      final reference = data['reference'] as String? ?? '';

      if (payUrl != null && payUrl.isNotEmpty) {
        await _launchPaiement(payUrl);
      } else {
        // Pas de redirect URL — afficher la référence
        _showConfirmation(reference, montant);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data),
            style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  Future<void> _launchPaiement(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      _showSuccessSnack();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).donsImpossible,
              style: const TextStyle(fontFamily: 'GoogleSans')),
          backgroundColor: AppColors.rouge,
        ),
      );
    }
  }

  void _showSuccessSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.of(context).donsRedirection,
            style: const TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: AppColors.emeraude,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showConfirmation(String reference, int montant) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Builder(builder: (bCtx) {
          final s = AppStrings.of(bCtx);
          return Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.emeraude, size: 24),
              const SizedBox(width: 10),
              Text(s.donsConfirmTitle,
                  style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bleuNuit)),
            ],
          );
        }),
        content: Builder(builder: (bCtx) {
          final s = AppStrings.of(bCtx);
          return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.donsMontantLabel(montant),
                style: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 14,
                    color: AppColors.gris)),
            const SizedBox(height: 8),
            if (reference.isNotEmpty) ...[
              Text(s.donsReferenceLabel,
                  style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      color: AppColors.grisMid)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: reference));
                  ScaffoldMessenger.of(bCtx).showSnackBar(
                    SnackBar(
                      content: Text(s.donsReferenceCopied,
                          style: const TextStyle(fontFamily: 'GoogleSans')),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.fond,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x18000000)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(reference,
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                color: AppColors.bleuNuit)),
                      ),
                      const Icon(Icons.copy_rounded,
                          size: 14, color: AppColors.grisMid),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              s.donsMerci,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 13,
                  color: AppColors.grisMid,
                  height: 1.4),
            ),
          ],
        );
        }),
        actions: [
          Builder(builder: (bCtx) {
            final s = AppStrings.of(bCtx);
            return ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraude,
                foregroundColor: AppColors.blanc,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text(s.donsCompris,
                style: const TextStyle(
                    fontFamily: 'GoogleSans', fontWeight: FontWeight.w700)),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _DonsHeader(onBack: () => context.go('/home')),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte d'impact
                    _ImpactCard(),
                    const SizedBox(height: 28),

                    // Sélection montant
                    _SectionLabel(text: AppStrings.of(context).donsChoixMontant),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ..._presets.map((p) => _AmountChip(
                              amount: p,
                              selected:
                                  !_customMode && _selectedPreset == p,
                              onTap: () => setState(() {
                                _selectedPreset = p;
                                _customMode = false;
                                _customCtrl.clear();
                              }),
                            )),
                        _AmountChip(
                          amount: null,
                          selected: _customMode,
                          onTap: () => setState(
                              () { _customMode = true; _selectedPreset = null; }),
                        ),
                      ],
                    ),
                    if (_customMode) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _customCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 16,
                            color: AppColors.gris),
                        decoration: _inputDeco(
                          label: AppStrings.of(context).donsMontantPersonnalise,
                          hint: 'ex: 3500',
                          suffix: 'FCFA',
                        ),
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          if (n == null || n < 100) {
                            return AppStrings.of(context).donsMinVal;
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Numéro Mobile Money
                    _SectionLabel(text: AppStrings.of(context).donsMobileMoney),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 15,
                          color: AppColors.gris),
                      decoration: _inputDeco(
                        label: 'Téléphone',
                        hint: '6XXXXXXXX',
                        prefix: '+237 ',
                      ),
                      validator: (v) {
                        final digits = v?.trim() ?? '';
                        if (digits.length < 9) {
                          return AppStrings.of(context).donsNumInvalide;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nom (optionnel)
                    _SectionLabel(text: AppStrings.of(context).donsNomSection),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nomCtrl,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 15,
                          color: AppColors.gris),
                      decoration: _inputDeco(
                        label: AppStrings.of(context).donsNomDonateur,
                        hint: AppStrings.of(context).donsAnonymeLabel,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message (optionnel)
                    _SectionLabel(text: AppStrings.of(context).donsMessageSection),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _msgCtrl,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 15,
                          color: AppColors.gris),
                      decoration: _inputDeco(
                        label: AppStrings.of(context).donsMsgEncouragement,
                        hint: '',
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Résumé montant sélectionné
                    if (_montant != null)
                      _SummaryBanner(montant: _montant!),
                    if (_montant != null) const SizedBox(height: 16),

                    // Bouton payer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _initierDon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.or,
                          foregroundColor: AppColors.blanc,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.blanc))
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.favorite_rounded, size: 20),
                                  const SizedBox(width: 10),
                                  Text(AppStrings.of(context).donsBtnPayer,
                                      style: const TextStyle(
                                          fontFamily: 'GoogleSans',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Sécurité
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_rounded,
                              size: 13, color: AppColors.grisLight),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.of(context).donsSecurite,
                            style: const TextStyle(
                                fontFamily: 'GoogleSans',
                                fontSize: 11,
                                color: AppColors.grisLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco({
    required String label,
    required String hint,
    String? prefix,
    String? suffix,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        suffixText: suffix,
        labelStyle: const TextStyle(
            fontFamily: 'GoogleSans', fontSize: 14, color: AppColors.grisMid),
        hintStyle: const TextStyle(
            fontFamily: 'GoogleSans', fontSize: 14, color: AppColors.grisLight),
        filled: true,
        fillColor: AppColors.blanc,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x18000000)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x18000000)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.or, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rouge),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rouge, width: 2),
        ),
      );
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _DonsHeader extends StatelessWidget {
  const _DonsHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.orDark, AppColors.or],
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
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
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
                      Text(s.donsTitle,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blanc)),
                      Text(s.donsSubtitle,
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 13,
                              color: Color(0xCCFFFFFF))),
                    ],
                  );
                }),
              ),
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: AppColors.blanc, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Carte d'impact ───────────────────────────────────────────────────────────

class _ImpactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const impacts = [
      (Icons.gavel_rounded, '500 FCFA', 'Consultation juridique partielle'),
      (Icons.psychology_rounded, '1 000 FCFA', 'Séance d\'écoute psychologique'),
      (Icons.home_rounded, '5 000 FCFA', 'Hébergement d\'urgence (1 nuit)'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bleuNuit, AppColors.bleuMid],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppColors.ombre],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(builder: (ctx) {
            final s = AppStrings.of(ctx);
            return Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.orPale, size: 18),
                const SizedBox(width: 8),
                Text(s.donsImpactTitle,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blanc)),
              ],
            );
          }),
          const SizedBox(height: 14),
          ...impacts.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(item.$1,
                          color: AppColors.orPale, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${item.$2} → ',
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.orPale),
                            ),
                            TextSpan(
                              text: item.$3,
                              style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 13,
                                  color: Color(0xCCFFFFFF)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Chip montant ─────────────────────────────────────────────────────────────

class _AmountChip extends StatelessWidget {
  const _AmountChip(
      {required this.amount, required this.selected, required this.onTap});
  final int? amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = amount != null ? '$amount F' : AppStrings.of(context).donsAutre;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.or : AppColors.blanc,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.or : const Color(0x20000000),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: AppColors.or.withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [
                  const BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2))
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'GoogleSans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.blanc : AppColors.gris,
          ),
        ),
      ),
    );
  }
}

// ─── Résumé don ──────────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.montant});
  final int montant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.orLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.or.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.volunteer_activism_rounded,
              color: AppColors.or, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Builder(builder: (ctx) {
              final s = AppStrings.of(ctx);
              return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${s.donsSummaryPrefix} ',
                      style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 14,
                          color: AppColors.orDark),
                    ),
                    TextSpan(
                      text: '$montant FCFA',
                      style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.orDark),
                    ),
                    TextSpan(
                      text: ' ${s.donsSummarySuffix}',
                      style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 14,
                          color: AppColors.orDark),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Label de section ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontFamily: 'GoogleSans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.bleuNuit));
  }
}
