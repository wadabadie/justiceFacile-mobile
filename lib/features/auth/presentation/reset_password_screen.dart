import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../infrastructure/auth_repository_impl.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.uid, required this.token});
  final String uid;
  final String token;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _pwdVisible = false;
  bool _confirmVisible = false;
  bool _loading = false;
  bool _done = false;
  String? _error;

  Future<void> _submit(AppStrings s) async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthRepositoryImpl().confirmPasswordReset(
        uid: widget.uid,
        token: widget.token,
        newPassword: _pwdCtrl.text,
      );
      if (mounted) setState(() => _done = true);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      final display = msg.toLowerCase().contains('invalide') ||
                      msg.toLowerCase().contains('expir')
          ? s.resetErrExpired
          : s.resetErrGeneric;
      if (mounted) setState(() => _error = display);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _pwdCtrl.dispose();
    _confirmCtrl.dispose();
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [AppColors.ombreOr],
                  ),
                  child: const Icon(Icons.password_rounded, color: AppColors.blanc, size: 36),
                ),
                const SizedBox(height: 24),
                Text(s.resetTitle, style: AppTextStyles.h1),
                const SizedBox(height: 6),
                Text(s.resetSubtitle, style: AppTextStyles.bodySm),
                const SizedBox(height: 28),
                if (_done) _SuccessCard(s: s) else _buildForm(s),
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
          Text(s.resetNewPwdHint, style: AppTextStyles.inputLabel),
          const SizedBox(height: 6),
          TextFormField(
            controller: _pwdCtrl,
            obscureText: !_pwdVisible,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(_pwdVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.grisMid),
                onPressed: () => setState(() => _pwdVisible = !_pwdVisible),
              ),
            ),
            validator: (v) {
              final val = v ?? '';
              if (val.isEmpty) return s.errRequired;
              if (val.length < 8) return s.errPasswordMin;
              return null;
            },
          ),
          const SizedBox(height: 18),
          Text(s.resetConfirmPwdHint, style: AppTextStyles.inputLabel),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: !_confirmVisible,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(_confirmVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.grisMid),
                onPressed: () => setState(() => _confirmVisible = !_confirmVisible),
              ),
            ),
            validator: (v) {
              if ((v ?? '').isEmpty) return s.errRequired;
              if (v != _pwdCtrl.text) return s.errPasswordMatch;
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
                  : Text(s.resetBtnConfirm,
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
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.emeraude, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.resetSuccessTitle,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 16,
                          fontWeight: FontWeight.w700, color: AppColors.emeraude,
                        )),
                    const SizedBox(height: 6),
                    Text(s.resetSuccessDesc,
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [AppColors.ombreOr],
            ),
            child: Text(s.resetSuccessBackLogin,
                textAlign: TextAlign.center,
                style: AppTextStyles.btn.copyWith(color: AppColors.blanc)),
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
