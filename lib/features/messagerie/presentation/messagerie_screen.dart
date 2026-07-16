import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

// ─── Modèle ───────────────────────────────────────────────────────────────────

class _Conversation {
  const _Conversation({
    required this.id,
    required this.nom,
    required this.role,
    required this.dernierMessage,
    required this.heure,
    required this.nonLus,
    this.isSysteme = false,
  });
  final String id, nom, role, dernierMessage, heure;
  final int nonLus;
  final bool isSysteme;
}

const _conversations = [
  _Conversation(
    id: '1',
    nom: 'Me. Jean-Baptiste Fotso',
    role: 'Juriste · Droit du travail',
    dernierMessage: 'J\'ai bien reçu votre dossier. Pouvez-vous m\'envoyer les preuves ?',
    heure: '14:32',
    nonLus: 2,
  ),
  _Conversation(
    id: '2',
    nom: 'Dr. Pauline Ngo',
    role: 'Psychologue · VBG',
    dernierMessage: 'Nous pouvons programmer un entretien demain à 10h si vous êtes disponible.',
    heure: '11:05',
    nonLus: 0,
  ),
  _Conversation(
    id: '3',
    nom: 'Me. Rose Ateba',
    role: 'Juriste · Droit de la famille',
    dernierMessage: 'Je vous rappelle demain matin pour la suite de la procédure.',
    heure: 'Hier',
    nonLus: 0,
  ),
  _Conversation(
    id: '4',
    nom: 'Support Justice Facile',
    role: 'Équipe JF',
    dernierMessage: 'Bienvenue ! Notre équipe est disponible pour vous aider.',
    heure: '10 juin',
    nonLus: 0,
    isSysteme: true,
  ),
];

// ─── Écran ────────────────────────────────────────────────────────────────────

class MessagerieScreen extends StatelessWidget {
  const MessagerieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          const _MessagerieHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: _conversations.length,
              itemBuilder: (_, i) => _ConversationTile(
                conv: _conversations[i],
                onTap: () => context.go('/chat', extra: _conversations[i].nom),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.messages),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _MessagerieHeader extends StatelessWidget {
  const _MessagerieHeader();

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
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Messages',
                        style: TextStyle(fontFamily: 'GoogleSans', fontSize: 26,
                            fontWeight: FontWeight.w700, color: AppColors.blanc)),
                    Text('Conversations sécurisées',
                        style: TextStyle(fontFamily: 'GoogleSans', fontSize: 14,
                            color: Color(0x80FFFFFF))),
                  ],
                ),
              ),
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_outline_rounded, color: AppColors.orPale, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tuile conversation ───────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conv, required this.onTap});
  final _Conversation conv;
  final VoidCallback onTap;

  String get _initials {
    if (conv.isSysteme) return 'JF';
    final parts = conv.nom.replaceAll(RegExp(r'^(Me\.|Dr\.)'), '').trim().split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  Color get _avatarColor => conv.isSysteme
      ? AppColors.or
      : conv.role.contains('Juriste')
          ? AppColors.bleuMid
          : conv.role.contains('Psychologue')
              ? AppColors.emeraude
              : AppColors.grisMid;

  @override
  Widget build(BuildContext context) {
    final hasUnread = conv.nonLus > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasUnread ? const Color(0xFFF0F4FF) : AppColors.blanc,
          borderRadius: BorderRadius.circular(16),
          border: hasUnread
              ? Border.all(color: AppColors.bleuNuit.withAlpha(30))
              : null,
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_avatarColor.withAlpha(200), _avatarColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(_initials,
                        style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 18,
                            fontWeight: FontWeight.w700, color: AppColors.blanc)),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.rouge,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.blanc, width: 2),
                      ),
                      child: Center(
                        child: Text('${conv.nonLus}',
                            style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 10,
                                fontWeight: FontWeight.w800, color: AppColors.blanc)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(conv.nom,
                            style: TextStyle(
                              fontFamily: 'GoogleSans', fontSize: 16,
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                              color: AppColors.bleuNuit,
                            )),
                      ),
                      Text(conv.heure,
                          style: TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 13,
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
                            color: hasUnread ? AppColors.bleuNuit : AppColors.grisLight,
                          )),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(conv.role,
                      style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 12,
                          color: AppColors.grisMid, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(conv.dernierMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 14,
                        color: hasUnread ? AppColors.gris : AppColors.grisMid,
                        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
