import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../infrastructure/auth_repository_impl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _passVisible = false;
  bool _terms = false;
  bool _loading = false;
  String? _error;
  String _role = 'citoyen';

  Future<void> _submit(AppStrings s) async {
    if (!_form.currentState!.validate()) return;
    if (!_terms) {
      setState(() => _error = s.termsAccept);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final email = _emailCtrl.text.trim();
      await AuthRepositoryImpl().register(
        firstName: _firstCtrl.text.trim(),
        lastName: _lastCtrl.text.trim(),
        email: email,
        password: _passCtrl.text,
        role: _role,
      );
      // Redirect to email verification — pass email so the screen knows where the code was sent
      if (mounted) context.go('/verify-email', extra: email);
    } catch (_) {
      setState(() => _error = s.errGeneric);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose();
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
            _RegisterHeader(s: s),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null) ...[
                      _ErrorBanner(message: _error!),
                      const SizedBox(height: 16),
                    ],

                    // Prénom / Nom
                    Row(children: [
                      Expanded(child: _Field(
                        ctrl: _firstCtrl, label: s.fieldFirstName, hint: 'Marie',
                        validator: (v) => (v == null || v.isEmpty) ? s.errRequired : null,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _Field(
                        ctrl: _lastCtrl, label: s.fieldLastName, hint: 'Dupont',
                        validator: (v) => (v == null || v.isEmpty) ? s.errRequired : null,
                      )),
                    ]),
                    const SizedBox(height: 14),

                    _Field(
                      ctrl: _emailCtrl, label: s.fieldEmail,
                      hint: 'nom@email.com',
                      type: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return s.errRequired;
                        if (!v.contains('@')) return s.errEmail;
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _Field(
                      ctrl: _passCtrl, label: s.fieldPassword, hint: '••••••••',
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
                    const SizedBox(height: 14),

                    _Field(
                      ctrl: _confirmCtrl, label: s.fieldConfirmPassword, hint: '••••••••',
                      obscure: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return s.errRequired;
                        if (v != _passCtrl.text) return s.errPasswordMatch;
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Rôle
                    Text(s.fieldRole, style: AppTextStyles.inputLabel),
                    const SizedBox(height: 8),
                    _RoleSelector(
                      roles: [
                        (s.roleCitoyen, 'citoyen'),
                        (s.roleJuriste, 'juriste'),
                        (s.rolePsychologue, 'psychologue'),
                        (s.roleOng, 'ong'),
                      ],
                      selected: _role,
                      onChanged: (r) => setState(() => _role = r),
                    ),
                    const SizedBox(height: 18),

                    // CGU
                    GestureDetector(
                      onTap: () => setState(() => _terms = !_terms),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: _terms ? AppColors.orLight : Colors.transparent,
                              border: Border.all(color: AppColors.or, width: 2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: _terms
                                ? const Icon(Icons.check, size: 13, color: AppColors.orDark)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(s.termsAccept,
                                style: AppTextStyles.bodySm.copyWith(height: 1.5)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _PrimaryButton(label: s.btnRegister, loading: _loading, onTap: () => _submit(s)),
                    const SizedBox(height: 20),

                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(s.registerHasAccount,
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.orDark, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 24),
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

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.bleuNuit, AppColors.bleuMid],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 52, 24, 48),
          child: Column(
            children: [
              SizedBox(
                width: 56, height: 56,
                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 14),
              Text(s.registerTitle, style: AppTextStyles.h1White),
              const SizedBox(height: 4),
              Text(s.registerSubtitle,
                  style: AppTextStyles.bodyWhite.copyWith(fontSize: 12)),
            ],
          ),
        ),
        Positioned(
          bottom: -1, left: 0, right: 0,
          child: ClipPath(
            clipper: _WaveClipper(),
            child: Container(height: 36, color: AppColors.fond),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.type,
    this.obscure = false,
    this.suffix,
    this.validator,
  });
  final TextEditingController ctrl;
  final String label, hint;
  final TextInputType? type;
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
          controller: ctrl,
          keyboardType: type,
          obscureText: obscure,
          style: AppTextStyles.body,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
          validator: validator,
        ),
      ],
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.roles, required this.selected, required this.onChanged});
  final List<(String, String)> roles;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: roles.map((r) {
        final active = selected == r.$2;
        return GestureDetector(
          onTap: () => onChanged(r.$2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: active ? AppColors.bleuNuit : AppColors.blanc,
              border: Border.all(
                color: active ? AppColors.bleuNuit : const Color(0x1A000000),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(r.$1,
                style: AppTextStyles.labelSm.copyWith(
                  color: active ? AppColors.blanc : AppColors.gris,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                )),
          ),
        );
      }).toList(),
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
          Expanded(child: Text(message,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.rouge))),
        ],
      ),
    );
  }
}
