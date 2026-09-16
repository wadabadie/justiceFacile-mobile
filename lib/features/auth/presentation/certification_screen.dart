import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../infrastructure/auth_repository_impl.dart';

class CertificationScreen extends StatefulWidget {
  const CertificationScreen({super.key});

  @override
  State<CertificationScreen> createState() => _CertificationScreenState();
}

enum _CertStatut { nonSoumis, enAttente, valide, rejete, inconnu }

_CertStatut _parseStatut(String? s) => switch (s?.toUpperCase()) {
  'EN_ATTENTE' => _CertStatut.enAttente,
  'VALIDE'     => _CertStatut.valide,
  'REJETE'     => _CertStatut.rejete,
  'NON_SOUMIS' => _CertStatut.nonSoumis,
  _            => _CertStatut.inconnu,
};

class _CertificationScreenState extends State<CertificationScreen> {
  final _form = GlobalKey<FormState>();
  final _nomStructureCtrl = TextEditingController();
  final _numeroCarteCtrl = TextEditingController();

  bool _loading = true;
  bool _submitting = false;
  String? _error;

  String? _role;
  _CertStatut _statut = _CertStatut.inconnu;
  String? _raisonRefus;

  // URLs of uploaded documents. Null means "not uploaded yet".
  String? _urlCartePro;
  String? _urlDiplome;
  String? _urlCni;
  String? _urlPhoto;

