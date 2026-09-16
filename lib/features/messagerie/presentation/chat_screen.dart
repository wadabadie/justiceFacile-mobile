import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/api_service.dart';

// ─── Modèle ───────────────────────────────────────────────────────────────────

class _Message {
  _Message({
    required this.id,
    required this.contenu,
    required this.auteurNom,
    required this.estDeMoi,
    required this.dateEnvoi,
  });
  final int id;
  final String contenu;
  final String auteurNom;
  final bool estDeMoi;
  final DateTime dateEnvoi;

  factory _Message.fromJson(Map<String, dynamic> json) => _Message(
        id:        json['id'] as int,
        contenu:   json['contenu'] as String? ?? '',
        auteurNom: json['auteur_nom'] as String? ?? '',
        estDeMoi:  json['est_de_moi'] as bool? ?? false,
        dateEnvoi: DateTime.tryParse(json['date_envoi'] as String? ?? '')?.toLocal()
                   ?? DateTime.now(),
      );

  String get heure {
    final h = dateEnvoi.hour.toString().padLeft(2, '0');
    final m = dateEnvoi.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── Écran ────────────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.dossierId,
    required this.canal,
    required this.contactName,
  });
  final int dossierId;
  final String canal;
  final String contactName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();

  List<_Message> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.instance.get(
        ApiConstants.dossierMessages(widget.dossierId, widget.canal),
      );
      final list = res.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _messages = list
            .map((e) => _Message.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
      _scrollToBottom();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ApiService.extractError(e.response?.data);
        _loading = false;
      });
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _ctrl.clear();

    try {
      final res = await ApiService.instance.post(
        ApiConstants.dossierMessages(widget.dossierId, widget.canal),
        data: {'contenu': text},
      );
      final msg = _Message.fromJson(res.data as Map<String, dynamic>);
      if (!mounted) return;
      setState(() {
        _messages.add(msg);
        _sending = false;
      });
      _scrollToBottom();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractError(e.response?.data)),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE8),
      body: Column(
        children: [
          _ChatHeader(
            name: widget.contactName,
            onBack: () => context.go('/messagerie'),
          ),
          const _EncryptionBanner(),
          Expanded(child: _buildMessages()),
          _ChatInput(
            controller: _ctrl,
            sending: _sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.bleuNuit),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.grisLight),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'GoogleSans',
                    fontSize: 14, color: AppColors.grisMid)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadMessages,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppStrings.of(context).btnRetry),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Text(AppStrings.of(context).chatEmpty,
            style: const TextStyle(fontFamily: 'GoogleSans',
                fontSize: 14, color: AppColors.grisMid)),
      );
    }

    return RefreshIndicator(
      color: AppColors.bleuNuit,
      onRefresh: _loadMessages,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        itemCount: _messages.length,
        itemBuilder: (_, i) => _Bubble(message: _messages[i]),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.name, required this.onBack});
  final String name;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final initials = name
        .replaceAll(RegExp(r'^(Me\.|Dr\.)'), '')
        .trim()
        .split(' ')
        .take(2)
        .map((p) => p.isNotEmpty ? p[0] : '')
        .join()
        .toUpperCase();

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
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.blanc, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.or.withAlpha(200),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 16,
                          fontWeight: FontWeight.w700, color: AppColors.blanc)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 17,
                            fontWeight: FontWeight.w700, color: AppColors.blanc)),
                    Row(
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(
                              color: AppColors.emeraude, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(s.chatSecure,
                            style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 13,
                                color: Color(0x99FFFFFF))),
                      ],
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

// ─── Bannière chiffrement ─────────────────────────────────────────────────────

class _EncryptionBanner extends StatelessWidget {
  const _EncryptionBanner();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      color: AppColors.emeraudeLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, size: 13, color: AppColors.emeraude),
          const SizedBox(width: 6),
          Text(s.chatEncryptionBanner,
              style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 12,
                  color: AppColors.emeraude, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Bulle ────────────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final _Message message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.estDeMoi;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(color: AppColors.bleuMid, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppColors.blanc, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              decoration: BoxDecoration(
                color: isMine ? AppColors.bleuNuit : AppColors.blanc,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  isMine ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMine ? const Radius.circular(4)  : const Radius.circular(18),
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMine) ...[
                    Text(message.auteurNom,
                        style: const TextStyle(
                          fontFamily: 'GoogleSans', fontSize: 11,
                          fontWeight: FontWeight.w700, color: AppColors.bleuMid,
                        )),
                    const SizedBox(height: 3),
                  ],
                  Text(message.contenu,
                      style: TextStyle(
                        fontFamily: 'GoogleSans', fontSize: 15,
                        color: isMine ? AppColors.blanc : AppColors.gris,
                        height: 1.45,
                      )),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message.heure,
                          style: TextStyle(
                            fontFamily: 'GoogleSans', fontSize: 11,
                            color: isMine ? const Color(0x80FFFFFF) : AppColors.grisLight,
                          )),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all_rounded,
                            size: 14, color: AppColors.orPale),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMine) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─── Zone de saisie ──────────────────────────────────────────────────────────

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.sending,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      color: AppColors.blanc,
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.fond,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x1A000000)),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15,
                    color: AppColors.gris),
                decoration: InputDecoration(
                  hintText: s.chatHint,
                  hintStyle: const TextStyle(fontFamily: 'GoogleSans', fontSize: 15,
                      color: AppColors.grisLight),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: sending
                      ? [AppColors.grisLight, AppColors.grisLight]
                      : [AppColors.bleuMid, AppColors.bleuNuit],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: sending ? [] : [
                  BoxShadow(color: AppColors.bleuNuit.withAlpha(80),
                      blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.blanc),
                    )
                  : const Icon(Icons.send_rounded, color: AppColors.blanc, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
