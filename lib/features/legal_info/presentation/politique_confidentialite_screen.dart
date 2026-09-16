import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_strings.dart';

class PolitiqueConfidentialiteScreen extends StatelessWidget {
  const PolitiqueConfidentialiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          _Header(onBack: () => context.go('/profil')),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              children: const [
                _UpdateBadge(date: '17 août 2026'),
                SizedBox(height: 20),
                _IntroCard(),
                SizedBox(height: 16),
                _Section(
                  number: '1',
                  title: 'Responsable du traitement',
                  content: [
                    _Para(
                      'JusticeFacile est développée dans le cadre d\'un projet académique à l\'IAI-Cameroun. '
                      'Le responsable du traitement des données est l\'équipe projet, joignable à l\'adresse : '
                      'itdreamtech237@gmail.com.',
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _Section(
                  number: '2',
                  title: 'Base légale — droit camerounais',
                  content: [
                    _Para(
                      'Le traitement de vos données personnelles est fondé sur les textes suivants :',
                    ),
                    _BulletItem(
                      'Loi n° 2010/012 du 21 décembre 2010 relative à la cybersécurité et à la cybercriminalité au Cameroun — protection des données à caractère personnel (art. 76–85).',
                    ),
                    _BulletItem(
                      'Loi n° 2016/007 du 12 juillet 2016 portant Code pénal camerounais — incrimination de la violation du secret des communications (art. 72).',
                    ),
                    _BulletItem(
                      'Décret n° 2012/1638/PM du 14 juin 2012 fixant les modalités d\'organisation et de fonctionnement de l\'Agence Nationale des Technologies de l\'Information et de la Communication (ANTIC).',
                    ),
                    _BulletItem(
                      'Votre consentement explicite, recueilli lors de l\'inscription, pour les données sensibles liées aux signalements VBG.',
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _Section(
                  number: '3',
                  title: 'Données collectées',
                  content: [
                    _SubTitle('Données d\'identité'),
                    _BulletItem('Nom, prénom, adresse e-mail, numéro de téléphone.'),
                    _BulletItem('Région de résidence.'),
                    _SubTitle('Données d\'utilisation'),
                    _BulletItem('Dossiers juridiques créés, messages échangés avec les spécialistes.'),
                    _BulletItem('Historique des consultations avec l\'assistant IA.'),
                    _SubTitle('Données sensibles (VBG uniquement)'),
                    _BulletItem(
                      'Nature de la violence subie, description des faits. '
                      'Ces données sont chiffrées en base et accessibles uniquement au spécialiste assigné.',
                    ),
                    _BulletItem('Coordonnées GPS lors d\'une alerte SOS, transmises aux services d\'urgence.'),
                  ],
                ),
                SizedBox(height: 12),
                _Section(
                  number: '4',
                  title: 'Finalités du traitement',
                  content: [
                    _BulletItem('Fourniture des services d\'assistance juridique et psychologique.'),
                    _BulletItem('Mise en relation avec des juristes, psychologues et ONG partenaires.'),
                    _BulletItem('Gestion des alertes SOS et orientation vers les services d\'urgence.'),
                    _BulletItem('Amélioration de l\'assistant IA juridique.'),
                    _BulletItem('Suivi des dossiers et notification des mises à jour.'),
                  ],
                ),
                SizedBox(height: 12),
                _Section(
                  number: '5',
                  title: 'Signalement anonyme VBG',
                  content: [
                    _Para(
                      'Conformément à l\'article 5 de la loi n° 2010/012, vous avez la possibilité de '
                      'soumettre un signalement sans fournir d\'informations permettant de vous identifier. '
                      'Dans ce cas :',
                    ),
                    _BulletItem('Aucun nom, prénom ou numéro de téléphone n\'est requis.'),
                    _BulletItem('Le signalement est traité avec la même priorité qu\'un signalement nominatif.'),
                    _BulletItem(
                      'Si vous fournissez des coordonnées GPS lors d\'une alerte SOS, '
                      'elles sont transmises uniquement aux services de secours (117) et supprimées après résolution.',
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _Section(
                  number: '6',
                  title: 'Durée de conservation',
                  content: [
                    _BulletItem('Données de compte : conservées jusqu\'à suppression du compte.'),
                    _BulletItem('Dossiers actifs : conservés pendant la durée du suivi + 5 ans (prescription civile).'),
                    _BulletItem('Alertes SOS : 90 jours après résolution.'),
                    _BulletItem('Journaux d\'audit : 1 an (obligations légales de sécurité).'),
                    _BulletItem('Données d\'historique IA : 6 mois après la dernière interaction.'),
                  ],
                ),
                SizedBox(height: 12),
                _Section(
                  number: '7',
                  title: 'Partage des données',
                  content: [
                    _Para('Vos données ne sont jamais vendues ni cédées à des tiers commerciaux. '
                        'Elles peuvent être partagées uniquement avec :'),
                    _BulletItem('Le juriste, psychologue ou ONG assigné à votre dossier.'),
                    _BulletItem('Les services d\'urgence (Police 117, SAMU 119) en cas d\'alerte SOS.'),
                    _BulletItem(
                      'Les autorités judiciaires camerounaises, sur réquisition légale '
                      '(art. 80 de la loi n° 2010/012).',
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _Section(
                  number: '8',
                  title: 'Vos droits',
                  content: [
                    _Para(
                      'Conformément à la loi n° 2010/012 et aux recommandations de l\'ANTIC, vous disposez des droits suivants :',
                    ),
                    _BulletItem('Droit d\'accès : consulter vos données personnelles via votre profil.'),
                    _BulletItem('Droit de rectification : modifier vos informations depuis votre profil.'),
                    _BulletItem('Droit à l\'effacement : supprimer votre compte depuis votre profil.'),
                    _BulletItem('Droit à la portabilité : obtenir une copie de vos données sur demande écrite.'),
                    _BulletItem(
                      'Droit d\'opposition : vous opposer au traitement de vos données pour certaines finalités.',
                    ),
                    _Para(
                      'Pour exercer ces droits, contactez : itdreamtech237@gmail.com. '
                      'Toute demande sera traitée dans un délai de 30 jours.',
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _Section(
                  number: '9',
                  title: 'Sécurité des données',
                  content: [
                    _BulletItem('Chiffrement TLS/HTTPS pour toutes les communications.'),
                    _BulletItem('Chiffrement AES-256 pour les données VBG sensibles en base.'),
                    _BulletItem('Authentification par jeton JWT avec expiration courte (1 heure).'),
                    _BulletItem('Double authentification optionnelle (2FA).'),
                    _BulletItem('Accès aux dossiers VBG strictement limité aux spécialistes assignés.'),
                    _BulletItem('Journaux d\'audit pour toute action sur les données sensibles.'),
                  ],
                ),
                SizedBox(height: 12),
                _Section(
                  number: '10',
                  title: 'Cookies et données de navigation',
                  content: [
                    _Para(
                      'L\'application mobile ne dépose aucun cookie. '
                      'Les préférences locales (langue, mode discret) sont stockées uniquement '
                      'sur votre appareil via les préférences système (SharedPreferences) '
                      'et ne sont jamais transmises à nos serveurs.',
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _Section(
                  number: '11',
                  title: 'Modifications de cette politique',
                  content: [
                    _Para(
                      'Toute modification substantielle de cette politique vous sera notifiée '
                      'par notification dans l\'application et par e-mail. '
                      'La version en vigueur est toujours accessible depuis votre profil.',
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _ContactCard(),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
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
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.blanc),
              ),
              Expanded(
                child: Builder(builder: (ctx) {
                  final s = AppStrings.of(ctx);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.politiqueTitle,
                          style: const TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 20,
                            fontWeight: FontWeight.w700, color: AppColors.blanc,
                          )),
                      const Text('JusticeFacile · Cameroun',
                          style: TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 13,
                            color: Color(0x80FFFFFF),
                          )),
                    ],
                  );
                }),
              ),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.orPale, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge date de mise à jour ─────────────────────────────────────────────────

class _UpdateBadge extends StatelessWidget {
  const _UpdateBadge({required this.date});
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.orLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.or.withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.update_rounded, size: 14, color: AppColors.orDark),
              const SizedBox(width: 6),
              Builder(builder: (ctx) => Text(AppStrings.of(ctx).politiqueLastUpdate(date),
                  style: const TextStyle(
                    fontFamily: 'GoogleSans', fontSize: 12,
                    fontWeight: FontWeight.w600, color: AppColors.orDark,
                  ))),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Intro card ────────────────────────────────────────────────────────────────

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bleuNuit, AppColors.bleuMid],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.orPale, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'JusticeFacile s\'engage à protéger vos données personnelles, '
              'en particulier celles des victimes de violences. '
              'Cette politique est conforme à la législation camerounaise en matière '
              'de protection des données (loi n° 2010/012).',
              style: TextStyle(
                fontFamily: 'GoogleSans', fontSize: 14,
                color: Color(0xCCFFFFFF), height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section numérotée ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.number,
    required this.title,
    required this.content,
  });
  final String number, title;
  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.bleuNuit,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(number,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 13,
                          fontWeight: FontWeight.w800, color: AppColors.blanc,
                        )),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 15,
                        fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
                      )),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Éléments de contenu ───────────────────────────────────────────────────────

class _Para extends StatelessWidget {
  const _Para(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
            fontFamily: 'GoogleSans', fontSize: 14,
            color: AppColors.gris, height: 1.6,
          )),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(text,
          style: const TextStyle(
            fontFamily: 'GoogleSans', fontSize: 14,
            fontWeight: FontWeight.w700, color: AppColors.bleuNuit,
          )),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 5, height: 5,
              decoration: BoxDecoration(
                color: AppColors.or,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                  fontFamily: 'GoogleSans', fontSize: 14,
                  color: AppColors.gris, height: 1.5,
                )),
          ),
        ],
      ),
    );
  }
}

// ── Carte contact ─────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.emeraudeLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emeraude.withAlpha(60)),
      ),
      child: Builder(builder: (ctx) {
        final s = AppStrings.of(ctx);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.email_outlined, color: AppColors.emeraude, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.politiqueContactTitle,
                      style: const TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 14,
                        fontWeight: FontWeight.w700, color: AppColors.emeraude,
                      )),
                  const SizedBox(height: 4),
                  const Text('itdreamtech237@gmail.com',
                      style: TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 14,
                        color: AppColors.emeraude, fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 4),
                  Text(s.politiqueContactDelay,
                      style: const TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 12,
                        color: AppColors.emeraude,
                      )),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
