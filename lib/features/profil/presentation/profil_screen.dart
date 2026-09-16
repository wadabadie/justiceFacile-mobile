import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/locale_service.dart';
import '../../../core/services/voice_service.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/infrastructure/auth_repository_impl.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

const _regions = ['Centre', 'Littoral', 'Ouest', 'Sud-Ouest', 'Nord-Ouest',
    'Nord', 'Adamaoua', 'Est', 'Sud', 'Extrême-Nord'];

class _ProfilScreenState extends State<ProfilScreen> {
  final _repo = AuthRepositoryImpl();

  UserEntity? _user;
  int _nbDossiers = 0;
  bool _notificationsOn  = true;
  bool _voiceAssistantOn = VoiceService.instance.isEnabled;
  bool _twoFactorOn      = false;
  bool _loggingOut       = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Show cached data immediately, then refresh from API.
    final local = await _repo.restoreSession();
    if (mounted) setState(() => _user = local);
    await Future.wait([_fetchMe(), _fetchStats()]);
  }

  Future<void> _fetchMe() async {
    final u = await _repo.fetchMe();
    if (!mounted || u == null) return;
    setState(() {
      _user       = u;
      _twoFactorOn = u.deuxFaActif;
    });
  }

  Future<void> _fetchStats() async {
    try {
      final results = await Future.wait([
        ApiService.instance.get(ApiConstants.demandes),
        ApiService.instance.get(ApiConstants.dossiers),
      ]);
      final total = (results[0].data as List).length + (results[1].data as List).length;
      if (mounted) setState(() => _nbDossiers = total);
    } catch (_) {}
  }

  Future<void> _toggle2FA(bool val) async {
    setState(() => _twoFactorOn = val);
    try {
      await _repo.toggle2FA();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _twoFactorOn = !val);
      final code = e.response?.statusCode;
      final msg = (code == 404 || code == null)
          ? AppStrings.of(context).twoFaInProgress
          : ApiService.extractError(e.response?.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  Future<void> _showEditSheet() async {
    final u = _user;
    if (u == null) return;

    final firstCtrl  = TextEditingController(text: u.firstName);
    final lastCtrl   = TextEditingController(text: u.lastName);
    final phoneCtrl  = TextEditingController(text: u.phone ?? '');
    String? region   = u.region;
    bool saving      = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.blanc,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE1E7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(AppStrings.of(context).profilEditTitle,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 20,
                      fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
                    )),
                const SizedBox(height: 20),
                _SheetField(controller: firstCtrl, label: AppStrings.of(context).fieldFirstName, icon: Icons.person_outline_rounded),
                const SizedBox(height: 12),
                _SheetField(controller: lastCtrl,  label: AppStrings.of(context).fieldLastName,  icon: Icons.person_outline_rounded),
                const SizedBox(height: 12),
                _SheetField(controller: phoneCtrl, label: AppStrings.of(context).profilPhone, icon: Icons.phone_outlined,
                    inputType: TextInputType.phone),
                const SizedBox(height: 12),
                // Region dropdown
                DropdownButtonFormField<String>(
                  value: region,
                  decoration: InputDecoration(
                    labelText: AppStrings.of(context).profilRegion,
                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.orDark),
                    filled: true,
                    fillColor: AppColors.orLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(fontFamily: 'GoogleSans', color: AppColors.grisMid),
                  ),
                  items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r,
                      style: const TextStyle(fontFamily: 'GoogleSans')))).toList(),
                  onChanged: (v) => setSheet(() => region = v),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving ? null : () async {
                      setSheet(() => saving = true);
                      final nav = Navigator.of(ctx);
                      try {
                        await _repo.updateMe(
                          firstName: firstCtrl.text.trim(),
                          lastName:  lastCtrl.text.trim(),
                          phone:     phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                          region:    region,
                        );
                        if (!mounted) return;
                        nav.pop();
                        await _fetchMe();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(AppStrings.of(context).profilUpdated),
                            backgroundColor: AppColors.emeraude,
                          ));
                        }
                      } on Exception catch (e) {
                        setSheet(() => saving = false);
                        if (!mounted) return;
                        final msg = e.toString().contains('endpoint_indisponible')
                            ? 'La modification du profil n\'est pas encore disponible (backend en cours de développement).'
                            : e is DioException
                                ? ApiService.extractError(e.response?.data)
                                : 'Une erreur est survenue.';
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(msg),
                          backgroundColor: AppColors.rouge,
                          duration: const Duration(seconds: 4),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bleuNuit,
                      foregroundColor: AppColors.blanc,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: saving
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: AppColors.blanc, strokeWidth: 2))
                        : Text(AppStrings.of(context).profilSave,
                            style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    firstCtrl.dispose();
    lastCtrl.dispose();
    phoneCtrl.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final s = AppStrings.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(s.logoutTitle,
              style: const TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w700, color: AppColors.bleuNuit)),
          content: Text(s.logoutMsg,
              style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 16, color: AppColors.gris)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(s.btnCancel,
                  style: const TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w600, color: AppColors.grisMid)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(s.logoutBtn,
                  style: const TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w700, color: AppColors.rouge)),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    setState(() => _loggingOut = true);
    await _repo.logout();
    if (mounted) context.go('/');
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final s = AppStrings.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(s.deleteTitle,
              style: const TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w700, color: AppColors.rouge)),
          content: Text(
            s.deleteMsg,
            style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15, color: AppColors.gris),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(s.btnCancel,
                  style: const TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w600, color: AppColors.grisMid)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(s.deleteBtn,
                  style: const TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w700, color: AppColors.rouge)),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await _repo.deleteAccount();
      await _repo.logout();
      if (mounted) context.go('/');
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data)),
        backgroundColor: AppColors.rouge,
      ));
    }
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
    final u = _user;
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _ProfileHeader(
            initials:    u?.initials ?? '?',
            name:        u != null ? '${u.firstName} ${u.lastName}'.trim() : '—',
            role:        u != null ? _roleLabel(u.role) : '',
            nbDossiers:  _nbDossiers,
            onEditTap:   _showEditSheet,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
              child: Column(
                children: [
                  // ── Informations personnelles ──
                  _Section(
                    title: s.profilSectionPersonal,
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: s.profilFullName,
                        value: u != null ? '${u.firstName} ${u.lastName}'.trim() : '—',
                        onTap: _showEditSheet,
                      ),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: s.profilEmail,
                        value: u?.email ?? '—',
                        onTap: () {},
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: s.profilPhone,
                        value: u?.phone?.isNotEmpty == true ? u!.phone! : s.profilPhoneEmpty,
                        onTap: _showEditSheet,
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: s.profilRegion,
                        value: u?.region?.isNotEmpty == true ? u!.region! : s.profilRegionEmpty,
                        onTap: _showEditSheet,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Préférences ──
                  _Section(
                    title: s.profilSectionPreferences,
                    children: [
                      _ToggleRow(
                        icon: Icons.notifications_outlined,
                        label: s.profilNotifications,
                        value: _notificationsOn,
                        onChanged: (v) => setState(() => _notificationsOn = v),
                      ),
                      _LanguageRow(),
                      _ToggleRow(
                        icon: Icons.mic_outlined,
                        label: s.profilVoiceAssistant,
                        value: _voiceAssistantOn,
                        onChanged: (v) {
                          setState(() => _voiceAssistantOn = v);
                          VoiceService.instance.setEnabled(v);
                        },
                        isLast: true,
                        infoText: s.profilVoiceInfo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Sécurité & Confidentialité ──
                  _Section(
                    title: s.profilSectionSecurity,
                    children: [
                      _ToggleRow(
                        icon: Icons.shield_outlined,
                        label: s.profilTwoFactor,
                        value: _twoFactorOn,
                        onChanged: _toggle2FA,
                      ),
                      _InfoRow(
                        icon: Icons.description_outlined,
                        label: s.profilPrivacy,
                        value: s.btnConsult,
                        onTap: () => context.go('/politique-confidentialite'),
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Déconnexion + suppression ──
                  _Section(
                    children: [
                      _LogoutRow(loading: _loggingOut, onTap: _logout),
                      _DeleteRow(onTap: _deleteAccount),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(s.profilVersion,
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
    required this.nbDossiers,
    required this.onEditTap,
  });
  final String initials, name, role;
  final int nbDossiers;
  final VoidCallback onEditTap;

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
                      Text(AppStrings.of(context).profilTitle,
                          style: AppTextStyles.h3.copyWith(color: AppColors.blanc)),
                      GestureDetector(
                        onTap: onEditTap,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit_outlined, color: AppColors.blanc, size: 18),
                        ),
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
                      _StatItem(value: '$nbDossiers', label: 'Dossiers'),
                      _StatDivider(),
                      _StatItem(value: '0',            label: 'Consultations'),
                      _StatDivider(),
                      _StatItem(value: '—',            label: 'Satisfaction'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Decorative gold orb top-right — IgnorePointer so it doesn't block the edit button
        Positioned(
          top: 0, right: -50,
          child: IgnorePointer(
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

// ── Delete account row ────────────────────────────────────────────────────────

class _DeleteRow extends StatelessWidget {
  const _DeleteRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x0D000000))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.rougeLight,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.rouge),
            ),
            const SizedBox(width: 14),
            Text(AppStrings.of(context).profilDeleteAccount,
                style: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 16,
                  fontWeight: FontWeight.w600, color: AppColors.rouge,
                )),
          ],
        ),
      ),
    );
  }
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

// ── Language row ──────────────────────────────────────────────────────────────

class _LanguageRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isFr = LocaleService.instance.isFrench;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0D000000))),
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: AppColors.orLight, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.language_outlined, size: 18, color: AppColors.orDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.profilLanguage,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 13,
                      color: AppColors.grisMid, fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 2),
                Text(isFr ? 'Français' : 'English',
                    style: const TextStyle(
                      fontFamily: 'GoogleSans', fontSize: 16,
                      fontWeight: FontWeight.w600, color: AppColors.bleuNuit,
                    )),
              ],
            ),
          ),
          _LangChip(label: 'FR', active: isFr,
              onTap: () => LocaleService.instance.setLocale(const Locale('fr'))),
          const SizedBox(width: 8),
          _LangChip(label: 'EN', active: !isFr,
              onTap: () => LocaleService.instance.setLocale(const Locale('en'))),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.bleuNuit : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppColors.bleuNuit : const Color(0xFFDDE1E7),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontFamily: 'GoogleSans', fontSize: 13, fontWeight: FontWeight.w700,
              color: active ? AppColors.blanc : AppColors.grisMid,
            )),
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
    this.infoText,
  });
  final IconData icon;
  final String label;
  final bool value, isLast;
  final ValueChanged<bool> onChanged;
  final String? infoText;

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(label,
            style: const TextStyle(
              fontFamily: 'GoogleSans',
              fontWeight: FontWeight.w700,
              color: AppColors.bleuNuit,
            )),
        content: Text(infoText!,
            style: const TextStyle(
              fontFamily: 'GoogleSans',
              fontSize: 15,
              color: AppColors.gris,
              height: 1.5,
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK',
                style: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontWeight: FontWeight.w700,
                  color: AppColors.bleuNuit,
                )),
          ),
        ],
      ),
    );
  }

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
                Row(
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 13,
                          color: AppColors.grisMid,
                          fontWeight: FontWeight.w500,
                        )),
                    if (infoText != null) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _showInfo(context),
                        child: const Icon(Icons.info_outline_rounded,
                            size: 15, color: AppColors.grisMid),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value ? AppStrings.of(context).profilEnabled : AppStrings.of(context).profilDisabled,
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

// ── Sheet text field ──────────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.inputType,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? inputType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15, color: AppColors.bleuNuit),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.orDark),
        filled: true,
        fillColor: AppColors.orLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(fontFamily: 'GoogleSans', color: AppColors.grisMid),
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
            Text(AppStrings.of(context).profilLogout,
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
