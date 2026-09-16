import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../infrastructure/auth_repository_impl.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  Future<void> _submit(AppStrings s) async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthRepositoryImpl().requestPasswordReset(_emailCtrl.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (_) {
      if (mounted) setState(() => _error = s.forgotError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.go('/login'),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.bleuNuit),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [AppColors.ombreOr],
                  ),
                  child: const Icon(Icons.lock_reset_rounded, color: AppColors.blanc, size: 36),
                ),
                const SizedBox(height: 24),
                Text(s.forgotTitle, style: AppTextStyles.h1),
                const SizedBox(height: 6),
                Text(s.forgotSubtitle, style: AppTextStyles.bodySm),
                const SizedBox(height: 28),
                if (_sent) _SuccessCard(s: s) else _buildForm(s),
              ],
            ),
          ),
        ),
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
          Text(s.forgotEmailHint, style: AppTextStyles.inputLabel),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.body,
            decoration: const InputDecoration(hintText: 'nom@exemple.com'),
            validator: (v) {
              final val = (v ?? '').trim();
              if (val.isEmpty) return s.errRequired;
              if (!val.contains('@') || !val.contains('.')) return s.errEmail;
              return null;
            },
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _loading ? null : () => _submit(s),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [AppColors.ombreOr],
              ),
              child: _loading
                  ? const Center(child: SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(color: AppColors.blanc, strokeWidth: 2.5),
                    ))
                  : Text(s.forgotBtnSend,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.btn.copyWith(color: AppColors.blanc)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.emeraudeLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.emeraude.withAlpha(60)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mark_email_read_rounded, color: AppColors.emeraude, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.forgotSuccessTitle,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 16,
                          fontWeight: FontWeight.w700, color: AppColors.emeraude,
                        )),
                    const SizedBox(height: 6),
                    Text(s.forgotSuccessDesc,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 13,
                          color: AppColors.gris, height: 1.4,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.blanc,
              border: Border.all(color: AppColors.bleuNuit.withAlpha(80)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(s.forgotSuccessBack,
                textAlign: TextAlign.center,
                style: AppTextStyles.btn.copyWith(color: AppColors.bleuNuit)),
          ),
        ),
      ],
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
