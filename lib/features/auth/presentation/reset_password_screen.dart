import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../infrastructure/auth_repository_impl.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});
  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _codeCtrls = List.generate(6, (_) => TextEditingController());
  final _codeNodes = List.generate(6, (_) => FocusNode());
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _pwdVisible = false;
  bool _confirmVisible = false;
  bool _loading = false;
  bool _resending = false;
  bool _done = false;
  String? _error;

  String get _code => _codeCtrls.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length >= 6) {
      for (int i = 0; i < 6; i++) {
        _codeCtrls[i].text = digits[i];
      }
      FocusScope.of(context).requestFocus(_codeNodes[5]);
      setState(() {});
      return;
    }

    if (digits.length > 1) {
      _codeCtrls[index].text = digits[digits.length - 1];
      _codeCtrls[index].selection = const TextSelection.collapsed(offset: 1);
      if (index < 5) FocusScope.of(context).requestFocus(_codeNodes[index + 1]);
      setState(() {});
      return;
    }

    if (digits.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(_codeNodes[index + 1]);
    }
    if (digits.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_codeNodes[index - 1]);
    }
    setState(() {});
  }

  Future<void> _submit(AppStrings s) async {
    if (!_form.currentState!.validate()) return;
    if (_code.length < 6) {
      setState(() => _error = s.codeIncomplete);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthRepositoryImpl().confirmPasswordReset(
        email: widget.email,
        code: _code,
        newPassword: _pwdCtrl.text,
      );
      if (mounted) setState(() => _done = true);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      final display = msg.toLowerCase().contains('expir') ||
                      msg.toLowerCase().contains('tentatives')
          ? s.resetErrExpired
          : msg.toLowerCase().contains('invalide')
              ? s.resetErrInvalidCode
              : s.resetErrGeneric;
      if (mounted) setState(() => _error = display);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend(AppStrings s) async {
    setState(() { _resending = true; _error = null; });
    try {
      await AuthRepositoryImpl().requestPasswordReset(widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s.codeResent),
          backgroundColor: AppColors.emeraude,
        ));
      }
    } catch (_) {
      if (mounted) setState(() => _error = s.forgotError);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  void dispose() {
    for (final c in _codeCtrls) { c.dispose(); }
    for (final f in _codeNodes) { f.dispose(); }
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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.go('/forgot-password'),
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
                  child: const Icon(Icons.password_rounded, color: AppColors.blanc, size: 36),
                ),
                const SizedBox(height: 24),
                Text(s.resetTitle, style: AppTextStyles.h1),
                const SizedBox(height: 6),
                Text(
                  s.resetSubtitleOtp(widget.email),
                  style: AppTextStyles.bodySm,
                ),
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
          Text(s.resetCodeLabel, style: AppTextStyles.inputLabel),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) => _DigitBox(
                controller: _codeCtrls[i],
                focusNode: _codeNodes[i],
                onChanged: (v) => _onDigitChanged(i, v),
                autofocus: i == 0,
              )),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _resending ? null : () => _resend(s),
              icon: _resending
                  ? const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orDark),
                    )
                  : const Icon(Icons.refresh_rounded, size: 16, color: AppColors.orDark),
              label: Text(s.resetResendCode,
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.orDark)),
            ),
          ),
          const SizedBox(height: 12),
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

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.autofocus,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        border: Border.all(color: const Color(0x33000000)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontFamily: 'GoogleSans', fontSize: 22,
          fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
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
