import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/notification_service.dart';

// ─── Modèle ───────────────────────────────────────────────────────────────────

class _Notif {
  _Notif({
    required this.id,
    required this.titre,
    required this.message,
    required this.type,
    required this.lu,
    required this.dateCreation,
  });

  final int id;
  final String titre;
  final String message;
  final String type;
  bool lu;
  final DateTime dateCreation;

  factory _Notif.fromJson(Map<String, dynamic> j) => _Notif(
        id:           j['id'] as int,
        titre:        j['titre'] as String? ?? '',
        message:      j['message'] as String? ?? '',
        type:         j['type'] as String? ?? 'info',
        lu:           j['lu'] as bool? ?? false,
        dateCreation: DateTime.tryParse(j['date_creation'] as String? ?? '')
                          ?.toLocal() ??
                      DateTime.now(),
      );

  String get heureRelative {
    final diff = DateTime.now().difference(dateCreation);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return '${dateCreation.day}/${dateCreation.month}/${dateCreation.year}';
  }
}

// ─── Écran ────────────────────────────────────────────────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<_Notif> _notifs = [];
  bool _loading = true;
  String? _error;
  bool _markingAll = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.instance.get(ApiConstants.notifications);
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _notifs = list
            .map((e) => _Notif.fromJson(e as Map<String, dynamic>))
            .toList();
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

  Future<void> _markOne(int index) async {
    final notif = _notifs[index];
    if (notif.lu) return;
    try {
      await ApiService.instance.post(ApiConstants.notificationLire(notif.id));
      if (!mounted) return;
      setState(() => notif.lu = true);
    } on DioException {
      // Best-effort: don't surface error to user
    }
  }

  Future<void> _markAll() async {
    if (_markingAll) return;
    setState(() => _markingAll = true);
    try {
      await ApiService.instance.post(ApiConstants.notificationsToutLire);
      if (!mounted) return;
      setState(() {
        for (final n in _notifs) {
          n.lu = true;
        }
        _markingAll = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _markingAll = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data)),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  int get _unreadCount => _notifs.where((n) => !n.lu).length;

  Future<void> _sendTestNotif() async {
    await NotificationService.instance.testNotification();
    final token = await NotificationService.instance.getFcmToken();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notification envoyée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Une notification locale vient d\'être affichée.'),
            const SizedBox(height: 16),
            const Text('Token FCM (Firebase Console) :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            SelectableText(
              token ?? 'Non disponible',
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
            if (token != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Token copié'),
                    duration: Duration(seconds: 2),
                  ));
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copier le token'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendTestNotif,
        backgroundColor: AppColors.emeraude,
        icon: const Icon(Icons.notifications_active_rounded, color: AppColors.blanc),
        label: const Text('Tester',
            style: TextStyle(color: AppColors.blanc, fontFamily: 'GoogleSans')),
      ),
      body: Column(
        children: [
          _NotifHeader(
            unreadCount: _unreadCount,
            onBack: () => context.go('/home'),
          ),
          if (!_loading && _error == null && _unreadCount > 0)
            _MarkAllBar(loading: _markingAll, onTap: _markAll),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.bleuNuit));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.grisLight),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 15,
                    color: AppColors.grisMid)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppStrings.of(context).btnRetry),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleuNuit,
                  foregroundColor: AppColors.blanc),
            ),
          ],
        ),
      );
    }

    if (_notifs.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notifs.length,
        itemBuilder: (_, i) => _NotifTile(
          notif: _notifs[i],
          onTap: () => _markOne(i),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _NotifHeader extends StatelessWidget {
  const _NotifHeader({required this.unreadCount, required this.onBack});
  final int unreadCount;
  final VoidCallback onBack;

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
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.blanc, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.notificationsTitle,
                        style: const TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blanc)),
                    if (unreadCount > 0)
                      Text(s.notificationsUnread(unreadCount),
                          style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 13,
                              color: Color(0x99FFFFFF))),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: AppColors.orPale, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Barre "tout marquer lu" ──────────────────────────────────────────────────

class _MarkAllBar extends StatelessWidget {
  const _MarkAllBar({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      color: AppColors.blanc,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: loading ? null : onTap,
            child: Row(
              children: [
                if (loading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: AppColors.bleuMid),
                  )
                else
                  const Icon(Icons.done_all_rounded,
                      size: 16, color: AppColors.bleuMid),
                const SizedBox(width: 6),
                Text(s.notificationsMarkAll,
                    style: const TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bleuMid)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tuile notification ───────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif, required this.onTap});
  final _Notif notif;
  final VoidCallback onTap;

  IconData get _icon => switch (notif.type) {
        'message'   => Icons.chat_bubble_outline_rounded,
        'dossier'   => Icons.folder_open_rounded,
        'rendez_vous' || 'rdv' => Icons.event_rounded,
        'alerte'    => Icons.warning_amber_rounded,
        _           => Icons.info_outline_rounded,
      };

  Color get _iconColor => switch (notif.type) {
        'message'   => AppColors.bleuMid,
        'dossier'   => AppColors.emeraude,
        'rendez_vous' || 'rdv' => AppColors.or,
        'alerte'    => AppColors.rouge,
        _           => AppColors.grisMid,
      };

  Color get _iconBg => switch (notif.type) {
        'message'   => const Color(0xFFE8F0FE),
        'dossier'   => AppColors.emeraudeLight,
        'rendez_vous' || 'rdv' => AppColors.orLight,
        'alerte'    => AppColors.rougeLight,
        _           => AppColors.fond2,
      };

  @override
  Widget build(BuildContext context) {
    final isUnread = !notif.lu;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF0F4FF) : AppColors.blanc,
          borderRadius: BorderRadius.circular(16),
          border: isUnread
              ? Border.all(color: AppColors.bleuNuit.withAlpha(30))
              : null,
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.titre,
                          style: TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 15,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.bleuNuit,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notif.heureRelative,
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 12,
                          color: isUnread
                              ? AppColors.bleuMid
                              : AppColors.grisLight,
                          fontWeight: isUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      color:
                          isUnread ? AppColors.gris : AppColors.grisMid,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.bleuMid,
                    shape: BoxShape.circle,
                  ),
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
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
                color: AppColors.fond2, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_off_outlined,
                size: 40, color: AppColors.grisLight),
          ),
          const SizedBox(height: 20),
          Text(s.notificationsEmpty,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bleuNuit)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              s.notificationsEmptyDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 14,
                  color: AppColors.grisMid,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