  // Local upload-in-flight tracking so we can show a spinner per row.
  final Set<String> _uploadingFields = {};

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      final profile = await AuthRepositoryImpl().fetchMyProfileRaw();
      if (!mounted) return;
      setState(() {
        _role = (profile['role'] as String? ?? '').toUpperCase();
        _statut = _parseStatut(profile['certification_statut'] as String?);
        _raisonRefus = profile['certification_raison'] as String?;
        _nomStructureCtrl.text = profile['nom_structure'] as String? ?? '';
        _numeroCarteCtrl.text = profile['numero_carte_professionnelle'] as String? ?? '';
        _urlCartePro = profile['document_carte_pro'] as String?;
        _urlDiplome = profile['document_diplome'] as String?;
        _urlCni = profile['document_cni'] as String?;
        _urlPhoto = profile['photo_professionnelle'] as String?;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = (e.response?.data as Map?)?['detail'] as String? ?? 'Erreur de chargement.';
      });
    }
  }

  Future<void> _pickAndUpload(String field, {bool imageOnly = false}) async {
    final s = AppStrings.of(context);
    List<PlatformFile> files;
    try {
      files = await FilePicker.pickFiles(
        type: imageOnly ? FileType.image : FileType.custom,
        allowedExtensions: imageOnly ? null : ['pdf', 'jpg', 'jpeg', 'png'],
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.certPickError),
        backgroundColor: AppColors.rouge,
      ));
      return;
    }
    if (files.isEmpty || files.first.path == null) return;

    final path = files.first.path!;
    final size = File(path).lengthSync();
    if (size > 10 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.certFileTooBig),
        backgroundColor: AppColors.rouge,
      ));
      return;
    }

    setState(() => _uploadingFields.add(field));
    try {
      final url = await AuthRepositoryImpl().uploadCertificationDocument(filePath: path);
      if (!mounted) return;
      setState(() {
        switch (field) {
          case 'carte_pro': _urlCartePro = url; break;
          case 'diplome':   _urlDiplome = url; break;
          case 'cni':       _urlCni = url; break;
          case 'photo':     _urlPhoto = url; break;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.certUploadError),
        backgroundColor: AppColors.rouge,
      ));
    } finally {
      if (mounted) setState(() => _uploadingFields.remove(field));
    }
  }

  bool get _isSpecialiste => _role == 'JURISTE' || _role == 'PSYCHOLOGUE' || _role == 'ONG';
  bool get _isOng => _role == 'ONG';

  bool _canSubmit() {
    if (!_isSpecialiste) return false;
    if (_isOng) {
      return _nomStructureCtrl.text.trim().isNotEmpty &&
          _urlCartePro != null && _urlCni != null;
    }
    return _numeroCarteCtrl.text.trim().isNotEmpty &&
        _urlCartePro != null && _urlDiplome != null && _urlCni != null;
  }

  Future<void> _submit() async {
    final s = AppStrings.of(context);
    if (!_form.currentState!.validate()) return;
    if (!_canSubmit()) {
      setState(() => _error = s.certMissingDocs);
      return;
    }

    setState(() { _submitting = true; _error = null; });
    try {
      final payload = <String, dynamic>{
        'document_carte_pro': _urlCartePro,
        'document_cni': _urlCni,
        if (_urlPhoto != null) 'photo_professionnelle': _urlPhoto,
      };
      if (_isOng) {
        payload['nom_structure'] = _nomStructureCtrl.text.trim();
      } else {
        payload['numero_carte_professionnelle'] = _numeroCarteCtrl.text.trim();
        payload['document_diplome'] = _urlDiplome;
      }

      await AuthRepositoryImpl().submitCertification(payload);
      if (!mounted) return;
      setState(() => _statut = _CertStatut.enAttente);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.certSubmittedSuccess),
        backgroundColor: AppColors.emeraude,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nomStructureCtrl.dispose();
    _numeroCarteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _Header(),
          Expanded(child: _buildBody(s)),
        ],
      ),
    );
  }

  Widget _buildBody(AppStrings s) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }
    if (_error != null && _statut == _CertStatut.inconnu) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'GoogleSans', color: AppColors.grisMid)),
        ),
      );
    }
    if (!_isSpecialiste) {
      return _NotSpecialisteView(s: s);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatutBanner(statut: _statut, raison: _raisonRefus),
          const SizedBox(height: 20),
          if (_statut == _CertStatut.enAttente || _statut == _CertStatut.valide)
            _SubmittedRecap(
              s: s,
              isOng: _isOng,
              nomStructure: _nomStructureCtrl.text,
              numeroCarte: _numeroCarteCtrl.text,
              urlCartePro: _urlCartePro,
              urlDiplome: _urlDiplome,
              urlCni: _urlCni,
              urlPhoto: _urlPhoto,
            )
          else
            _buildForm(s),
        ],
      ),
    );
  }

  Widget _buildForm(AppStrings s) {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null) ...[
            _ErrorBanner(message: _error!),
            const SizedBox(height: 16),
          ],
          if (_isOng) ...[
            Text(s.certLabelNomStructure, style: AppTextStyles.inputLabel),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nomStructureCtrl,
              style: AppTextStyles.body,
              decoration: const InputDecoration(hintText: 'Ex : Réseau des Femmes Ambazonia'),
              validator: (v) => (v ?? '').trim().isEmpty ? s.errRequired : null,
            ),
          ] else ...[
            Text(s.certLabelNumeroCarte, style: AppTextStyles.inputLabel),
            const SizedBox(height: 6),
            TextFormField(
              controller: _numeroCarteCtrl,
              style: AppTextStyles.body,
              decoration: const InputDecoration(hintText: 'Ex : BAR-CM-2020-0142'),
              validator: (v) => (v ?? '').trim().isEmpty ? s.errRequired : null,
            ),
          ],
          const SizedBox(height: 24),
          Text(s.certDocsTitle,
              style: AppTextStyles.h3.copyWith(fontSize: 16, color: AppColors.bleuNuit)),
          const SizedBox(height: 12),
          _DocumentRow(
            label: _isOng ? s.certDocAgrement : s.certDocCartePro,
            url: _urlCartePro,
            uploading: _uploadingFields.contains('carte_pro'),
            onPick: () => _pickAndUpload('carte_pro'),
          ),
          if (!_isOng)
            _DocumentRow(
              label: s.certDocDiplome,
              url: _urlDiplome,
              uploading: _uploadingFields.contains('diplome'),
              onPick: () => _pickAndUpload('diplome'),
            ),
          _DocumentRow(
            label: s.certDocCni,
            url: _urlCni,
            uploading: _uploadingFields.contains('cni'),
            onPick: () => _pickAndUpload('cni'),
          ),
          _DocumentRow(
            label: s.certDocPhotoOpt,
            url: _urlPhoto,
            uploading: _uploadingFields.contains('photo'),
            onPick: () => _pickAndUpload('photo', imageOnly: true),
            optional: true,
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: (_submitting || _uploadingFields.isNotEmpty) ? null : _submit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _canSubmit()
                    ? const LinearGradient(colors: [AppColors.or, AppColors.orDark])
                    : LinearGradient(colors: [AppColors.grisLight, AppColors.grisMid]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: _canSubmit() ? const [AppColors.ombreOr] : null,
              ),
              child: _submitting
                  ? const Center(child: SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(color: AppColors.blanc, strokeWidth: 2.5),
                    ))
                  : Text(s.certBtnSubmit,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.btn.copyWith(color: AppColors.blanc)),
            ),
          ),
          const SizedBox(height: 12),
          Text(s.certFooterNote,
              style: AppTextStyles.bodySm.copyWith(
                fontSize: 12, color: AppColors.grisMid, height: 1.4,
              )),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
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
          padding: const EdgeInsets.fromLTRB(6, 4, 18, 18),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.go('/profil'),
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.blanc),
              ),
              Expanded(
                child: Text(s.certTitle,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 22,
                      fontWeight: FontWeight.w700, color: AppColors.blanc,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Statut banner ─────────────────────────────────────────────────────────────

class _StatutBanner extends StatelessWidget {
  const _StatutBanner({required this.statut, required this.raison});
  final _CertStatut statut;
  final String? raison;

  ({Color bg, Color fg, IconData icon, String Function(AppStrings) title, String Function(AppStrings) desc}) _cfg(_CertStatut s) {
    return switch (s) {
      _CertStatut.enAttente => (
        bg: const Color(0xFFFFF8E1),
        fg: AppColors.orDark,
        icon: Icons.hourglass_top_rounded,
        title: (l) => l.certStatutEnAttenteTitle,
        desc: (l) => l.certStatutEnAttenteDesc,
      ),
      _CertStatut.valide => (
        bg: AppColors.emeraudeLight,
        fg: AppColors.emeraude,
        icon: Icons.verified_rounded,
        title: (l) => l.certStatutValideTitle,
        desc: (l) => l.certStatutValideDesc,
      ),
      _CertStatut.rejete => (
        bg: AppColors.rougeLight,
        fg: AppColors.rouge,
        icon: Icons.cancel_outlined,
        title: (l) => l.certStatutRejeteTitle,
        desc: (l) => l.certStatutRejeteDesc,
      ),
      _ => (
        bg: const Color(0xFFF0F0F0),
        fg: AppColors.grisMid,
        icon: Icons.info_outline_rounded,
        title: (l) => l.certStatutNonSoumisTitle,
        desc: (l) => l.certStatutNonSoumisDesc,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cfg = _cfg(statut);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cfg.fg.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(cfg.icon, color: cfg.fg, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(cfg.title(s),
                    style: TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 16,
                      fontWeight: FontWeight.w700, color: cfg.fg,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(cfg.desc(s),
              style: const TextStyle(
                fontFamily: 'GoogleSans', fontSize: 13,
                color: AppColors.gris, height: 1.4,
              )),
          if (statut == _CertStatut.rejete && (raison ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blanc,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cfg.fg.withAlpha(40)),
              ),
              child: Text(raison!,
                  style: TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 13,
                    color: cfg.fg, fontStyle: FontStyle.italic,
                  )),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Document upload row ───────────────────────────────────────────────────────

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.label,
    required this.url,
    required this.uploading,
    required this.onPick,
    this.optional = false,
  });
  final String label;
  final String? url;
  final bool uploading;
  final VoidCallback onPick;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final uploaded = url != null && url!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: uploaded ? AppColors.emeraude.withAlpha(60) : const Color(0x14000000),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: uploaded ? AppColors.emeraude.withAlpha(30) : AppColors.orLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                uploaded ? Icons.check_rounded : Icons.description_outlined,
                color: uploaded ? AppColors.emeraude : AppColors.orDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 14,
                        fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
                      )),
                  const SizedBox(height: 2),
                  Text(
                    uploaded
                        ? s.certDocUploaded
                        : (optional ? s.certDocOptional : s.certDocPickHint),
                    style: TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 12,
                      color: uploaded ? AppColors.emeraude : AppColors.grisMid,
                    ),
                  ),
                ],
              ),
            ),
            uploading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orDark),
                  )
                : TextButton(
                    onPressed: onPick,
                    child: Text(uploaded ? s.certDocReplace : s.certDocPick,
                        style: TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: uploaded ? AppColors.bleuMid : AppColors.orDark,
                        )),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Submitted recap (read-only after soumission) ──────────────────────────────

