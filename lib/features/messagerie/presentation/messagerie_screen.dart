import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

// ─── Modèle ───────────────────────────────────────────────────────────────────

class _Conversation {
  _Conversation({
    required this.dossierId,
    required this.canal,
    required this.nom,
    required this.role,
  });
  final int dossierId;
  final String canal;
  final String nom;
  final String role;
  String dernierMessage = '';
  String heure = '';
  int nonLus = 0;
}

// ─── Écran ────────────────────────────────────────────────────────────────────

class MessagerieScreen extends StatefulWidget {
  const MessagerieScreen({super.key});

  @override
  State<MessagerieScreen> createState() => _MessagerieScreenState();
}

class _MessagerieScreenState extends State<MessagerieScreen> {
  List<_Conversation> _conversations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.instance.get(ApiConstants.dossiers);
      final dossiers = res.data as List<dynamic>;

      final convs = <_Conversation>[];

      // Fetch canaux for each dossier in parallel.
      await Future.wait(dossiers.map((d) async {
        final dossierId = d['id'] as int;
        try {
          final cRes = await ApiService.instance.get(ApiConstants.dossierCanaux(dossierId));
          final canaux = cRes.data as List<dynamic>;
          for (final c in canaux) {
            convs.add(_Conversation(
              dossierId: dossierId,
              canal:     c['canal'] as String,
              nom:       c['specialiste'] as String? ?? 'Spécialiste',
              role:      _roleLabel(c['canal'] as String? ?? ''),
            ));
          }
        } catch (_) {
          // Skip dossiers whose channels can't be loaded.
        }
      }));

      // Fetch last message + unread count per conversation in parallel.
      await Future.wait(convs.map((conv) async {
        try {
          final mRes = await ApiService.instance.get(
            ApiConstants.dossierMessages(conv.dossierId, conv.canal),
            params: {'ordering': '-date_envoi', 'limit': '1'},
          );
          final msgs = mRes.data as List<dynamic>;
          if (msgs.isNotEmpty) {
            final last = msgs.first as Map<String, dynamic>;
            conv.dernierMessage = last['contenu'] as String? ?? '';
            conv.heure = _fmtHeure(last['date_envoi'] as String? ?? '');
          }
        } catch (_) {}

        try {
          final uRes = await ApiService.instance.get(
            ApiConstants.dossierMessagesNonLus(conv.dossierId, conv.canal),
          );
          conv.nonLus = (uRes.data['non_lus'] as int?) ?? 0;
        } catch (_) {}
      }));

      if (!mounted) return;
      setState(() {
        _conversations = convs;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ApiService.extractError(e.response?.data);
        _loading = false;
      });
    }
  }

  String _roleLabel(String canal) => switch (canal) {
    'juriste'     => 'Juriste',
    'psychologue' => 'Psychologue',
    'ong'         => 'ONG Partenaire',
    _             => 'Spécialiste',
  };

  String _fmtHeure(String iso) {
    if (iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inDays == 0) {
        return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Hier';
      } else {
        return '${d.day}/${d.month}';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          const _MessagerieHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.messages),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.grisLight),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'GoogleSans',
                    fontSize: 15, color: AppColors.grisMid)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppStrings.of(context).btnRetry),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleuNuit, foregroundColor: AppColors.blanc),
            ),
          ],
        ),
      );
    }

    if (_conversations.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _conversations.length,
        itemBuilder: (_, i) => _ConversationTile(
          conv: _conversations[i],
          onTap: () => context.go('/chat', extra: {
            'dossierId':   _conversations[i].dossierId,
            'canal':       _conversations[i].canal,
            'contactName': _conversations[i].nom,
          }),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _MessagerieHeader extends StatelessWidget {
  const _MessagerieHeader();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.messagerieTitle,
                        style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 26,
                            fontWeight: FontWeight.w700, color: AppColors.blanc)),
                    Text(s.messagerieSubtitle,
                        style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 14,
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
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.orPale, size: 20),
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
    final parts = conv.nom
        .replaceAll(RegExp(r'^(Me\.|Dr\.)'), '')
        .trim()
        .split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  Color get _avatarColor => switch (conv.canal) {
    'juriste'     => AppColors.bleuMid,
    'psychologue' => AppColors.emeraude,
    'ong'         => AppColors.or,
    _             => AppColors.grisMid,
  };

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
                      if (conv.heure.isNotEmpty)
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
                  if (conv.dernierMessage.isNotEmpty) ...[
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── État vide ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(color: AppColors.fond2, shape: BoxShape.circle),
            child: const Icon(Icons.forum_outlined, size: 40, color: AppColors.grisLight),
          ),
          const SizedBox(height: 20),
          Text(s.messagerieEmpty,
              style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 18,
                  fontWeight: FontWeight.w700, color: AppColors.bleuNuit)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              s.messagerieEmptyDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 14,
                  color: AppColors.grisMid, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
