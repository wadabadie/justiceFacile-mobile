import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';

class NewDossierScreen extends StatefulWidget {
  const NewDossierScreen({super.key});

  @override
  State<NewDossierScreen> createState() => _NewDossierScreenState();
}

class _NewDossierScreenState extends State<NewDossierScreen> {
  final _descCtrl = TextEditingController();
  bool _estAnonyme = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _descCtrl.text.trim().length >= 20 && !_loading;

  Future<void> _submit() async {
    final desc  = _descCtrl.text.trim();
    final titre = desc.length > 80 ? '${desc.substring(0, 80)}…' : desc;

    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.instance.post(ApiConstants.demandes, data: {
        'titre':            titre,
        'description':      desc,
        'est_anonyme':      _estAnonyme,
        'consentement_ong': true,
      });
      if (!mounted) return;
      final s = AppStrings.of(context);
      context.go('/dossiers');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.ndSuccess,
              style: const TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w600)),
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
    final s = AppStrings.of(context);
    final charCount = _descCtrl.text.trim().length;

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _buildHeader(context, s),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bleuNuit.withAlpha(8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.bleuNuit.withAlpha(20)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.bleuNuit.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded,
                              color: AppColors.bleuNuit, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.ndAiTitle,
                                  style: const TextStyle(
                                    fontFamily: 'GoogleSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.bleuNuit,
                                  )),
                              const SizedBox(height: 4),
                              Text(s.ndAiDesc,
                                  style: const TextStyle(
                                    fontFamily: 'GoogleSans',
                                    fontSize: 13,
                                    color: AppColors.grisMid,
                                    height: 1.4,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description field
                  Text(s.ndDescLabel,
                      style: AppTextStyles.h3.copyWith(fontSize: 17)),
                  const SizedBox(height: 4),
                  Text(s.ndDescDesc,
                      style: AppTextStyles.bodySm.copyWith(fontSize: 14, height: 1.4)),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.blanc,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x1A000000)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                    child: TextField(
                      controller: _descCtrl,
                      onChanged: (_) => setState(() {}),
                      maxLines: 8,
                      maxLength: 1000,
                      style: AppTextStyles.body.copyWith(fontSize: 15, height: 1.6),
                      decoration: InputDecoration(
                        hintText: s.ndDescHint,
                        hintStyle: AppTextStyles.bodySm.copyWith(
                            color: AppColors.grisLight, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        counterStyle: const TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 12, color: AppColors.grisLight),
                      ),
                    ),
                  ),

                  if (charCount > 0 && charCount < 20)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        s.ndMinCharsMsg(20 - charCount),
                        style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 13,
                          color: AppColors.rouge,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // Anonymous toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.blanc,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _estAnonyme
                            ? AppColors.bleuNuit.withAlpha(60)
                            : const Color(0x1A000000),
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: _estAnonyme
                                ? AppColors.bleuNuit.withAlpha(15)
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _estAnonyme
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: _estAnonyme ? AppColors.bleuNuit : AppColors.grisMid,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.ndAnonLabel,
                                  style: const TextStyle(
                                    fontFamily: 'GoogleSans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gris,
                                  )),
                              const SizedBox(height: 2),
                              Text(s.ndAnonDesc,
                                  style: const TextStyle(
                                    fontFamily: 'GoogleSans',
                                    fontSize: 12,
                                    color: AppColors.grisMid,
                                    height: 1.3,
                                  )),
                            ],
                          ),
                        ),
                        Switch(
                          value: _estAnonyme,
                          onChanged: (v) => setState(() => _estAnonyme = v),
                          activeThumbColor: AppColors.blanc,
                          activeTrackColor: AppColors.bleuNuit,
                        ),
                      ],
                    ),
                  ),

                  // Error
                  if (_error != null) ...[
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
                            child: Text(_error!,
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
                          child: Text(s.ndPrivacy,
                              style: const TextStyle(
                                fontFamily: 'GoogleSans',
                                fontSize: 13,
                                color: AppColors.orDark,
                                height: 1.4,
                              )),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, s),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStrings s) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientBleu),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 18, 20),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/dossiers');
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.blanc, size: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.newDossierTitle,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 12,
                          color: Color(0x80FFFFFF),
                          fontWeight: FontWeight.w500,
                        )),
                    Text(s.ndDescLabel,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.or.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.or.withAlpha(80)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.orPale, size: 14),
                    SizedBox(width: 4),
                    Text('Confidentiel',
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.orPale,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppStrings s) {
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
            gradient: _canSubmit
                ? const LinearGradient(colors: [AppColors.emeraude, Color(0xFF0A5E57)])
                : const LinearGradient(colors: [Color(0xFFCCCCCC), Color(0xFFBBBBBB)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _canSubmit
                ? [BoxShadow(
                    color: AppColors.emeraude.withAlpha(80),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _canSubmit ? _submit : null,
              borderRadius: BorderRadius.circular(14),
              child: Center(
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: AppColors.blanc, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s.btnSubmit,
                              style: const TextStyle(
                                fontFamily: 'GoogleSans',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blanc,
                              )),
                          const SizedBox(width: 8),
                          const Icon(Icons.send_rounded,
                              color: AppColors.blanc, size: 20),
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