class _SubmittedRecap extends StatelessWidget {
  const _SubmittedRecap({
    required this.s,
    required this.isOng,
    required this.nomStructure,
    required this.numeroCarte,
    required this.urlCartePro,
    required this.urlDiplome,
    required this.urlCni,
    required this.urlPhoto,
  });

  final AppStrings s;
  final bool isOng;
  final String nomStructure, numeroCarte;
  final String? urlCartePro, urlDiplome, urlCni, urlPhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.certRecapTitle,
              style: AppTextStyles.h3.copyWith(fontSize: 15, color: AppColors.bleuNuit)),
          const SizedBox(height: 12),
          if (isOng)
            _RecapRow(label: s.certLabelNomStructure, value: nomStructure)
          else
            _RecapRow(label: s.certLabelNumeroCarte, value: numeroCarte),
          _RecapRow(
            label: isOng ? s.certDocAgrement : s.certDocCartePro,
            value: (urlCartePro ?? '').isNotEmpty ? s.certDocUploaded : '—',
          ),
          if (!isOng)
            _RecapRow(
              label: s.certDocDiplome,
              value: (urlDiplome ?? '').isNotEmpty ? s.certDocUploaded : '—',
            ),
          _RecapRow(
            label: s.certDocCni,
            value: (urlCni ?? '').isNotEmpty ? s.certDocUploaded : '—',
          ),
          if ((urlPhoto ?? '').isNotEmpty)
            _RecapRow(label: s.certDocPhotoOpt, value: s.certDocUploaded),
        ],
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  const _RecapRow({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 13, color: AppColors.grisMid,
                )),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.gris,
                )),
          ),
        ],
      ),
    );
  }
}

class _NotSpecialisteView extends StatelessWidget {
  const _NotSpecialisteView({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.orLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.workspace_premium_outlined, size: 46, color: AppColors.orDark),
            ),
            const SizedBox(height: 20),
            Text(s.certNotSpecialisteTitle, textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(color: AppColors.bleuNuit)),
            const SizedBox(height: 8),
            Text(s.certNotSpecialisteDesc, textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.grisMid, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.rougeLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.rouge.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.rouge, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 13, color: AppColors.rouge,
                )),
          ),
        ],
      ),
    );
  }
}
