import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../infrastructure/auth_repository_impl.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _passVisible = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit(AppStrings s) async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthRepositoryImpl().login(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) context.go('/home');
    } catch (_) {
      setState(() { _error = s.errCredentials; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header bleu
            _LoginHeader(),

            // Corps du formulaire
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.loginTitle, style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Text(s.loginSubtitle, style: AppTextStyles.bodySm),
                    const SizedBox(height: 24),

                    if (_error != null) ...[
                      _ErrorBanner(message: _error!),
                      const SizedBox(height: 16),
                    ],

                    _InputField(
                      controller: _emailCtrl,
                      label: s.fieldEmail,
                      hint: 'nom@email.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return s.errRequired;
                        if (!v.contains('@')) return s.errEmail;
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _InputField(
                      controller: _passCtrl,
                      label: s.fieldPassword,
                      hint: '••••••••',
                      obscure: !_passVisible,
                      suffix: IconButton(
                        icon: Icon(
                          _passVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.grisMid, size: 20,
                        ),
                        onPressed: () => setState(() => _passVisible = !_passVisible),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return s.errRequired;
                        if (v.length < 8) return s.errPasswordMin;
                        return null;
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(s.loginForgot,
                            style: AppTextStyles.labelSm.copyWith(color: AppColors.orDark)),
                      ),
                    ),

                    const SizedBox(height: 8),
                    _PrimaryButton(
                      label: s.btnLogin,
                      loading: _loading,
                      onTap: () => _submit(s),
                    ),

                    const SizedBox(height: 20),
                    _Divider(label: s.orSeparator),
                    const SizedBox(height: 20),

                    _GoogleButton(label: s.continueGoogle),

                    const SizedBox(height: 28),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/register'),
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodySm,
                            children: [
                              TextSpan(text: '${s.loginNoAccount} '),
                              TextSpan(
                                text: s.btnSignUp,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.orDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.bleuNuit, AppColors.bleuMid],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 52),
          child: Column(
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [AppColors.ombreOr],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 14),
              RichText(
                text: const TextSpan(children: [
                  TextSpan(text: 'Justice ', style: AppTextStyles.h1White),
                  TextSpan(
                    text: 'Facile',
                    style: TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 22, fontWeight: FontWeight.w700,
                      color: AppColors.orPale,
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
        // Vague basse
        Positioned(
          bottom: -1, left: 0, right: 0,
          child: ClipPath(
            clipper: _WaveClipper(),
            child: Container(height: 40, color: AppColors.fond),
          ),
        ),
      ],
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.validator,
  });
  final TextEditingController controller;
  final String label, hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap, this.loading = false});
  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.or, AppColors.orDark]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [AppColors.ombreOr],
        ),
        child: loading
            ? const Center(child: SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: AppColors.blanc, strokeWidth: 2.5),
              ))
            : Text(label,
                textAlign: TextAlign.center,
                style: AppTextStyles.btn.copyWith(color: AppColors.blanc)),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider(color: Color(0x26000000))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label, style: AppTextStyles.bodySm),
      ),
      const Expanded(child: Divider(color: Color(0x26000000))),
    ]);
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        border: Border.all(color: const Color(0x1A000000)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF4285F4), Color(0xFF34A853)]),
            ),
            child: const Center(
              child: Text('G', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.label.copyWith(color: AppColors.gris)),
        ],
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
          const Icon(Icons.error_outline, color: AppColors.rouge, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: AppTextStyles.bodySm.copyWith(color: AppColors.rouge))),
        ],
      ),
    );
  }
}
