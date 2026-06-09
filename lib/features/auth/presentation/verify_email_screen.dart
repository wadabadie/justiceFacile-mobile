import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../infrastructure/auth_repository_impl.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});
  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  // 6 separate controllers for each digit box
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes  = List.generate(6, (_) => FocusNode());

  bool _loading  = false;
  bool _resending = false;
  String? _error;

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _submit() async {
    if (_code.length < 6) {
      setState(() => _error = AppStrings.of(context).codeIncomplete);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthRepositoryImpl().verifyEmail(widget.email, _code);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = AppStrings.of(context).codeInvalid);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() { _resending = true; _error = null; });
    try {
      await AuthRepositoryImpl().resendVerificationCode(widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).codeResent),
            backgroundColor: AppColors.emeraude,
          ),
        );
      }
    } catch (_) {
      setState(() => _error = AppStrings.of(context).errGeneric);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      // Auto-advance to next field
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      // Auto-go back on delete
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 84, height: 84,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.bleuNuit, AppColors.bleuMid]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [AppColors.ombre],
                ),
                child: const Icon(Icons.mark_email_read_outlined, color: AppColors.orPale, size: 40),
              ),
              const SizedBox(height: 28),

              Text(s.verifyEmailTitle, style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                '${s.verifyEmailDesc} ${widget.email}',
                style: AppTextStyles.body.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 6-digit code input
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) => _DigitBox(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  onChanged: (v) => _onDigitChanged(i, v),
                  autofocus: i == 0,
                )),
              ),
              const SizedBox(height: 12),

              if (_error != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.rougeLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_error!, style: TextStyle(color: AppColors.rouge, fontFamily: 'GoogleSans', fontSize: 17)),
                ),
              const SizedBox(height: 32),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _loading
                          ? const CircularProgressIndicator(color: AppColors.blanc, strokeWidth: 2.5)
                          : Text(s.verifyEmailBtn, style: AppTextStyles.btn.copyWith(color: AppColors.blanc)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resend link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s.codeNotReceived, style: AppTextStyles.bodySm),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _resending ? null : _resend,
                    child: _resending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(s.resendCode,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.bleuNuit,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            )),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Back to login
              TextButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.arrow_back, color: AppColors.gris, size: 18),
                label: Text(s.backToLogin,
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.gris)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.autofocus = false,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontFamily: 'GoogleSans',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.bleuNuit,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.blanc,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDE1E7), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.or, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
