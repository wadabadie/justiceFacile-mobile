import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class VBGScreen extends StatefulWidget {
  const VBGScreen({super.key});

  @override
  State<VBGScreen> createState() => _VBGScreenState();
}

class _VBGScreenState extends State<VBGScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _dial(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _VBGHeader(onBack: () => context.go('/home')),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SOSButton(controller: _pulseCtrl, onTap: () => _dial('117')),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Appuyez pour appeler la Police nationale',
                      style: TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 14,
                        color: AppColors.grisMid,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  const _SectionTitle(text: "Besoin d'aide ?"),
                  const SizedBox(height: 14),
                  const _QuickActionsGrid(),
                  const SizedBox(height: 34),
                  const _SectionTitle(text: "Numéros d'urgence"),
                  const SizedBox(height: 14),
                  _EmergencyTile(
                    icon: Icons.local_police_rounded,
                    label: 'Police nationale',
                    number: '117',
                    onCall: () => _dial('117'),
                  ),
                  _EmergencyTile(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Pompiers',
                    number: '118',
                    onCall: () => _dial('118'),
                  ),
                  _EmergencyTile(
                    icon: Icons.medical_services_rounded,
                    label: 'SAMU',
                    number: '119',
                    onCall: () => _dial('119'),
                  ),
                  const SizedBox(height: 34),
                  const _RightsCard(),
                  const SizedBox(height: 20),
                  const _AnonymityBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _VBGHeader extends StatelessWidget {
  const _VBGHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B0000), Color(0xFFC0392B), Color(0xFF1A2E4A)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.blanc,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: AppColors.blanc,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MODULE VBG',
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xA0FFFFFF),
                          letterSpacing: 2.5,
                        ),
                      ),
                      Text(
                        'Protection & Accompagnement',
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blanc,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withAlpha(35)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded, color: Color(0xCCFFFFFF), size: 14),
                    SizedBox(width: 7),
                    Text(
                      'Espace confidentiel · Signalement anonyme disponible',
                      style: TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 13,
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bouton SOS animé ─────────────────────────────────────────────────────────

class _SOSButton extends StatelessWidget {
  const _SOSButton({required this.controller, required this.onTap});
  final AnimationController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 240,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final v = controller.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                _ring(v, 240, 0.0, 0.18),
                _ring((v + 0.33) % 1.0, 200, 0.0, 0.22),
                _ring((v + 0.66) % 1.0, 168, 0.0, 0.28),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFE85D52), AppColors.rouge],
                        center: Alignment(-0.3, -0.3),
                        radius: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rouge.withAlpha(110),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sos_rounded, color: AppColors.blanc, size: 46),
                        SizedBox(height: 2),
                        Text(
                          'APPELER',
                          style: TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.blanc,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _ring(double v, double size, double minScale, double maxOpacity) {
    return Transform.scale(
      scale: 0.45 + v * 0.9,
      child: Opacity(
        opacity: ((1 - v) * maxOpacity).clamp(0.0, 1.0),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.rouge,
          ),
        ),
      ),
    );
  }
}

// ─── Titre de section ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 22, decoration: BoxDecoration(color: AppColors.rouge, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(text, style: AppTextStyles.h2),
      ],
    );
  }
}

// ─── Grille d'actions rapides ─────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.edit_note_rounded, AppColors.rouge, AppColors.rougeLight, 'Signalement\nAnonyme', '/new-dossier'),
      (Icons.gavel_rounded, AppColors.bleuMid, const Color(0xFFE8F0FE), 'Consulter\nun Juriste', '/juristes'),
      (Icons.psychology_rounded, AppColors.emeraude, AppColors.emeraudeLight, 'Soutien\nPsychologique', ''),
      (Icons.people_rounded, AppColors.or, AppColors.orLight, 'ONG\nPartenaires', ''),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: items.map((e) => _ActionCard(
        icon: e.$1,
        color: e.$2,
        bg: e.$3,
        label: e.$4,
        onTap: e.$5.isEmpty ? null : () => context.go(e.$5),
      )).toList(),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color, bg;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gris,
                height: 1.3,
              ),
            ),
            if (onTap == null)
              const Text(
                'Bientôt',
                style: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 11,
                  color: AppColors.grisLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Tuile numéro d'urgence ───────────────────────────────────────────────────

class _EmergencyTile extends StatelessWidget {
  const _EmergencyTile({
    required this.icon,
    required this.label,
    required this.number,
    required this.onCall,
  });
  final IconData icon;
  final String label, number;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: AppColors.rouge, width: 3.5)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.rougeLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.rouge, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600, color: AppColors.gris)),
                Text(
                  number,
                  style: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.rouge,
                    letterSpacing: 1,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCall,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE74C3C), AppColors.rouge],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rouge.withAlpha(70),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_rounded, color: AppColors.blanc, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Appeler',
                    style: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blanc,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte droits ─────────────────────────────────────────────────────────────

class _RightsCard extends StatelessWidget {
  const _RightsCard();

  @override
  Widget build(BuildContext context) {
    const points = [
      'Loi n° 2016/007 du 12 juillet 2016 — Code pénal camerounais (arts. 292–297 : violences conjugales)',
      'La violence domestique est un crime passible d\'emprisonnement selon le droit camerounais',
      'Vous pouvez déposer une plainte anonymement via ce module',
    ];
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bleuNuit, AppColors.bleuMid],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppColors.ombre],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.orPale, size: 20),
              SizedBox(width: 10),
              Text(
                'VOS DROITS',
                style: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orPale,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...points.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.or,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t,
                    style: AppTextStyles.bodyWhite.copyWith(fontSize: 15, height: 1.5),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => context.go('/lois'),
            child: const Row(
              children: [
                Text(
                  'Voir tous les textes de loi',
                  style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orPale,
                  ),
                ),
                SizedBox(width: 5),
                Icon(Icons.arrow_forward_rounded, color: AppColors.orPale, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bannière anonymat ────────────────────────────────────────────────────────

class _AnonymityBanner extends StatelessWidget {
  const _AnonymityBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.emeraudeLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emeraude.withAlpha(60)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: AppColors.emeraude, size: 28),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Aucune information personnelle n\'est requise pour signaler. Votre identité reste protégée.',
              style: TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 14,
                color: AppColors.emeraude,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
