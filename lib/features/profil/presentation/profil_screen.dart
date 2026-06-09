import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/infrastructure/auth_repository_impl.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  UserEntity? _user;
  bool _notificationsOn   = true;
  bool _voiceAssistantOn  = false;
  bool _twoFactorOn       = true;
  bool _loggingOut        = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthRepositoryImpl().restoreSession();
    if (mounted) setState(() => _user = user);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Se déconnecter',
          style: TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w700, color: AppColors.bleuNuit),
        ),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter de votre compte ?',
          style: TextStyle(fontFamily: 'GoogleSans', fontSize: 16, color: AppColors.gris),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler',
                style: TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w600, color: AppColors.grisMid)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Se déconnecter',
                style: TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w700, color: AppColors.rouge)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _loggingOut = true);
    await AuthRepositoryImpl().logout();
    if (mounted) context.go('/');
  }

  String get _initials {
    if (_user == null) return '?';
    final f = _user!.firstName.isNotEmpty ? _user!.firstName[0] : '';
    final l = _user!.lastName.isNotEmpty  ? _user!.lastName[0]  : '';
    return '$f$l'.toUpperCase().isEmpty ? '?' : '$f$l'.toUpperCase();
  }

  String _roleLabel(String role) {
    const map = {
      'citoyen':     'Citoyen(ne)',
      'victime_vbg': 'Victime VBG',
      'juriste':     'Juriste / Avocat',
      'psychologue': 'Psychologue',
      'ong':         'ONG / Association',
      'admin':       'Administrateur(trice)',
    };
    return map[role] ?? role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _ProfileHeader(
            initials:   _initials,
            name:       _user != null ? '${_user!.firstName} ${_user!.lastName}'.trim() : '—',
            role:       _user != null ? _roleLabel(_user!.role) : '',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
              child: Column(
                children: [
                  // ── Informations personnelles ──
                  _Section(
                    title: 'Informations personnelles',
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Nom complet',
                        value: _user != null
                            ? '${_user!.firstName} ${_user!.lastName}'.trim()
                            : '—',
                        onTap: () {},
                      ),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: _user?.email ?? '—',
                        onTap: () {},
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Téléphone',
                        value: '+237 6XX XXX XXX',
                        onTap: () {},
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Région',
                        value: 'Centre (Yaoundé)',
                        onTap: () {},
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Préférences ──
                  _Section(
                    title: 'Préférences',
                    children: [
                      _ToggleRow(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        value: _notificationsOn,
                        onChanged: (v) => setState(() => _notificationsOn = v),
                      ),
                      _InfoRow(
                        icon: Icons.language_outlined,
                        label: 'Langue',
                        value: 'Français',
                        onTap: () {},
                      ),
                      _ToggleRow(
                        icon: Icons.mic_outlined,
                        label: 'Assistant vocal',
                        value: _voiceAssistantOn,
                        onChanged: (v) => setState(() => _voiceAssistantOn = v),
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Sécurité & Confidentialité ──
                  _Section(
                    title: 'Sécurité & Confidentialité',
                    children: [
                      _InfoRow(
                        icon: Icons.lock_outline_rounded,
                        label: 'Mot de passe',
                        value: 'Modifier',
                        onTap: () {},
                      ),
                      _ToggleRow(
                        icon: Icons.shield_outlined,
                        label: 'Double authentification',
                        value: _twoFactorOn,
                        onChanged: (v) => setState(() => _twoFactorOn = v),
                      ),
                      _InfoRow(
                        icon: Icons.description_outlined,
                        label: 'Politique de confidentialité',
                        value: 'Consulter',
                        onTap: () {},
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Déconnexion ──
                  _Section(
                    children: [
                      _LogoutRow(loading: _loggingOut, onTap: _logout),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Version
                  Text('Justice Facile · v1.0.0',
                      style: AppTextStyles.bodySm.copyWith(
                        fontSize: 14,
                        color: AppColors.grisMid.withAlpha(120),
                      )),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.profil),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.role,
  });
  final String initials, name, role;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient background
        Container(
          width: double.infinity,
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
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 52),
              child: Column(
                children: [
                  // Top bar — title + settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mon Profil',
                          style: AppTextStyles.h3.copyWith(color: AppColors.blanc)),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_outlined, color: AppColors.blanc, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar
                  Container(
                    width: 84, height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.or, width: 3),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.or, AppColors.orDark],
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x55C9920A), blurRadius: 20, offset: Offset(0, 8)),
                      ],
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blanc,
                          )),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(name,
                      style: AppTextStyles.h2.copyWith(color: AppColors.blanc, fontSize: 22)),
                  const SizedBox(height: 6),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(role,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 13,
                          color: Color(0xB3FFFFFF),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  const SizedBox(height: 18),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(value: '3',   label: 'Dossiers'),
                      _StatDivider(),
                      _StatItem(value: '0',   label: 'Consultations'),
                      _StatDivider(),
                      _StatItem(value: '—',   label: 'Satisfaction'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Decorative gold orb top-right
        Positioned(
          top: 0, right: -50,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.or.withAlpha(40), Colors.transparent,
              ]),
            ),
          ),
        ),

        // Wave bottom clip
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

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value, label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontFamily: 'GoogleSans',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.orPale,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
              fontFamily: 'GoogleSans',
              fontSize: 12,
              color: Color(0x80FFFFFF),
            )),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1, height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        color: Colors.white.withAlpha(30),
      );
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.moveTo(0, size.height);
    p.quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(_) => false;
}

// ── Section card ──────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.children, this.title});
  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F6F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Text(
                title!.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grisMid,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

// ── Info row (tappable with › arrow) ─────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.isLast = false,
  });
  final IconData icon;
  final String label, value;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0x0D000000))),
        ),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.orLight,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: AppColors.orDark),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 13,
                        color: AppColors.grisMid,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bleuNuit,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grisLight, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Toggle row ────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });
  final IconData icon;
  final String label;
  final bool value, isLast;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0x0D000000))),
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.orLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: AppColors.orDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      color: AppColors.grisMid,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 2),
                Text(
                  value ? 'Activé' : 'Désactivé',
                  style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: value ? AppColors.emeraude : AppColors.grisLight,
                  ),
                ),
              ],
            ),
          ),
          // Custom toggle switch
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48, height: 26,
              decoration: BoxDecoration(
                color: value ? AppColors.bleuNuit : const Color(0xFFDDE1E7),
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20, height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: AppColors.blanc,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logout row ────────────────────────────────────────────────────────────────

class _LogoutRow extends StatelessWidget {
  const _LogoutRow({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.rougeLight,
                borderRadius: BorderRadius.circular(9),
              ),
              child: loading
                  ? const Center(
                      child: SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          color: AppColors.rouge, strokeWidth: 2,
                        ),
                      ),
                    )
                  : const Icon(Icons.logout_rounded, size: 18, color: AppColors.rouge),
            ),
            const SizedBox(width: 14),
            Text('Se déconnecter',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.rouge,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }
}
